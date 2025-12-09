-- Hazard Detection Unit
-- Detects data and control hazards and generates stall/flush signals
library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detection is
  port(
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
  signal s_ControlHazard : std_logic;
  signal s_DataHazard : std_logic;
  signal s_Jump_d : std_logic := '0';
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

  -- Combined data hazard signal
  s_DataHazard <= s_LoadUseHazard or s_BranchDataHazard;

  -- Control hazard: any branch or jump that redirects PC
  s_ControlHazard <= i_Branch or i_Jump;

  -- Delay jump flush by one cycle
  process (i_Jump, i_Branch, i_Branch_ID, i_IDEX_MemRead, i_IDEX_RD, i_IDEX_RegWrite, i_IFID_RS1, i_IFID_RS2, i_CLK)
  begin
    if rising_edge(i_CLK) then
      s_Jump_d <= i_Jump;
    end if;
  end process;

  -- Output logic - prioritize control hazard over data stalls
  -- When control hazard occurs, allow PC update to jump/branch target
  o_PCWrite <= not s_DataHazard or s_ControlHazard;
  o_IFID_Write <= not s_DataHazard;  -- Disable write only for data hazards
  o_ControlMux <= s_DataHazard;  -- Insert NOP for data hazards only

  -- Nuanced flush: flush both IF/ID and ID/EX on taken branch, only IF/ID on jump (delayed)
  -- i_Branch = (branch taken), s_Jump_d = (JAL/JALR delayed)
  o_IFID_Flush <= i_Branch or s_Jump_d;
  o_IDEX_Flush <= i_Branch;  -- Only flush ID/EX for taken branches, not for jumps

end behavioral;