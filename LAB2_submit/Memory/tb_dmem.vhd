library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_dmem is
end tb_dmem;

architecture sim of tb_dmem is
  constant T : time := 10 ns;

  signal clk  : std_logic := '0';
  signal addr : std_logic_vector(9 downto 0) := (others => '0');  -- 10 bits
  signal data : std_logic_vector(31 downto 0) := (others => '0');
  signal we   : std_logic := '0';
  signal q    : std_logic_vector(31 downto 0);
begin
  dmem : entity work.mem
    port map (
      clk  => clk,
      addr => addr,
      data => data,
      we   => we,
      q    => q
    );

  clk <= not clk after T/2;

  stim_proc : process
  begin
    -- 1) read 0x000..0x009
    for i in 0 to 9 loop
      addr <= std_logic_vector(to_unsigned(i, addr'length));  -- length = 10
      we   <= '0';
      wait for T;
    end loop;

    -- 2) write to 0x100..0x109
    for i in 0 to 9 loop
      addr <= std_logic_vector(to_unsigned(i + 16#100#, addr'length));  -- 256..265
      data <= q;
      we   <= '1';
      wait for T;
      we   <= '0';
      wait for T;
    end loop;

    -- 3) read back 0x100..0x109
    for i in 0 to 9 loop
      addr <= std_logic_vector(to_unsigned(i + 16#100#, addr'length));
      we   <= '0';
      wait for T;
    end loop;

    wait;
  end process;
end sim;


