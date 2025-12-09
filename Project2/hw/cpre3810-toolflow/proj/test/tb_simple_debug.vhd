-------------------------------------------------------------------------
-- Simple Debug Testbench for JALR Issue
-- Uses only standard ports - no hierarchical signal access
-- Run with jalr_1.s test program
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_simple_debug is
end tb_simple_debug;

architecture mixed of tb_simple_debug is

constant gCLK_HPER : time := 10 ns;
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N : integer := 32;

component RISCV_processor is
  generic (N : integer);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0));
end component;

signal CLK, reset : std_logic := '0';
signal reset_done : std_logic := '0';
signal alu_out : std_logic_vector(N-1 downto 0);

begin

  MyRiscv: RISCV_processor
  generic map(N => N)
  port map(
    iCLK      => CLK,
    iRST      => reset,
    iInstLd   => '0',
    iInstAddr => (others => '0'),
    iInstExt  => (others => '0'),
    oALUOut   => alu_out);

  -- Clock generation
  P_CLK: process
  begin
    CLK <= '1';
    wait for gCLK_HPER;
    CLK <= '0';
    wait for gCLK_HPER;
  end process;

  -- Reset
  P_RST: process
  begin
    reset <= '0';
    wait for gCLK_HPER/2;
    reset <= '1';
    wait for gCLK_HPER*2;
    reset <= '0';
    reset_done <= '1';
    wait;
  end process;

  -- Simple monitoring process
  P_MONITOR: process
  begin
    wait until reset_done = '1';

    -- Wait for test to complete (50 cycles should be enough for jalr_1)
    for i in 1 to 50 loop
      wait until rising_edge(CLK);
      report "Cycle " & integer'image(i) & " - ALU Out: " &
             integer'image(to_integer(unsigned(alu_out)));
    end loop;

    report "Test completed after 50 cycles";
    wait;
  end process;

end mixed;
