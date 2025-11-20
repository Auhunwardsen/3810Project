-- 3-to-1 Multiplexer for Forwarding
-- Used to select between register file data and forwarded data
library IEEE;
use IEEE.std_logic_1164.all;

entity mux3t1_n is
  generic(N : integer := 32);
  port(
    i_S   : in  std_logic_vector(1 downto 0);  -- 2-bit select signal
    i_D0  : in  std_logic_vector(N-1 downto 0);  -- 00: register file data
    i_D1  : in  std_logic_vector(N-1 downto 0);  -- 01: MEM/WB forwarded data
    i_D2  : in  std_logic_vector(N-1 downto 0);  -- 10: EX/MEM forwarded data
    o_O   : out std_logic_vector(N-1 downto 0)
  );
end mux3t1_n;

architecture dataflow of mux3t1_n is
begin
  with i_S select
    o_O <= i_D0 when "00",
           i_D1 when "01", 
           i_D2 when "10",
           i_D0 when others;  -- Default case
end dataflow;