-------------------------------------------------------------------------
-- Testbench for 5-Stage Pipelined RISC-V Processor
-- Tests each pipeline stage and monitors internal signals
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
library std;
use std.textio.all;

library work;
use work.RISCV_types.all;

entity tb_pipeline is
  generic(gCLK_HPER : time := 10 ns);
end tb_pipeline;

architecture behavior of tb_pipeline is

  -- Clock period
  constant cCLK_PER : time := gCLK_HPER * 2;

  component RISCV_Processor is
    port(iCLK            : in std_logic;
         iRST            : in std_logic;
         iInstLd         : in std_logic;
         iInstAddr       : in std_logic_vector(31 downto 0);
         iInstExt        : in std_logic_vector(31 downto 0);
         oALUOut         : out std_logic_vector(31 downto 0));
  end component;

  -- Clock and reset signals
  signal s_CLK : std_logic := '0';
  signal s_RST : std_logic := '0';
  
  -- Instruction loading signals
  signal s_InstLd   : std_logic := '0';
  signal s_InstAddr : std_logic_vector(31 downto 0) := (others => '0');
  signal s_InstExt  : std_logic_vector(31 downto 0) := (others => '0');
  
  -- Output signal
  signal s_ALUOut : std_logic_vector(31 downto 0);
  
  -- Test control
  signal s_TestComplete : boolean := false;
  signal s_TestNum : integer := 0;

