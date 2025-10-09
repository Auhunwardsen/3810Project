library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_fetch is
end entity;

architecture sim of tb_fetch is
  -- DUT I/O
  signal s_CLK        : std_logic := '0';
  signal s_RST        : std_logic := '1';
  signal s_UseNextAdr : std_logic := '0';
  signal s_Stall      : std_logic := '0';
  signal s_NextAdr    : std_logic_vector(31 downto 0) := (others => '0');

  signal s_IMemAdr    : std_logic_vector(31 downto 0);
  signal s_IMemData   : std_logic_vector(31 downto 0) := (others => '0');

  signal s_PC         : std_logic_vector(31 downto 0);
  signal s_PCplus4    : std_logic_vector(31 downto 0);
  signal s_Instr      : std_logic_vector(31 downto 0);
  
  begin
    return a;
  end function;
begin
  -- 10 ns clock
  s_CLK <= not s_CLK after 5 ns;

  -- DUT
  DUT0 : entity work.fetch
    port map (
      i_CLK        => s_CLK,
      i_RST        => s_RST,
      i_UseNextAdr => s_UseNextAdr,
      i_Stall      => s_Stall,
      i_NextAdr    => s_NextAdr,
      o_IMemAdr    => s_IMemAdr,
      i_IMemData   => s_IMemData,
      o_PC         => s_PC,
      o_PCplus4    => s_PCplus4,
      o_Instr      => s_Instr
    );

  -- IMEM: instruction equals address
  s_IMemData <= addr_echo(s_IMemAdr);

  -- Stimulus + Expected Behavior (waves check)
  p_stim : process
  begin
    -- Hold reset for ~2.5 cycles
    s_RST <= '1';
    wait for 25 ns;
    s_RST <= '0';

    -- (1) Sequential for ~4 cycles: expect PC = 0x0, 0x4, 0x8, 0xC
    s_UseNextAdr <= '0'; s_Stall <= '0';
    wait for 40 ns;

    -- (2) Redirect to 0x40 for next cycle: expect next PC = 0x40, then 0x44, 0x48
    s_UseNextAdr <= '1'; s_NextAdr <= x"00000040";
    wait for 10 ns;  -- one rising edge triggers redirect
    s_UseNextAdr <= '0';
    wait for 30 ns;

    -- (3) Stall two cycles: expect PC holds for 2 cycles
    s_Stall <= '1';
    wait for 20 ns;
    s_Stall <= '0';

    -- (4) Redirect to 0x100, then sequential
    s_UseNextAdr <= '1'; s_NextAdr <= x"00000100";
    wait for 10 ns;
    s_UseNextAdr <= '0';
    wait for 30 ns;

    -- Done
    wait for 20 ns;
    
  end process;
end architecture;