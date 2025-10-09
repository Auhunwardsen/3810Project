library ieee;
use ieee.std_logic_1164.all;

entity register_n is
  generic ( N : integer := 32 );
  port (
    i_CLK : in  std_logic;
    i_RST : in  std_logic;                         -- async, active-high reset
    i_D   : in  std_logic_vector(N-1 downto 0);    -- data in
    o_Q   : out std_logic_vector(N-1 downto 0)     -- data out
  );
end entity;

architecture rtl of register_n is
  signal s_Q : std_logic_vector(N-1 downto 0);
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      s_Q <= (others => '0');
    elsif rising_edge(i_CLK) then
      s_Q <= i_D;
    end if;
  end process;

  o_Q <= s_Q;
end architecture;