begin

  DUT: RISCV_Processor
    port map(
      iCLK      => s_CLK,
      iRST      => s_RST,
      iInstLd   => s_InstLd,
      iInstAddr => s_InstAddr,
      iInstExt  => s_InstExt,
      oALUOut   => s_ALUOut
    );

  -- Clock generation
  P_CLK: process
  begin
    if not s_TestComplete then
      s_CLK <= '0';
      wait for gCLK_HPER;
      s_CLK <= '1';
      wait for gCLK_HPER;
    else
      wait;
    end if;
  end process;

  -- Test stimulus
  P_TEST: process
    
    -- Helper procedure to load an instruction
    procedure load_instruction(
      addr : in integer;
      inst : in std_logic_vector(31 downto 0)
    ) is
    begin
      s_InstLd <= '1';
      s_InstAddr <= std_logic_vector(to_unsigned(addr, 32));
      s_InstExt <= inst;
      wait for cCLK_PER;
      s_InstLd <= '0';
    end procedure;
    
    -- Helper to wait N cycles
    procedure wait_cycles(n : in integer) is
    begin
      for i in 0 to n-1 loop
        wait for cCLK_PER;
      end loop;
    end procedure;
    
    -- Helper to create R-type instruction
    function r_type(funct7 : std_logic_vector(6 downto 0);
                    rs2    : std_logic_vector(4 downto 0);
                    rs1    : std_logic_vector(4 downto 0);
                    funct3 : std_logic_vector(2 downto 0);
                    rd     : std_logic_vector(4 downto 0);
                    opcode : std_logic_vector(6 downto 0)) 
                    return std_logic_vector is
    begin
      return funct7 & rs2 & rs1 & funct3 & rd & opcode;
    end function;
    
    -- Helper to create I-type instruction
    function i_type(imm    : std_logic_vector(11 downto 0);
                    rs1    : std_logic_vector(4 downto 0);
                    funct3 : std_logic_vector(2 downto 0);
                    rd     : std_logic_vector(4 downto 0);
                    opcode : std_logic_vector(6 downto 0))
                    return std_logic_vector is
    begin
      return imm & rs1 & funct3 & rd & opcode;
    end function;
    
    -- Helper to create S-type instruction
    function s_type(imm11_5 : std_logic_vector(6 downto 0);
                    rs2     : std_logic_vector(4 downto 0);
                    rs1     : std_logic_vector(4 downto 0);
                    funct3  : std_logic_vector(2 downto 0);
                    imm4_0  : std_logic_vector(4 downto 0);
                    opcode  : std_logic_vector(6 downto 0))
                    return std_logic_vector is
    begin
      return imm11_5 & rs2 & rs1 & funct3 & imm4_0 & opcode;
    end function;
    
    -- Helper to create B-type instruction
    function b_type(imm12   : std_logic;
                    imm10_5 : std_logic_vector(5 downto 0);
                    rs2     : std_logic_vector(4 downto 0);
                    rs1     : std_logic_vector(4 downto 0);
                    funct3  : std_logic_vector(2 downto 0);
                    imm4_1  : std_logic_vector(3 downto 0);
                    imm11   : std_logic;
                    opcode  : std_logic_vector(6 downto 0))
                    return std_logic_vector is
    begin
      return imm12 & imm10_5 & rs2 & rs1 & funct3 & imm4_1 & imm11 & opcode;
    end function;
    
  begin
    report "========================================";
    report "Starting Pipeline Testbench";
    report "========================================";
    
    -- Reset processor
    s_RST <= '1';
    wait_cycles(2);
    s_RST <= '0';
    wait_cycles(1);
    
    report "Loading test program into instruction memory...";
    
    -- ========================================
    -- TEST 1: Simple R-type instruction sequence
    -- ========================================
    s_TestNum <= 1;
    report "TEST 1: R-type instructions with NOPs";
    
    -- Address 0: addi x1, x0, 5  (x1 = 5)
    load_instruction(0, i_type(
      imm    => x"005",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00001",
      opcode => "0010011"
    ));
    
    -- Address 4: nop (addi x0, x0, 0)
    load_instruction(4, i_type(
      imm    => x"000",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00000",
      opcode => "0010011"
    ));
    
    -- Address 8: nop
    load_instruction(8, i_type(
      imm    => x"000",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00000",
      opcode => "0010011"
    ));
    
    -- Address 12: add x2, x1, x1  (x2 = 10)
    load_instruction(12, r_type(
      funct7 => "0000000",
      rs2    => "00001",
      rs1    => "00001",
      funct3 => "000",
      rd     => "00010",
      opcode => "0110011"
    ));
    
    -- Address 16: nop
    load_instruction(16, i_type(
      imm    => x"000",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00000",
      opcode => "0010011"
    ));
    
    -- Address 20: nop
    load_instruction(20, i_type(
      imm    => x"000",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00000",
      opcode => "0010011"
    ));
    
    -- Address 24: sub x3, x2, x1  (x3 = 5)
    load_instruction(24, r_type(
      funct7 => "0100000",
      rs2    => "00001",
      rs1    => "00010",
      funct3 => "000",
      rd     => "00011",
      opcode => "0110011"
    ));
    
    -- Address 28: wfi (halt)
    load_instruction(28, i_type(
      imm    => x"105",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00000",
      opcode => "1110011"
    ));
    
    report "Finished loading instructions. Starting execution...";
    
    -- Run the program
    wait_cycles(1);
    
    report "Cycle 1: IF stage fetches addi x1, x0, 5";
    wait_cycles(1);
    
    report "Cycle 2: IF=nop, ID=addi x1";
    wait_cycles(1);
    
    report "Cycle 3: IF=nop, ID=nop, EX=addi x1";
    wait_cycles(1);
    
    report "Cycle 4: IF=add x2, ID=nop, EX=nop, MEM=addi x1";
    wait_cycles(1);
    
    report "Cycle 5: IF=nop, ID=add x2, EX=nop, MEM=nop, WB=addi x1 (x1 should be 5)";
    wait_cycles(1);
    
    report "Cycle 6: IF=nop, ID=nop, EX=add x2, MEM=nop, WB=nop";
    wait_cycles(1);
    
    report "Cycle 7: IF=sub x3, ID=nop, EX=nop, MEM=add x2, WB=nop";
    wait_cycles(1);
    
    report "Cycle 8: IF=wfi, ID=sub x3, EX=nop, MEM=nop, WB=add x2 (x2 should be 10)";
    wait_cycles(1);
    
    report "Cycle 9: ID=wfi, EX=sub x3, MEM=nop, WB=nop";
    wait_cycles(1);
    
    report "Cycle 10: EX=wfi, MEM=sub x3, WB=nop";
    wait_cycles(1);
    
    report "Cycle 11: MEM=wfi, WB=sub x3 (x3 should be 5)";
    wait_cycles(1);
    
    report "Cycle 12: WB=wfi (halt)";
    wait_cycles(1);
    
    report "Test 1 Complete!";
    report "Expected: x1=5, x2=10, x3=5";
    
    -- ========================================
    -- TEST 2: Load and Store operations
    -- ========================================
    s_TestNum <= 2;
    report "";
    report "========================================";
    report "TEST 2: Load/Store operations";
    report "========================================";
    
    -- Reset for new test
    s_RST <= '1';
    wait_cycles(2);
    s_RST <= '0';
    wait_cycles(1);
    
    -- Address 0: addi x1, x0, 100  (x1 = 100)
    load_instruction(0, i_type(
      imm    => x"064",
      rs1    => "00000",
      funct3 => "000",
      rd     => "00001",
      opcode => "0010011"
    ));
    
    -- Address 4-12: nops
    load_instruction(4, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(8, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(12, i_type(x"000", "00000", "000", "00000", "0010011"));
    
    -- Address 16: sw x1, 0(x0)  (store 100 to address 0)
    load_instruction(16, s_type(
      imm11_5 => "0000000",
      rs2     => "00001",
      rs1     => "00000",
      funct3  => "010",
      imm4_0  => "00000",
      opcode  => "0100011"
    ));
    
    -- Address 20-28: nops
    load_instruction(20, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(24, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(28, i_type(x"000", "00000", "000", "00000", "0010011"));
    
    -- Address 32: lw x2, 0(x0)  (load from address 0)
    load_instruction(32, i_type(
      imm    => x"000",
      rs1    => "00000",
      funct3 => "010",
      rd     => "00010",
      opcode => "0000011"
    ));
    
    -- Address 36-44: nops
    load_instruction(36, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(40, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(44, i_type(x"000", "00000", "000", "00000", "0010011"));
    
    -- Address 48: add x3, x2, x1  (x3 = 200)
    load_instruction(48, r_type(
      funct7 => "0000000",
      rs2    => "00001",
      rs1    => "00010",
      funct3 => "000",
      rd     => "00011",
      opcode => "0110011"
    ));
    
    -- Address 52: wfi
    load_instruction(52, i_type(x"105", "00000", "000", "00000", "1110011"));
    
    report "Running load/store test...";
    
    -- Run for enough cycles to complete
    for i in 1 to 20 loop
      wait_cycles(1);
      report "Cycle " & integer'image(i);
    end loop;
    
    report "Test 2 Complete!";
    report "Expected: x1=100, x2=100 (loaded), x3=200";
    
    -- ========================================
    -- TEST 3: Branch instructions
    -- ========================================
    s_TestNum <= 3;
    report "";
    report "========================================";
    report "TEST 3: Branch instructions";
    report "========================================";
    
    -- Reset for new test
    s_RST <= '1';
    wait_cycles(2);
    s_RST <= '0';
    wait_cycles(1);
    
    -- Address 0: addi x1, x0, 10  (x1 = 10)
    load_instruction(0, i_type(x"00A", "00000", "000", "00001", "0010011"));
    
    -- Address 4-8: nops
    load_instruction(4, i_type(x"000", "00000", "000", "00000", "0010011"));
    load_instruction(8, i_type(x"000", "00000", "000", "00000", "0010011"));
    
    -- Address 12: beq x1, x1, 12 (branch forward, should take)
    load_instruction(12, b_type(
      imm12   => '0',
      imm10_5 => "000000",
      rs2     => "00001",
      rs1     => "00001",
      funct3  => "000",
      imm4_1  => "0011",  -- offset 12 bytes
      imm11   => '0',
      opcode  => "1100011"
    ));
    
    -- Address 16: addi x2, x0, 99 (should be skipped)
    load_instruction(16, i_type(x"063", "00000", "000", "00010", "0010011"));
    
    -- Address 20: addi x3, x0, 99 (should be skipped)
    load_instruction(20, i_type(x"063", "00000", "000", "00011", "0010011"));
    
    -- Address 24: addi x4, x1, 5 (branch target, x4 = 15)
    load_instruction(24, i_type(x"005", "00001", "000", "00100", "0010011"));
    
    -- Address 28: wfi
    load_instruction(28, i_type(x"105", "00000", "000", "00000", "1110011"));
    
    report "Running branch test...";
    
    for i in 1 to 15 loop
      wait_cycles(1);
      report "Cycle " & integer'image(i);
    end loop;
    
    report "Test 3 Complete!";
    report "Expected: x1=10, x2=0 (skipped), x3=0 (skipped), x4=15";
    
    -- ========================================
    -- End of tests
    -- ========================================
    report "";
    report "========================================";
    report "All Tests Complete!";
    report "========================================";
    report "Check the waveform to verify:";
    report "1. Instructions flow through pipeline stages correctly";
    report "2. Register values are written in WB stage";
    report "3. Pipeline registers hold correct values";
    report "4. Branch flushes work correctly";
    report "========================================";
    
    s_TestComplete <= true;
    wait;
  end process;

end behavior;
