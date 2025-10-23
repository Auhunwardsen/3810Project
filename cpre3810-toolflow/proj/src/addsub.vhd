library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity addsub is
  port (
    a, b    : in  std_logic_vector(31 downto 0); -- operands
    nAddSub : in  std_logic;                     -- 0=add, 1=sub
    result  : out std_logic_vector(31 downto 0)  -- output
  );
end entity;

architecture rtl of addsub is
begin
  process(a, b, nAddSub)
  begin
    if nAddSub = '0' then
      result <= std_logic_vector(signed(a) + signed(b));
    else
      result <= std_logic_vector(signed(a) - signed(b));
    end if;
  end process;
end architecture;
