library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_regfile is end entity;

architecture sim of tb_regfile is
  constant T : time := 10 ns;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '0';
  signal i_RegWrite : std_logic := '0';
  signal i_rd       : std_logic_vector(4 downto 0) := (others => '0');
  signal i_rs1      : std_logic_vector(4 downto 0) := (others => '0');
  signal i_rs2      : std_logic_vector(4 downto 0) := (others => '0');
  signal i_WriteData: std_logic_vector(31 downto 0) := (others => '0');
  signal o_ReadData1: std_logic_vector(31 downto 0);
  signal o_ReadData2: std_logic_vector(31 downto 0);
begin
  -- DUT
  UUT: entity work.regfile
    port map(
      i_clk    => clk,
      i_rst    => rst,
      i_we     => i_RegWrite,
      i_rd     => i_rd,
      i_rs1    => i_rs1,
      i_rs2    => i_rs2,
      i_wdata  => i_WriteData,
      o_rdata1 => o_ReadData1,
      o_rdata2 => o_ReadData2
    );


  clk <= not clk after T/2;


  process
  begin
    -- reset
    rst <= '1'; i_RegWrite <= '0';
    i_rd <= (others=>'0'); i_rs1 <= (others=>'0'); i_rs2 <= (others=>'0');
    i_WriteData <= (others=>'0');
    wait for 3*T;
    
    wait until falling_edge(clk);
    rst <= '0';
    wait for T;

    -- 1) write x5 = 0xDEADBEEF
    i_rd       <= std_logic_vector(to_unsigned(5,5));
    i_WriteData<= x"DEADBEEF";
    i_RegWrite <= '1';
    wait until rising_edge(clk);
    i_RegWrite <= '0';

    -- read back on rs1=5 (and show x0 on rs2=0)
    i_rs1 <= std_logic_vector(to_unsigned(5,5));
    i_rs2 <= std_logic_vector(to_unsigned(0,5));
    wait for T;

    -- 2) attempt write x0 (should be ignored because we dont want to edit that)
    i_rd       <= std_logic_vector(to_unsigned(0,5));
    i_WriteData<= x"FFFFFFFF";
    i_RegWrite <= '1';
    wait until rising_edge(clk);
    i_RegWrite <= '0';
    -- read rs1=0, rs2=5 (x0 must be 0; x5 still DEADBEEF)
    i_rs1 <= std_logic_vector(to_unsigned(0,5));
    i_rs2 <= std_logic_vector(to_unsigned(5,5));
    wait for T;

    -- 3) write x7 = 0x12345678, then read
    i_rd       <= std_logic_vector(to_unsigned(7,5));
    i_WriteData<= x"12345678";
    i_RegWrite <= '1';
    wait until rising_edge(clk);
    i_RegWrite <= '0';
    -- read rs1=7, rs2=5
    i_rs1 <= std_logic_vector(to_unsigned(7,5));
    i_rs2 <= std_logic_vector(to_unsigned(5,5));
    wait for T;

    -- 4) back-to-back writes x10 and x11, then read both
    i_rd       <= std_logic_vector(to_unsigned(10,5));
    i_WriteData<= x"A5A5A5A5";
    i_RegWrite <= '1';
    wait until rising_edge(clk);
    
    i_rd       <= std_logic_vector(to_unsigned(11,5));
    i_WriteData<= x"5A5A5A5A";
    wait until rising_edge(clk);
    i_RegWrite <= '0';
    -- read rs1=10, rs2=11
    i_rs1 <= std_logic_vector(to_unsigned(10,5));
    i_rs2 <= std_logic_vector(to_unsigned(11,5));
    wait for T;

    
    i_rs1 <= std_logic_vector(to_unsigned(0,5));  
    i_rs2 <= std_logic_vector(to_unsigned(31,5));  
    wait for T;

    wait;
  end process;
end architecture;
