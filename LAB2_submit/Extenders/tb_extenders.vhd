-- tb_extenders.vhd
library ieee;
use ieee.std_logic_1164.all;

entity tb_extenders is end entity;

architecture sim of tb_extenders is
  signal din12      : std_logic_vector(11 downto 0);
  signal dout_zero  : std_logic_vector(31 downto 0);
  signal dout_sign  : std_logic_vector(31 downto 0);
begin
  UZ: entity work.zero_extender port map(din => din12, dout => dout_zero);
  US: entity work.sign_extender port map(din => din12, dout => dout_sign);

  process
  begin
    din12 <= x"7FF";  wait for 10 ns; -- +2047: both 000007FF
    din12 <= x"800";  wait for 10 ns; -- -2048: zero 00000800, sign FFFFF800
    din12 <= x"0FF";  wait for 10 ns; -- +255 : both 000000FF
    wait;
  end process;
end architecture;

