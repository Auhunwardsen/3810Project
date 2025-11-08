library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- N-bit adder (used for PC+4)
entity adder_n is
  generic (N : integer := 32);
  port (
    iA   : in  std_logic_vector(N-1 downto 0);
    iB   : in  std_logic_vector(N-1 downto 0);
    oSum : out std_logic_vector(N-1 downto 0)
  );
end entity;

architecture rtl of adder_n is
begin
  oSum <= std_logic_vector(unsigned(iA) + unsigned(iB));
end architecture;