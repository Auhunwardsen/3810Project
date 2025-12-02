library IEEE;
use IEEE.std_logic_1164.all;

entity ifid_reg is
  port (
    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;
    i_WE        : in  std_logic;
    i_Flush     : in  std_logic;
    i_PC        : in  std_logic_vector(31 downto 0);
    i_PCPlus4   : in  std_logic_vector(31 downto 0);
    i_Inst      : in  std_logic_vector(31 downto 0);
    o_PC        : out std_logic_vector(31 downto 0);
    o_PCPlus4   : out std_logic_vector(31 downto 0);
    o_Inst      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture behavioral of ifid_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      o_PC      <= (others => '0');
      o_PCPlus4 <= (others => '0');
      o_Inst    <= (others => '0');
    elsif rising_edge(i_CLK) then
      if i_Flush = '1' then
        o_PC      <= (others => '0');
        o_PCPlus4 <= (others => '0');
        o_Inst    <= (others => '0');
      elsif i_WE = '1' then
        o_PC      <= i_PC;
        o_PCPlus4 <= i_PCPlus4;
        o_Inst    <= i_Inst;
      end if;
    end if;
  end process;
end architecture;