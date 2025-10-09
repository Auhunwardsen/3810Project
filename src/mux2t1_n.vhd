library ieee;
use ieee.std_logic_1164.all;

-- Generic N-bit 2:1 multiplexer
entity mux2t1_n is
  generic (N : integer := 32);
  port (
    i_S  : in  std_logic;                         -- select
    i_D0 : in  std_logic_vector(N-1 downto 0);   -- input 0
    i_D1 : in  std_logic_vector(N-1 downto 0);   -- input 1
    o_O  : out std_logic_vector(N-1 downto 0)    -- output
  );
end entity;

architecture rtl of mux2t1_n is
begin
  o_O <= i_D1 when i_S = '1' else i_D0;
end architecture;