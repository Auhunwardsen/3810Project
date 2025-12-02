-------------------------------------------------------------------------
-- Unit Testbench for Pipeline Registers
-- Tests each pipeline register independently
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pipeline_regs is
  generic(gCLK_HPER : time := 10 ns);
end tb_pipeline_regs;

architecture behavior of tb_pipeline_regs is

  constant cCLK_PER : time := gCLK_HPER * 2;

  -- IF/ID Register
  component ifid_reg is
    port (
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_Flush     : in  std_logic;
      i_PC        : in  std_logic_vector(31 downto 0);
      i_PCPlus4   : in  std_logic_vector(31 downto 0);
      i_Inst      : in  std_logic_vector(31 downto 0);
      o_PC        : out std_logic_vector(31 downto 0);
      o_PCPlus4   : out std_logic_vector(31 downto 0);
      o_Inst      : out std_logic_vector(31 downto 0)
    );
  end component;

  -- ID/EX Register
  component idex_reg is
    port (
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_Flush     : in  std_logic;
      i_PC        : in  std_logic_vector(31 downto 0);
      i_PCPlus4   : in  std_logic_vector(31 downto 0);
      i_RS1Data   : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_Imm       : in  std_logic_vector(31 downto 0);
      i_RS1       : in  std_logic_vector(4 downto 0);
      i_RS2       : in  std_logic_vector(4 downto 0);
      i_RD        : in  std_logic_vector(4 downto 0);
      i_Funct3    : in  std_logic_vector(2 downto 0);
      i_Funct7_5  : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_MemWrite  : in  std_logic;
      i_MemRead   : in  std_logic;
      i_Branch    : in  std_logic;
      i_ALUSrc    : in  std_logic;
      i_ALUOp     : in  std_logic_vector(2 downto 0);
      i_IsJAL     : in  std_logic;
      i_IsJALR    : in  std_logic;
      i_IsAUIPC   : in  std_logic;
      o_PC        : out std_logic_vector(31 downto 0);
      o_PCPlus4   : out std_logic_vector(31 downto 0);
      o_RS1Data   : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0);
      o_Imm       : out std_logic_vector(31 downto 0);
      o_RS1       : out std_logic_vector(4 downto 0);
      o_RS2       : out std_logic_vector(4 downto 0);
      o_RD        : out std_logic_vector(4 downto 0);
      o_Funct3    : out std_logic_vector(2 downto 0);
      o_Funct7_5  : out std_logic;
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_Branch    : out std_logic;
      o_ALUSrc    : out std_logic;
      o_ALUOp     : out std_logic_vector(2 downto 0);
      o_IsJAL     : out std_logic;
      o_IsJALR    : out std_logic;
      o_IsAUIPC   : out std_logic
    );
  end component;

  signal s_CLK : std_logic := '0';
  signal s_RST : std_logic := '0';
  signal s_TestComplete : boolean := false;

  -- IF/ID signals
  signal s_IFID_WE    : std_logic := '1';
  signal s_IFID_Flush : std_logic := '0';
  signal s_IFID_PC_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IFID_PCPlus4_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IFID_Inst_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IFID_PC_out : std_logic_vector(31 downto 0);
  signal s_IFID_PCPlus4_out : std_logic_vector(31 downto 0);
  signal s_IFID_Inst_out : std_logic_vector(31 downto 0);

  -- ID/EX signals
  signal s_IDEX_WE    : std_logic := '1';
  signal s_IDEX_Flush : std_logic := '0';
  signal s_IDEX_PC_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IDEX_PCPlus4_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IDEX_RS1Data_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IDEX_RS2Data_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IDEX_Imm_in : std_logic_vector(31 downto 0) := (others => '0');
  signal s_IDEX_RS1_in : std_logic_vector(4 downto 0) := (others => '0');
  signal s_IDEX_RS2_in : std_logic_vector(4 downto 0) := (others => '0');
  signal s_IDEX_RD_in : std_logic_vector(4 downto 0) := (others => '0');
  signal s_IDEX_Funct3_in : std_logic_vector(2 downto 0) := (others => '0');
  signal s_IDEX_Funct7_5_in : std_logic := '0';
  signal s_IDEX_RegWrite_in : std_logic := '0';
  signal s_IDEX_MemToReg_in : std_logic := '0';
  signal s_IDEX_MemWrite_in : std_logic := '0';
  signal s_IDEX_MemRead_in : std_logic := '0';
  signal s_IDEX_Branch_in : std_logic := '0';
  signal s_IDEX_ALUSrc_in : std_logic := '0';
  signal s_IDEX_ALUOp_in : std_logic_vector(2 downto 0) := (others => '0');
  signal s_IDEX_IsJAL_in : std_logic := '0';
  signal s_IDEX_IsJALR_in : std_logic := '0';
  signal s_IDEX_IsAUIPC_in : std_logic := '0';
  
  signal s_IDEX_PC_out : std_logic_vector(31 downto 0);
  signal s_IDEX_PCPlus4_out : std_logic_vector(31 downto 0);
  signal s_IDEX_RS1Data_out : std_logic_vector(31 downto 0);
  signal s_IDEX_RS2Data_out : std_logic_vector(31 downto 0);
  signal s_IDEX_Imm_out : std_logic_vector(31 downto 0);
  signal s_IDEX_RS1_out : std_logic_vector(4 downto 0);
  signal s_IDEX_RS2_out : std_logic_vector(4 downto 0);
  signal s_IDEX_RD_out : std_logic_vector(4 downto 0);
  signal s_IDEX_Funct3_out : std_logic_vector(2 downto 0);
  signal s_IDEX_Funct7_5_out : std_logic;
  signal s_IDEX_RegWrite_out : std_logic;
  signal s_IDEX_MemToReg_out : std_logic;
  signal s_IDEX_MemWrite_out : std_logic;
  signal s_IDEX_MemRead_out : std_logic;
  signal s_IDEX_Branch_out : std_logic;
  signal s_IDEX_ALUSrc_out : std_logic;
  signal s_IDEX_ALUOp_out : std_logic_vector(2 downto 0);
  signal s_IDEX_IsJAL_out : std_logic;
  signal s_IDEX_IsJALR_out : std_logic;
  signal s_IDEX_IsAUIPC_out : std_logic;

