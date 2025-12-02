-------------------------------------------------------------------------
-- Testbench for Software-Scheduled 5-Stage Pipelined RISC-V Processor
-- Tests the final processor with comprehensive instruction coverage
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
library std;
use std.textio.all;

library work;
use work.RISCV_types.all;

entity tb_processor_sw is
  generic(gCLK_HPER : time := 10 ns);
end tb_processor_sw;

architecture behavior of tb_processor_sw is
  
  constant cCLK_PER : time := gCLK_HPER * 2;
  
  -- Component Declaration for Software-Scheduled Pipeline
  component RISCV_Processor
    generic(N : integer := DATA_WIDTH);
    port (
      iCLK        : in  std_logic;
      iRST        : in  std_logic;
      iInstLd     : in  std_logic;
      iInstAddr   : in  std_logic_vector(N-1 downto 0);
      iInstExt    : in  std_logic_vector(N-1 downto 0);
      oALUOut     : out std_logic_vector(N-1 downto 0)
    );
  end component;
  
  -- Signals for processor
  signal s_CLK       : std_logic := '0';
  signal s_RST       : std_logic := '0';
  signal s_ALUResult : std_logic_vector(31 downto 0);
  signal s_InstLd    : std_logic := '0';
  signal s_InstAddr  : std_logic_vector(31 downto 0) := (others => '0');
  signal s_InstExt   : std_logic_vector(31 downto 0) := (others => '0');
  
  -- Test control
  signal s_TestComplete : boolean := false;
  signal s_CycleCount   : integer := 0;
  
  -- Comprehensive test program with all instruction types
  type mem_array is array (0 to 63) of std_logic_vector(31 downto 0);
  constant test_program : mem_array := (
    -- Test 1: Basic R-type and I-type with proper scheduling
    0  => x"00500093",  -- addi x1, x0, 5      (x1 = 5)
    1  => x"00000013",  -- nop
    2  => x"00000013",  -- nop
    3  => x"00000013",  -- nop
    4  => x"00108133",  -- add x2, x1, x1      (x2 = 10)
    5  => x"00000013",  -- nop
    6  => x"00000013",  -- nop
    7  => x"00000013",  -- nop
    8  => x"401101B3",  -- sub x3, x2, x1      (x3 = 5)
    
    -- Test 2: Logical operations
    9  => x"00000013",  -- nop
    10 => x"00000013",  -- nop
    11 => x"00000013",  -- nop
    12 => x"0020F213",  -- andi x4, x1, 2      (x4 = 0)
    13 => x"00000013",  -- nop
    14 => x"00000013",  -- nop
    15 => x"00000013",  -- nop
    16 => x"0020E293",  -- ori x5, x1, 2       (x5 = 7)
    17 => x"00000013",  -- nop
    18 => x"00000013",  -- nop
    19 => x"00000013",  -- nop
    20 => x"0020C313",  -- xori x6, x1, 2      (x6 = 7)
    
    -- Test 3: Shift operations
    21 => x"00000013",  -- nop
    22 => x"00000013",  -- nop
    23 => x"00000013",  -- nop
    24 => x"00109393",  -- slli x7, x1, 1      (x7 = 10)
    25 => x"00000013",  -- nop
    26 => x"00000013",  -- nop
    27 => x"00000013",  -- nop
    28 => x"0010D413",  -- srli x8, x1, 1      (x8 = 2)
    
    -- Test 4: Load upper immediate and AUIPC
    29 => x"00000013",  -- nop
    30 => x"00000013",  -- nop
    31 => x"00000013",  -- nop
    32 => x"123454B7",  -- lui x9, 0x12345     (x9 = 0x12345000)
    33 => x"00000013",  -- nop
    34 => x"00000013",  -- nop
    35 => x"00000013",  -- nop
    36 => x"00000517",  -- auipc x10, 0        (x10 = PC + 0)
    
    -- Test 5: Memory operations (store then load)
    37 => x"00000013",  -- nop
    38 => x"00000013",  -- nop
    39 => x"00000013",  -- nop
    40 => x"00102023",  -- sw x1, 0(x0)        (store x1=5 to addr 0)
    41 => x"00000013",  -- nop
    42 => x"00000013",  -- nop
    43 => x"00000013",  -- nop
    44 => x"00002583",  -- lw x11, 0(x0)       (load from addr 0, x11 = 5)
    
    -- Test 6: Branch instruction (BEQ - should be taken)
    45 => x"00000013",  -- nop
    46 => x"00000013",  -- nop
    47 => x"00000013",  -- nop
    48 => x"00108663",  -- beq x1, x1, 12      (branch forward 12 bytes)
    49 => x"06300613",  -- addi x12, x0, 99    (SKIPPED - shouldn't execute)
    50 => x"06300693",  -- addi x13, x0, 99    (SKIPPED - shouldn't execute)
    51 => x"00A00713",  -- addi x14, x0, 10    (branch target, x14 = 10)
    
    -- Test 7: JAL instruction
    52 => x"00000013",  -- nop
    53 => x"00000013",  -- nop
    54 => x"00000013",  -- nop
    55 => x"008007EF",  -- jal x15, 8          (jump forward, x15 = return addr)
    56 => x"06300813",  -- addi x16, x0, 99    (SKIPPED - shouldn't execute)
    57 => x"00F00893",  -- addi x17, x0, 15    (jump target, x17 = 15)
    
    -- Test 8: End with WFI
    58 => x"00000013",  -- nop
    59 => x"00000013",  -- nop
    60 => x"00000013",  -- nop
    61 => x"10500073",  -- wfi                 (halt instruction)
    
    others => x"00000013"  -- Fill rest with NOPs
  );
  
begin

  -- Instantiate the software-scheduled processor
  DUT: RISCV_Processor
    generic map(N => 32)
    port map (
      iCLK        => s_CLK,
      iRST        => s_RST,
      iInstLd     => s_InstLd,
      iInstAddr   => s_InstAddr,
      iInstExt    => s_InstExt,
      oALUOut     => s_ALUResult
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
  
  -- Cycle counter
  P_COUNTER: process(s_CLK)
  begin
    if rising_edge(s_CLK) and s_InstLd = '0' and s_RST = '0' then
      s_CycleCount <= s_CycleCount + 1;
    end if;
  end process;
  
  -- Test stimulus and monitoring
  P_TEST: process
    variable v_cycle : integer := 0;
  begin
    report "========================================";
    report "Software-Scheduled Pipeline Processor Test";
    report "========================================";
    
    -- Apply reset
    report "Applying reset...";
    s_RST <= '1';
    wait for cCLK_PER * 3;
    s_RST <= '0';
    wait for cCLK_PER;
    
    report "Loading test program into instruction memory...";
    
    -- Load test program into instruction memory
    s_InstLd <= '1';
    for i in 0 to 63 loop
      s_InstAddr <= std_logic_vector(to_unsigned(i * 4, 32));
      s_InstExt <= test_program(i);
      wait for cCLK_PER;
    end loop;
    s_InstLd <= '0';
    
    report "Program loaded. Starting execution...";
    report "========================================";
    
    -- Monitor execution for key milestones
    wait for cCLK_PER * 10;
    report "Cycle 10: First instruction (addi x1) should be in WB stage";
    
    wait for cCLK_PER * 10;
    report "Cycle 20: R-type operations should be completing";
    
    wait for cCLK_PER * 10;
    report "Cycle 30: Logical operations in progress";
    
    wait for cCLK_PER * 10;
    report "Cycle 40: Shift and LUI operations in progress";
    
    wait for cCLK_PER * 10;
    report "Cycle 50: Memory operations (store/load) in progress";
    
    wait for cCLK_PER * 10;
    report "Cycle 60: Branch instruction executed";
    
    wait for cCLK_PER * 10;
    report "Cycle 70: JAL instruction executed";
    
    wait for cCLK_PER * 20;
    report "Cycle 90: Program should be near completion";
    
    -- Let it run to completion
    wait for cCLK_PER * 30;
    
    report "========================================";
    report "Test Execution Complete!";
    report "========================================";
    report "Total cycles executed: " & integer'image(s_CycleCount);
    report "Final ALU output: 0x" & to_hstring(s_ALUResult);
    report "";
    report "Expected Results (verify in waveform):";
    report "  x1  = 5          (0x00000005)";
    report "  x2  = 10         (0x0000000A)";
    report "  x3  = 5          (0x00000005)";
    report "  x4  = 0          (0x00000000)";
    report "  x5  = 7          (0x00000007)";
    report "  x6  = 7          (0x00000007)";
    report "  x7  = 10         (0x0000000A)";
    report "  x8  = 2          (0x00000002)";
    report "  x9  = 0x12345000 (LUI result)";
    report "  x10 = PC+0       (AUIPC result)";
    report "  x11 = 5          (loaded from memory)";
    report "  x12 = 0          (should NOT be 99 - branch skip)";
    report "  x13 = 0          (should NOT be 99 - branch skip)";
    report "  x14 = 10         (branch target)";
    report "  x15 = return_addr (JAL link register)";
    report "  x16 = 0          (should NOT be 99 - jump skip)";
    report "  x17 = 15         (jump target)";
    report "========================================";
    report "Check waveform for:";
    report "  1. Instructions progressing through all 5 stages";
    report "  2. Pipeline registers updating correctly";
    report "  3. Branch/Jump flushes working properly";
    report "  4. Register writes occurring in WB stage";
    report "  5. Memory operations completing correctly";
    report "========================================";
    
    s_TestComplete <= true;
    wait;
  end process;
  
end behavior;