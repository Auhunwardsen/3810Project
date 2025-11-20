-- Pipeline Register: IF/ID Stage
-- Stores instruction and PC+4 from fetch stage
library IEEE;
use IEEE.std_logic_1164.all;

entity IFID_reg is
  port(
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_WE      : in  std_logic;  -- Write enable (for stalling)
    i_flush   : in  std_logic;  -- Flush signal (for control hazards)
    
    -- Inputs from IF stage
    i_PC      : in  std_logic_vector(31 downto 0);
    i_PCplus4 : in  std_logic_vector(31 downto 0); 
    i_Instr   : in  std_logic_vector(31 downto 0);
    
    -- Outputs to ID stage
    o_PC      : out std_logic_vector(31 downto 0);
    o_PCplus4 : out std_logic_vector(31 downto 0);
    o_Instr   : out std_logic_vector(31 downto 0)
  );
end IFID_reg;

architecture behavioral of IFID_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      o_PC      <= (others => '0');
      o_PCplus4 <= (others => '0');
      o_Instr   <= (others => '0');
    elsif rising_edge(i_CLK) then
      if i_flush = '1' then
        o_PC      <= (others => '0');
        o_PCplus4 <= (others => '0');
        o_Instr   <= (others => '0');
      elsif i_WE = '1' then
        o_PC      <= i_PC;
        o_PCplus4 <= i_PCplus4;
        o_Instr   <= i_Instr;
      end if;
    end if;
  end process;
end behavioral;