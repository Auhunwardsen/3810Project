-- Hazard Detection Unit
-------------------------------------------------------------------------
-- PURPOSE: Detect pipeline hazards and generate stall/flush signals
--
-- DATA HAZARDS DETECTED:
--   1. Load-Use: Instruction uses result of load (stall 1 cycle)
--   2. Branch Data: Branch depends on value in EX stage (stall until MEM)
--   3. JALR Data: JALR depends on RS1 value in EX stage (stall until MEM)
--
-- CONTROL HAZARDS:
--   - Branch taken or Jump detected → flush IF/ID (wrong path instruction)
--   - Don't flush if we're stalling for data hazard
--
-- OUTPUTS:
--   o_PCWrite: 0=stall PC, 1=update PC
--   o_IFID_Write: 0=freeze IF/ID, 1=update IF/ID
--   o_ControlMux: 1=insert NOP (zero control signals)
--   o_IFID_Flush: 1=flush IF/ID to NOP
-------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detection is
  port(
    i_CLK          : in std_logic;  -- Clock input for delayed flush
    -- From ID/EX register
    i_IDEX_MemRead  : in std_logic;
    i_IDEX_RD       : in std_logic_vector(4 downto 0);
    i_IDEX_RegWrite : in std_logic;  -- Added: to detect any EX stage write

    -- From IF/ID register
    i_IFID_RS1      : in std_logic_vector(4 downto 0);
    i_IFID_RS2      : in std_logic_vector(4 downto 0);

    -- Control hazard signals
    i_Branch        : in std_logic;
    i_Jump          : in std_logic;
    i_JALR          : in std_logic;  -- JALR instruction in ID (needs RS1)
    i_Branch_ID     : in std_logic;  -- Added: indicates branch in ID stage

    -- Output control signals
    o_PCWrite       : out std_logic;  -- Enable PC update
    o_IFID_Write    : out std_logic;  -- Enable IF/ID register write
    o_ControlMux    : out std_logic;  -- Mux control for inserting NOPs
    o_IFID_Flush    : out std_logic;  -- Flush IF/ID register
    o_IDEX_Flush    : out std_logic   -- Flush ID/EX register
  );
end hazard_detection;

architecture behavioral of hazard_detection is
  signal s_LoadUseHazard : std_logic;
  signal s_BranchDataHazard : std_logic;
  signal s_JumpDataHazard : std_logic;
  signal s_ControlHazard : std_logic;
  signal s_DataHazard : std_logic;
begin

  -- HAZARD 1: Load-Use Hazard
  -- Example: lw x1, 0(x2)   # Load in EX stage
  --          add x3, x1, x4  # Uses x1 in ID stage (not ready yet!)
  -- Solution: Stall 1 cycle - can forward from MEM stage next cycle
  s_LoadUseHazard <= '1' when (i_IDEX_MemRead = '1' and
                              ((i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000") or
                               (i_IDEX_RD = i_IFID_RS2 and i_IFID_RS2 /= "00000")))
                     else '0';

  -- HAZARD 2: Branch Data Hazard
  -- Example: add x1, x2, x3  # Write x1 in EX stage
  --          beq x1, x0, L1  # Branch compares x1 in ID stage (not ready!)
  -- Solution: Stall 1 cycle - can forward from MEM stage next cycle
  -- Note: Branches are resolved in ID stage, so can't forward from EX
  s_BranchDataHazard <= '1' when (i_Branch_ID = '1' and i_IDEX_RegWrite = '1' and
                                  ((i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000") or
                                   (i_IDEX_RD = i_IFID_RS2 and i_IFID_RS2 /= "00000")))
                        else '0';

  -- HAZARD 3: JALR Data Hazard
  -- Example: lw x1, 0(x2)    # Load in EX stage
  --          jalr x0, 0(x1)  # JALR uses x1 for target in ID stage (not ready!)
  -- Solution: Stall 1 cycle - can forward from MEM stage next cycle
  -- Note: JAL doesn't need this (target is PC+immediate, not register-based)
  s_JumpDataHazard <= '1' when (i_JALR = '1' and i_IDEX_RegWrite = '1' and
                                (i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000"))
                      else '0';

  -- Combined data hazard signal
  s_DataHazard <= s_LoadUseHazard or s_BranchDataHazard or s_JumpDataHazard;

  -- Control hazard: any branch or jump that redirects PC
  s_ControlHazard <= i_Branch or i_Jump;

  -- Output logic - control hazards allow PC update, except when there's a data hazard
  -- that affects the control decision (JALR target or branch condition)
  -- JALR and branch data hazards must stall to get correct register values
  o_PCWrite <= not s_DataHazard;

  -- IFID_Write: disable when stalling for data hazards
  o_IFID_Write <= not s_DataHazard;

  -- ControlMux: Insert NOP for data hazards only
  o_ControlMux <= s_DataHazard;

  -- Flush logic for hardware-scheduled pipeline:
  -- When branch/jump is detected in ID stage, the next sequential instruction
  -- has already been fetched and is in IF stage. On the next clock edge:
  --   - PC will be updated to jump/branch target
  --   - IF/ID flush will prevent the wrong instruction from entering the pipeline
  --   - The branch/jump itself must continue through to complete (jumps write link register)
  -- Exception: don't flush if we're stalling due to a data hazard
  o_IFID_Flush <= s_ControlHazard and not s_DataHazard;  -- Flush only when not stalling
  o_IDEX_Flush <= '0';  -- Never flush ID/EX (let control instruction complete)

end behavioral;