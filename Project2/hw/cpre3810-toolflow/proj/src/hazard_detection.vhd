-- Hazard Detection Unit
-- Detects data and control hazards and generates stall/flush signals
library IEEE;
use IEEE.std_logic_1164.all;

entity hazard_detection is
  port(
    -- From ID/EX register
    i_IDEX_MemRead  : in std_logic;
    i_IDEX_RD       : in std_logic_vector(4 downto 0);
    
    -- From IF/ID register  
    i_IFID_RS1      : in std_logic_vector(4 downto 0);
    i_IFID_RS2      : in std_logic_vector(4 downto 0);
    
    -- Control hazard signals
    i_Branch        : in std_logic;
    i_Jump          : in std_logic;
    
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
  signal s_ControlHazard : std_logic;
begin
  
  -- Load-use hazard detection
  -- Occurs when current instruction uses result of previous load instruction
  s_LoadUseHazard <= '1' when (i_IDEX_MemRead = '1' and 
                              ((i_IDEX_RD = i_IFID_RS1 and i_IFID_RS1 /= "00000") or
                               (i_IDEX_RD = i_IFID_RS2 and i_IFID_RS2 /= "00000")))
                     else '0';
  
  -- Control hazard detection  
  s_ControlHazard <= i_Branch or i_Jump;
  
  -- Output logic
  o_PCWrite <= not s_LoadUseHazard;  -- Stall PC if load-use hazard
  o_IFID_Write <= not s_LoadUseHazard;  -- Stall IF/ID if load-use hazard
  o_ControlMux <= s_LoadUseHazard;  -- Insert NOP if load-use hazard
  
  -- Flush pipeline stages on control hazards
  o_IFID_Flush <= s_ControlHazard;
  o_IDEX_Flush <= s_ControlHazard;
  
end behavioral;