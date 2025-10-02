library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapath is end entity;
architecture sim of tb_datapath is
  constant T : time := 10 ns;

  signal clk, rst, RegWrite, nAdd_Sub, ALUSrc : std_logic := '0';
  signal rs1, rs2, rd : std_logic_vector(4 downto 0) := (others=>'0');
  signal imm12        : std_logic_vector(11 downto 0) := (others=>'0');
  signal r1, r2, y    : std_logic_vector(31 downto 0);

begin
  -- DUT
  UUT: entity work.datapath
    port map(
      i_clk      => clk,
      i_rst      => rst,
      i_RegWrite => RegWrite,
      i_nAdd_Sub => nAdd_Sub,
      i_ALUSrc   => ALUSrc,
      i_rs1      => rs1,
      i_rs2      => rs2,
      i_rd       => rd,
      i_imm12    => imm12,
      o_rdata1   => r1,
      o_rdata2   => r2,
      o_aluY     => y
    );

  -- clock
  clk <= not clk after T/2;

  -- stimulus (each instruction completes in one rising clock edge)
process
begin
  ----------------------------------------------------------------------
  -- reset
  ----------------------------------------------------------------------
  rst       <= '1';
  RegWrite  <= '0';
  ALUSrc    <= '0';
  nAdd_Sub  <= '0';
  rs1       <= "00000";        -- x0
  rs2       <= "00000";
  rd        <= "00000";
  imm12     <= (others => '0');
  wait for 3*T;
  rst <= '0';
  wait until rising_edge(clk);  -- start clean on a posedge

  ----------------------------------------------------------------------
  -- addi x1, zero, 1
  ----------------------------------------------------------------------
  rs1       <= "00000";  -- zero
  rd        <= "00001";  -- x1
  imm12     <= std_logic_vector(to_signed(1,12));
  ALUSrc    <= '1';
  nAdd_Sub  <= '0';
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x2, zero, 2
  rd        <= "00010";  imm12 <= std_logic_vector(to_signed(2,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x3, zero, 3
  rd        <= "00011";  imm12 <= std_logic_vector(to_signed(3,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x4, zero, 4
  rd        <= "00100";  imm12 <= std_logic_vector(to_signed(4,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x5, zero, 5
  rd        <= "00101";  imm12 <= std_logic_vector(to_signed(5,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x6, zero, 6
  rd        <= "00110";  imm12 <= std_logic_vector(to_signed(6,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x7, zero, 7
  rd        <= "00111";  imm12 <= std_logic_vector(to_signed(7,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x8, zero, 8
  rd        <= "01000";  imm12 <= std_logic_vector(to_signed(8,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x9, zero, 9
  rd        <= "01001";  imm12 <= std_logic_vector(to_signed(9,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- addi x10, zero, 10
  rd        <= "01010";  imm12 <= std_logic_vector(to_signed(10,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  ----------------------------------------------------------------------
  -- add x11, x1, x2
  ----------------------------------------------------------------------
  ALUSrc    <= '0';      -- use rs2
  nAdd_Sub  <= '0';      -- add
  rs1       <= "00001";  -- x1
  rs2       <= "00010";  -- x2
  rd        <= "01011";  -- x11
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- sub x12, x11, x3
  nAdd_Sub  <= '1';      -- subtract
  rs1       <= "01011";  -- x11
  rs2       <= "00011";  -- x3
  rd        <= "01100";  -- x12
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- add x13, x12, x4
  nAdd_Sub  <= '0';
  rs1       <= "01100";  -- x12
  rs2       <= "00100";  -- x4
  rd        <= "01101";  -- x13
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- sub x14, x13, x5
  nAdd_Sub  <= '1';
  rs1       <= "01101";  -- x13
  rs2       <= "00101";  -- x5
  rd        <= "01110";  -- x14
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- add x15, x14, x6
  nAdd_Sub  <= '0';
  rs1       <= "01110";  -- x14
  rs2       <= "00110";  -- x6
  rd        <= "01111";  -- x15
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- sub x16, x15, x7
  nAdd_Sub  <= '1';
  rs1       <= "01111";  -- x15
  rs2       <= "00111";  -- x7
  rd        <= "10000";  -- x16
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- add x17, x16, x8
  nAdd_Sub  <= '0';
  rs1       <= "10000";  -- x16
  rs2       <= "01000";  -- x8
  rd        <= "10001";  -- x17
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- sub x18, x17, x9
  nAdd_Sub  <= '1';
  rs1       <= "10001";  -- x17
  rs2       <= "01001";  -- x9
  rd        <= "10010";  -- x18
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  -- add x19, x18, x10
  nAdd_Sub  <= '0';
  rs1       <= "10010";  -- x18
  rs2       <= "01010";  -- x10
  rd        <= "10011";  -- x19
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  ----------------------------------------------------------------------
  -- addi x20, zero, -35
  ----------------------------------------------------------------------
  ALUSrc    <= '1';
  nAdd_Sub  <= '0';
  rs1       <= "00000";  -- zero
  rd        <= "10100";  -- x20
  imm12     <= std_logic_vector(to_signed(-35,12));
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0'; wait until falling_edge(clk);

  ----------------------------------------------------------------------
  -- add x21, x19, x20
  ----------------------------------------------------------------------
  ALUSrc    <= '0';
  nAdd_Sub  <= '0';
  rs1       <= "10011";  -- x19
  rs2       <= "10100";  -- x20
  rd        <= "10101";  -- x21
  RegWrite  <= '1';
  wait until rising_edge(clk); RegWrite <= '0';

  ----------------------------------------------------------------------
  -- done
  ----------------------------------------------------------------------
  wait;
end process;

end architecture;

