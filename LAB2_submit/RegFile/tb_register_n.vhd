-----------------------------------------------------------------------------
-- Entity: tb_register_n.vhd  
-- Name: Austin Hunwardsen
-- Description: N-bit register using flip-flop Testbench for file register_n.vhd
-- Date: 9/11/25
-----------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_register_n is
end entity;

architecture sim of tb_register_n is
  constant C_CLK : time := 10 ns;

  signal clk : std_logic := '0';
  signal rst : std_logic := '0';
  signal we  : std_logic := '0';

  signal d   : std_logic_vector(31 downto 0) := (others => '0');
  signal q   : std_logic_vector(31 downto 0);
begin
  -- DUT: 32-bit instance of your generic register
  UUT: entity work.register_n
    generic map ( N => 32 )
    port map (
      i_CLK => clk,
      i_RST => rst,
      i_WE  => we,
      i_D   => d,
      o_Q   => q
    );

  -- 100 MHz clock
  clk <= not clk after C_CLK/2;

  -- Stimulus
  process
  begin
    -- async reset high, then low
    rst <= '1'; we <= '0'; d <= (others => '0');
    wait for 3*C_CLK;
    rst <= '0';
    wait for C_CLK;

    -- Write #1 on rising edge: 0xA5A5A5A5
    d  <= x"A5A5A5A5";
    we <= '1';
    wait until rising_edge(clk);   -- capture happens here
    we <= '0';
    wait for 2*C_CLK;              -- hold (q should remain A5A5A5A5)

    -- Write #2 on rising edge: 0x5A5A5A5A
    d  <= x"5A5A5A5A";
    we <= '1';
    wait until rising_edge(clk);
    we <= '0';
    wait for 3*C_CLK;

    -- done
    wait;
  end process;

  -- Optional: simple checks (won't stop sim, but useful in transcript)
  process
  begin
    -- wait until after first write edge
    wait for 5*C_CLK;
    assert q = x"A5A5A5A5"
      report "Expected q=A5A5A5A5 after write #1" severity note;

    wait for 3*C_CLK;
    assert q = x"5A5A5A5A"
      report "Expected q=5A5A5A5A after write #2" severity note;

    wait;
  end process;
end architecture;

