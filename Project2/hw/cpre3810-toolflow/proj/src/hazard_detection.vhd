-- Hazard Detection Unit
-- Detects data and control hazards and generates stall/flush signals
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

  -- Load-use hazard detection
  -- Occurs when current instruction uses result of previous load instruction
  s_LoadUseHazard <= '1' when (i_IDEX_MemRead = '1' and
                              ((i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000") or
                               (i_IDEX_RD = i_IFID_RS2 and i_IFID_RS2 /= "00000")))
                     else '0';

  -- Branch data hazard detection
  -- Occurs when a branch in ID stage depends on a result in EX stage
  -- We can forward from MEM and WB stages, but not from EX stage (timing)
  s_BranchDataHazard <= '1' when (i_Branch_ID = '1' and i_IDEX_RegWrite = '1' and
                                  ((i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000") or
                                   (i_IDEX_RD = i_IFID_RS2 and i_IFID_RS2 /= "00000")))
                        else '0';

  -- Jump data hazard detection (for JALR only)
  -- JALR reads RS1 to compute jump target, needs to stall if RS1 is in EX stage
  -- JAL doesn't read RS1 (immediate encoded in instruction), so no stall needed
  s_JumpDataHazard <= '1' when (i_JALR = '1' and i_IDEX_RegWrite = '1' and
                                (i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000"))
                      else '0';

  -- Combined data hazard signal
  s_DataHazard <= s_LoadUseHazard or s_BranchDataHazard or s_JumpDataHazard;

  -- Control hazard: any branch or jump that redirects PC
  s_ControlHazard <= i_Branch or i_Jump;

  -- Output logic - prioritize control hazard over data stalls
  -- When control hazard occurs, allow PC update to jump/branch target
  o_PCWrite <= not s_DataHazard or s_ControlHazard;

  -- IFID_Write: disable when stalling for data hazards
  o_IFID_Write <= not s_DataHazard;

  -- ControlMux: Insert NOP for data hazards only
  o_ControlMux <= s_DataHazard;

  -- Flush logic for hardware-scheduled pipeline:
  -- When branch/jump is detected in ID stage, the next sequential instruction
  -- has already been fetched and will latch into IFID on the next rising edge.
  -- We need to flush IFID immediately to prevent this wrong instruction from entering.
  -- The branch/jump itself continues through the pipeline (jumps write PC+4, branches are NOPs)
  o_IFID_Flush <= s_ControlHazard;  -- Flush immediately for both branches and jumps
  o_IDEX_Flush <= '0';  -- Never flush ID/EX for control hazards

end behavioral;