begin

  -- Instantiate IF/ID register
  DUT_IFID: ifid_reg
    port map (
      i_CLK     => s_CLK,
      i_RST     => s_RST,
      i_WE      => s_IFID_WE,
      i_Flush   => s_IFID_Flush,
      i_PC      => s_IFID_PC_in,
      i_PCPlus4 => s_IFID_PCPlus4_in,
      i_Inst    => s_IFID_Inst_in,
      o_PC      => s_IFID_PC_out,
      o_PCPlus4 => s_IFID_PCPlus4_out,
      o_Inst    => s_IFID_Inst_out
    );

  -- Instantiate ID/EX register
  DUT_IDEX: idex_reg
    port map (
      i_CLK       => s_CLK,
      i_RST       => s_RST,
      i_WE        => s_IDEX_WE,
      i_Flush     => s_IDEX_Flush,
      i_PC        => s_IDEX_PC_in,
      i_PCPlus4   => s_IDEX_PCPlus4_in,
      i_RS1Data   => s_IDEX_RS1Data_in,
      i_RS2Data   => s_IDEX_RS2Data_in,
      i_Imm       => s_IDEX_Imm_in,
      i_RS1       => s_IDEX_RS1_in,
      i_RS2       => s_IDEX_RS2_in,
      i_RD        => s_IDEX_RD_in,
      i_Funct3    => s_IDEX_Funct3_in,
      i_Funct7_5  => s_IDEX_Funct7_5_in,
      i_RegWrite  => s_IDEX_RegWrite_in,
      i_MemToReg  => s_IDEX_MemToReg_in,
      i_MemWrite  => s_IDEX_MemWrite_in,
      i_MemRead   => s_IDEX_MemRead_in,
      i_Branch    => s_IDEX_Branch_in,
      i_ALUSrc    => s_IDEX_ALUSrc_in,
      i_ALUOp     => s_IDEX_ALUOp_in,
      i_IsJAL     => s_IDEX_IsJAL_in,
      i_IsJALR    => s_IDEX_IsJALR_in,
      i_IsAUIPC   => s_IDEX_IsAUIPC_in,
      o_PC        => s_IDEX_PC_out,
      o_PCPlus4   => s_IDEX_PCPlus4_out,
      o_RS1Data   => s_IDEX_RS1Data_out,
      o_RS2Data   => s_IDEX_RS2Data_out,
      o_Imm       => s_IDEX_Imm_out,
      o_RS1       => s_IDEX_RS1_out,
      o_RS2       => s_IDEX_RS2_out,
      o_RD        => s_IDEX_RD_out,
      o_Funct3    => s_IDEX_Funct3_out,
      o_Funct7_5  => s_IDEX_Funct7_5_out,
      o_RegWrite  => s_IDEX_RegWrite_out,
      o_MemToReg  => s_IDEX_MemToReg_out,
      o_MemWrite  => s_IDEX_MemWrite_out,
      o_MemRead   => s_IDEX_MemRead_out,
      o_Branch    => s_IDEX_Branch_out,
      o_ALUSrc    => s_IDEX_ALUSrc_out,
      o_ALUOp     => s_IDEX_ALUOp_out,
      o_IsJAL     => s_IDEX_IsJAL_out,
      o_IsJALR    => s_IDEX_IsJALR_out,
      o_IsAUIPC   => s_IDEX_IsAUIPC_out
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
  begin
    report "========================================";
    report "Testing Pipeline Registers";
    report "========================================";
    
    -- Test 1: Reset behavior
    report "TEST 1: Reset behavior";
    s_RST <= '1';
    wait for cCLK_PER;
    
    assert s_IFID_PC_out = x"00000000" 
      report "IFID PC not reset!" severity error;
    assert s_IFID_PCPlus4_out = x"00000000"
      report "IFID PCPlus4 not reset!" severity error;
    assert s_IFID_Inst_out = x"00000000"
      report "IFID Inst not reset!" severity error;
      
    report "Reset test PASSED";
    
    -- Test 2: Normal write operation
    report "TEST 2: Normal write operation";
    s_RST <= '0';
    s_IFID_WE <= '1';
    s_IFID_PC_in <= x"00000100";
    s_IFID_PCPlus4_in <= x"00000104";
    s_IFID_Inst_in <= x"12345678";
    wait for cCLK_PER;
    
    assert s_IFID_PC_out = x"00000100"
      report "IFID PC write failed!" severity error;
    assert s_IFID_PCPlus4_out = x"00000104"
      report "IFID PCPlus4 write failed!" severity error;
    assert s_IFID_Inst_out = x"12345678"
      report "IFID Inst write failed!" severity error;
      
    report "Normal write test PASSED";
    
    -- Test 3: Write enable = 0 (should hold value)
    report "TEST 3: Write enable = 0";
    s_IFID_WE <= '0';
    s_IFID_PC_in <= x"FFFFFFFF";
    s_IFID_PCPlus4_in <= x"FFFFFFFF";
    s_IFID_Inst_in <= x"FFFFFFFF";
    wait for cCLK_PER;
    
    assert s_IFID_PC_out = x"00000100"
      report "IFID PC changed when WE=0!" severity error;
    assert s_IFID_PCPlus4_out = x"00000104"
      report "IFID PCPlus4 changed when WE=0!" severity error;
    assert s_IFID_Inst_out = x"12345678"
      report "IFID Inst changed when WE=0!" severity error;
      
    report "Write enable test PASSED";
    
    -- Test 4: Flush operation
    report "TEST 4: Flush operation";
    s_IFID_WE <= '1';
    s_IFID_Flush <= '1';
    s_IFID_PC_in <= x"AAAAAAAA";
    wait for cCLK_PER;
    
    assert s_IFID_PC_out = x"00000000"
      report "IFID PC not flushed!" severity error;
    assert s_IFID_PCPlus4_out = x"00000000"
      report "IFID PCPlus4 not flushed!" severity error;
    assert s_IFID_Inst_out = x"00000000"
      report "IFID Inst not flushed!" severity error;
      
    report "Flush test PASSED";
    
    -- Test 5: ID/EX register normal operation
    report "TEST 5: ID/EX register operation";
    s_RST <= '0';
    s_IFID_Flush <= '0';
    s_IDEX_WE <= '1';
    s_IDEX_Flush <= '0';
    s_IDEX_PC_in <= x"00000200";
    s_IDEX_PCPlus4_in <= x"00000204";
    s_IDEX_RS1Data_in <= x"0000000A";
    s_IDEX_RS2Data_in <= x"00000014";
    s_IDEX_Imm_in <= x"00000005";
    s_IDEX_RS1_in <= "00001";
    s_IDEX_RS2_in <= "00010";
    s_IDEX_RD_in <= "00011";
    s_IDEX_RegWrite_in <= '1';
    s_IDEX_ALUSrc_in <= '1';
    s_IDEX_ALUOp_in <= "010";
    wait for cCLK_PER;
    
    assert s_IDEX_PC_out = x"00000200"
      report "IDEX PC write failed!" severity error;
    assert s_IDEX_RS1Data_out = x"0000000A"
      report "IDEX RS1Data write failed!" severity error;
    assert s_IDEX_RS2Data_out = x"00000014"
      report "IDEX RS2Data write failed!" severity error;
    assert s_IDEX_RegWrite_out = '1'
      report "IDEX RegWrite write failed!" severity error;
    assert s_IDEX_ALUSrc_out = '1'
      report "IDEX ALUSrc write failed!" severity error;
      
    report "ID/EX register test PASSED";
    
    -- Test 6: ID/EX flush
    report "TEST 6: ID/EX flush operation";
    s_IDEX_Flush <= '1';
    wait for cCLK_PER;
    
    assert s_IDEX_RegWrite_out = '0'
      report "IDEX RegWrite not flushed!" severity error;
    assert s_IDEX_MemWrite_out = '0'
      report "IDEX MemWrite not flushed!" severity error;
    assert s_IDEX_ALUSrc_out = '0'
      report "IDEX ALUSrc not flushed!" severity error;
      
    report "ID/EX flush test PASSED";
    
    report "========================================";
    report "All Pipeline Register Tests PASSED!";
    report "========================================";
    
    s_TestComplete <= true;
    wait;
  end process;

end behavior;
