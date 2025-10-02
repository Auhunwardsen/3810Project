-----------------------------------------------------------------------------
-- Entity: register_n.vhd  
-- Name: Austin Hunwardsen
-- Description: N-bit register using flip-flop
-- Date: 9/11/25
-----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity register_n is
  generic ( N : integer := 32 );
  port (
    i_CLK : in  std_logic;
    i_RST : in  std_logic;                         -- async, active-high (matches dffg)
    i_WE  : in  std_logic;                         -- write enable
    i_D   : in  std_logic_vector(N-1 downto 0);    -- data in
    o_Q   : out std_logic_vector(N-1 downto 0)     -- data out
  );
end entity register_n;

architecture structural of register_n is
  component dffg
    port (
      i_CLK : in  std_logic;
      i_RST : in  std_logic;
      i_WE  : in  std_logic;
      i_D   : in  std_logic;
      o_Q   : out std_logic
    );
  end component;

  signal s_q : std_logic_vector(N-1 downto 0);
begin
  gen_bits : for i in 0 to N-1 generate
  begin
    u_ff : dffg
      port map (
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => i_WE,     -- WE handled inside dffg
        i_D   => i_D(i),
        o_Q   => s_q(i)
      );
  end generate;

  o_Q <= s_q;
end architecture structural;
