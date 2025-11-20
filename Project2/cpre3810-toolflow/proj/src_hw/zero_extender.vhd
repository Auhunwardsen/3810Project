-- zero_extender.vhd  (12 -> 32)
library ieee;
use ieee.std_logic_1164.all;

entity zero_extender is
  port (
    din  : in  std_logic_vector(11 downto 0);
    dout : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of zero_extender is
begin
  dout <= (31 downto 12 => '0') & din;
end architecture;

