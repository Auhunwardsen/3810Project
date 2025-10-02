library ieee;
use ieee.std_logic_1164.all;

entity mux2t1 is
  port (
    a, b : in  std_logic_vector(31 downto 0); -- inputs
    sel  : in  std_logic;                      -- select
    y    : out std_logic_vector(31 downto 0)   -- output
  );
end entity;

architecture rtl of mux2t1 is
begin
  y <= a when sel = '0' else b;
end architecture;
