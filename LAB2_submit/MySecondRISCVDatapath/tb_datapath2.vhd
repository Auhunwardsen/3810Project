library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_datapath2 is
end entity;

architecture sim of tb_datapath2 is
  constant T : time := 10 ns;             -- 100 MHz

  -- Control / inputs to your datapath2 (rename if your ports differ)
  signal clk, rst               : std_logic := '0';
  signal RegWrite               : std_logic := '0';
  signal nAdd_Sub               : std_logic := '0';
  signal ALUSrc                 : std_logic := '0';
  signal MemWrite               : std_logic := '0';
  signal MemToReg               : std_logic := '0';
  signal rs1, rs2, rd           : std_logic_vector(4 downto 0)  := (others=>'0');
  signal imm12                  : std_logic_vector(11 downto 0) := (others=>'0');

  
begin
  -- clock
  clk <= not clk after T/2;

  -- DUT
  UUT: entity work.datapath2
    port map (
      i_clk      => clk,
      i_rst      => rst,
      i_RegWrite => RegWrite,
      i_nAdd_Sub => nAdd_Sub,
      i_ALUSrc   => ALUSrc,
      i_MemWrite => MemWrite,
      i_MemToReg => MemToReg,
      i_rs1      => rs1,
      i_rs2      => rs2,
      i_rd       => rd,
      i_imm12    => imm12
     
    );

  -----------------------------------------------------------------------------
  -- Stimulus: one statement per instruction, 1 cycle each
  -----------------------------------------------------------------------------
  stim: process
  begin
    ---------------------------------------------------------------------------
    -- Reset
    ---------------------------------------------------------------------------
    rst <= '1';
    RegWrite <= '0'; MemWrite <= '0'; MemToReg <= '0';
    wait for 3*T; rst <= '0'; wait for T;

    ---------------------------------------------------------------------------
    -- addi x25, x25, 0    ; x25 = &A   (word index 0)
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(25,5));  -- rs1 = x25
    rd  <= std_logic_vector(to_unsigned(25,5));  -- rd  = x25
    imm12  <= std_logic_vector(to_signed(0,12));
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '0';
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    ---------------------------------------------------------------------------
    -- addi x26, x26, 256  ; x26 = &B   (word index 256)
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(26,5));
    rd  <= std_logic_vector(to_unsigned(26,5));
    imm12  <= std_logic_vector(to_signed(256,12));
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '0';
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    ---------------------------------------------------------------------------
    -- lw x1, 0(x25)       ; A[0] -> x1   (word offset 0)
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(25,5));
    rd  <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(0,12));
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '1';          -- writeback from MEM
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    ---------------------------------------------------------------------------
    -- lw x2, 4(x25)       ; A[1] -> x2   (byte +4 => word +1)
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(25,5));
    rd  <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(1,12));
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '1';
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    ---------------------------------------------------------------------------
    -- add x1, x1, x2      ; x1 = x1 + x2
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(1,5));
    rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5));
    ALUSrc <= '0'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '0';           -- write ALU result
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    ---------------------------------------------------------------------------
    -- sw x1, 0(x26)       ; B[0] = x1
    ---------------------------------------------------------------------------
    rs1 <= std_logic_vector(to_unsigned(26,5));  -- base
    rs2 <= std_logic_vector(to_unsigned(1,5));   -- data
    imm12  <= std_logic_vector(to_signed(0,12)); -- word offset
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemToReg <= '0'; RegWrite <= '0';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    -- lw x2, 8(x25) ; A[2] -> x2 (word +2)
    rs1 <= std_logic_vector(to_unsigned(25,5));
    rd  <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(2,12));
    ALUSrc <= '1'; nAdd_Sub <= '0';
    MemWrite <= '0'; MemToReg <= '1';
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    -- add x1, x1, x2
    rs1 <= std_logic_vector(to_unsigned(1,5)); rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5));
    ALUSrc <= '0'; nAdd_Sub <= '0';
    MemToReg <= '0'; MemWrite <= '0';
    RegWrite <= '1';  wait until rising_edge(clk);  RegWrite <= '0';

    -- sw x1, 4(x26) ; B[1] (word +1)
    rs1 <= std_logic_vector(to_unsigned(26,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(1,12));
    ALUSrc <= '1'; MemWrite <= '1'; RegWrite <= '0';
    wait until rising_edge(clk); MemWrite <= '0';

    -- lw x2, 12(x25) ; A[3] (word +3)
    rs1 <= std_logic_vector(to_unsigned(25,5)); rd <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(3,12)); ALUSrc <= '1'; MemToReg <= '1';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- add x1, x1, x2
    rs1 <= std_logic_vector(to_unsigned(1,5)); rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5)); ALUSrc <= '0'; MemToReg <= '0';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- sw x1, 8(x26) ; B[2] (word +2)
    rs1 <= std_logic_vector(to_unsigned(26,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(2,12)); ALUSrc <= '1';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    -- lw x2, 16(x25) ; A[4] (word +4)
    rs1 <= std_logic_vector(to_unsigned(25,5)); rd <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(4,12)); ALUSrc <= '1'; MemToReg <= '1';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- add x1, x1, x2
    rs1 <= std_logic_vector(to_unsigned(1,5)); rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5)); ALUSrc <= '0'; MemToReg <= '0';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- sw x1, 12(x26) ; B[3] (word +3)
    rs1 <= std_logic_vector(to_unsigned(26,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(3,12)); ALUSrc <= '1';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    -- lw x2, 20(x25) ; A[5] (word +5)
    rs1 <= std_logic_vector(to_unsigned(25,5)); rd <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(5,12)); ALUSrc <= '1'; MemToReg <= '1';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- add x1, x1, x2
    rs1 <= std_logic_vector(to_unsigned(1,5)); rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5)); ALUSrc <= '0'; MemToReg <= '0';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- sw x1, 16(x26) ; B[4] (word +4)
    rs1 <= std_logic_vector(to_unsigned(26,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(4,12)); ALUSrc <= '1';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    -- lw x2, 24(x25) ; A[6] (word +6)
    rs1 <= std_logic_vector(to_unsigned(25,5)); rd <= std_logic_vector(to_unsigned(2,5));
    imm12  <= std_logic_vector(to_signed(6,12)); ALUSrc <= '1'; MemToReg <= '1';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- add x1, x1, x2
    rs1 <= std_logic_vector(to_unsigned(1,5)); rs2 <= std_logic_vector(to_unsigned(2,5));
    rd  <= std_logic_vector(to_unsigned(1,5)); ALUSrc <= '0';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- addi x27, x27, 64  ; &B[64]  (512 bytes -> 64 words)
    rs1 <= std_logic_vector(to_unsigned(27,5)); rd <= std_logic_vector(to_unsigned(27,5));
    imm12  <= std_logic_vector(to_signed(64,12)); ALUSrc <= '1';
    RegWrite <= '1'; wait until rising_edge(clk); RegWrite <= '0';

    -- sw x1, -4(x27) ; store x1 at B[63]  (-4 bytes -> -1 word)
    rs1 <= std_logic_vector(to_unsigned(27,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(-1,12)); ALUSrc <= '1';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    -- sw x1, -4(x27) ; again
    rs1 <= std_logic_vector(to_unsigned(27,5)); rs2 <= std_logic_vector(to_unsigned(1,5));
    imm12  <= std_logic_vector(to_signed(-1,12)); ALUSrc <= '1';
    MemWrite <= '1'; wait until rising_edge(clk); MemWrite <= '0';

    report "Done with Part 7 program.";
    wait;
  end process;
end architecture;

