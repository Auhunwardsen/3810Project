-- sign_extender.vhd  (12 -> 32)
library ieee;
use ieee.std_logic_1164.all;

entity sign_extender is
  port (
    din  : in  std_logic_vector(11 downto 0);
    dout : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of sign_extender is
begin
  dout <= (31 downto 12 => din(11)) & din;  -- replicate sign bit
end architecture;

