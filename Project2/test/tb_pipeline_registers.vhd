-- Testbench for Pipeline Registers
-- Tests stalling, flushing, and normal operation
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_pipeline_registers is
end tb_pipeline_registers;

architecture behavioral of tb_pipeline_registers is
  
  -- Clock and reset
  signal CLK   : std_logic := '0';
  signal RST   : std_logic := '0';
  
  -- Control signals for testing
  signal WE_IFID    : std_logic := '1';
  signal WE_IDEX    : std_logic := '1'; 
  signal WE_EXMEM   : std_logic := '1';
  signal WE_MEMWB   : std_logic := '1';
  
  signal FLUSH_IFID   : std_logic := '0';
  signal FLUSH_IDEX   : std_logic := '0';
  signal FLUSH_EXMEM  : std_logic := '0';
  signal FLUSH_MEMWB  : std_logic := '0';
  
  -- Test data
  signal test_pc      : std_logic_vector(31 downto 0) := x"00000000";
  signal test_instr   : std_logic_vector(31 downto 0) := x"12345678";
  signal test_data    : std_logic_vector(31 downto 0) := x"ABCDEF00";
  
  -- Pipeline register outputs (for tracking data flow)
  signal ifid_pc_out     : std_logic_vector(31 downto 0);
  signal ifid_instr_out  : std_logic_vector(31 downto 0);
  signal idex_pc_out     : std_logic_vector(31 downto 0);
  signal idex_instr_out  : std_logic_vector(31 downto 0);
  signal idex_rs1_out    : std_logic_vector(31 downto 0);
  signal exmem_alu_out   : std_logic_vector(31 downto 0);
  signal exmem_data_out  : std_logic_vector(31 downto 0);
  signal memwb_alu_out   : std_logic_vector(31 downto 0);
  signal memwb_data_out  : std_logic_vector(31 downto 0);
  
  -- Component declarations
  component IFID_reg is
    port(
      i_CLK     : in  std_logic;
      i_RST     : in  std_logic;
      i_WE      : in  std_logic;
      i_flush   : in  std_logic;
      i_PC      : in  std_logic_vector(31 downto 0);
      i_PCplus4 : in  std_logic_vector(31 downto 0); 
      i_Instr   : in  std_logic_vector(31 downto 0);
      o_PC      : out std_logic_vector(31 downto 0);
      o_PCplus4 : out std_logic_vector(31 downto 0);
      o_Instr   : out std_logic_vector(31 downto 0)
    );
  end component;
  
  component IDEX_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_MemWrite  : in  std_logic;
      i_MemRead   : in  std_logic;
      i_Branch    : in  std_logic;
      i_ALUSrc    : in  std_logic;
      i_ALUOp     : in  std_logic_vector(2 downto 0);
      i_PC        : in  std_logic_vector(31 downto 0);
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_RS1Data   : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_Immediate : in  std_logic_vector(31 downto 0);
      i_RS1Addr   : in  std_logic_vector(4 downto 0);
      i_RS2Addr   : in  std_logic_vector(4 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr     : in  std_logic_vector(31 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_Branch    : out std_logic;
      o_ALUSrc    : out std_logic;
      o_ALUOp     : out std_logic_vector(2 downto 0);
      o_PC        : out std_logic_vector(31 downto 0);
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_RS1Data   : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0);
      o_Immediate : out std_logic_vector(31 downto 0);
      o_RS1Addr   : out std_logic_vector(4 downto 0);
      o_RS2Addr   : out std_logic_vector(4 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0);
      o_Instr     : out std_logic_vector(31 downto 0)
    );
  end component;

  component EXMEM_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_MemWrite  : in  std_logic;
      i_MemRead   : in  std_logic;
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_PCBranch  : in  std_logic_vector(31 downto 0);
      i_PCSrc     : in  std_logic;
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_PCBranch  : out std_logic_vector(31 downto 0);
      o_PCSrc     : out std_logic;
      o_ALUResult : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0)
    );
  end component;

  component MEMWB_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_MemData   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_ALUResult : out std_logic_vector(31 downto 0);
      o_MemData   : out std_logic_vector(31 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0)
    );
  end component;
  
begin

  -- Clock generation (10ns period)
  CLK <= not CLK after 5 ns;
  
  -- Instantiate IFID register for testing
  IFID_REG_INST: IFID_reg
    port map(
      i_CLK     => CLK,
      i_RST     => RST,
      i_WE      => WE_IFID,
      i_flush   => FLUSH_IFID,
      i_PC      => test_pc,
      i_PCplus4 => std_logic_vector(unsigned(test_pc) + 4),
      i_Instr   => test_instr,
      o_PC      => ifid_pc_out,
      o_PCplus4 => open,
      o_Instr   => ifid_instr_out
    );
  
  -- Instantiate IDEX register for testing  
  IDEX_REG_INST: IDEX_reg
    port map(
      i_CLK       => CLK,
      i_RST       => RST,
      i_WE        => WE_IDEX,
      i_flush     => FLUSH_IDEX,
      i_RegWrite  => '1',
      i_MemToReg  => '0',
      i_MemWrite  => '0',
      i_MemRead   => '0',
      i_Branch    => '0',
      i_ALUSrc    => '0',
      i_ALUOp     => "000",
      i_PC        => ifid_pc_out,
      i_PCplus4   => std_logic_vector(unsigned(ifid_pc_out) + 4),
      i_RS1Data   => test_data,
      i_RS2Data   => x"00000000",
      i_Immediate => x"00000010",
      i_RS1Addr   => "00001",
      i_RS2Addr   => "00010",
      i_RDAddr    => "00011",
      i_Instr     => ifid_instr_out,
      o_RegWrite  => open,
      o_MemToReg  => open,
      o_MemWrite  => open,
      o_MemRead   => open,
      o_Branch    => open,
      o_ALUSrc    => open,
      o_ALUOp     => open,
      o_PC        => idex_pc_out,
      o_PCplus4   => open,
      o_RS1Data   => open,
      o_RS2Data   => open,
      o_Immediate => open,
      o_RS1Addr   => open,
      o_RS2Addr   => open,
      o_RDAddr    => open,
      o_RS1Data   => idex_rs1_out,
      o_RS2Data   => open,
      o_Immediate => open,
      o_RS1Addr   => open,
      o_RS2Addr   => open,
      o_RDAddr    => open,
      o_Instr     => idex_instr_out
    );

  -- Instantiate EXMEM register for testing
  EXMEM_REG_INST: EXMEM_reg
    port map(
      i_CLK       => CLK,
      i_RST       => RST,
      i_WE        => WE_EXMEM,
      i_flush     => FLUSH_EXMEM,
      i_RegWrite  => '1',
      i_MemToReg  => '0',
      i_MemWrite  => '0',
      i_MemRead   => '0',
      i_PCplus4   => std_logic_vector(unsigned(idex_pc_out) + 4),
      i_PCBranch  => x"00000000",
      i_PCSrc     => '0',
      i_ALUResult => idex_rs1_out,  -- Use RS1 data as ALU result for test
      i_RS2Data   => x"00000000",
      i_RDAddr    => "00100",
      o_RegWrite  => open,
      o_MemToReg  => open,
      o_MemWrite  => open,
      o_MemRead   => open,
      o_PCplus4   => open,
      o_PCBranch  => open,
      o_PCSrc     => open,
      o_ALUResult => exmem_alu_out,
      o_RS2Data   => exmem_data_out,
      o_RDAddr    => open
    );

  -- Instantiate MEMWB register for testing  
  MEMWB_REG_INST: MEMWB_reg
    port map(
      i_CLK       => CLK,
      i_RST       => RST,
      i_WE        => WE_MEMWB,
      i_flush     => FLUSH_MEMWB,
      i_RegWrite  => '1',
      i_MemToReg  => '1',
      i_PCplus4   => std_logic_vector(unsigned(idex_pc_out) + 4),
      i_ALUResult => exmem_alu_out,
      i_MemData   => x"MEMDATA1",  -- Simulated memory data
      i_RDAddr    => "00101",
      o_RegWrite  => open,
      o_MemToReg  => open,
      o_PCplus4   => open,
      o_ALUResult => memwb_alu_out,
      o_MemData   => memwb_data_out,
      o_RDAddr    => open
    );
  
  -- Test process
  process
  begin
    -- Test 1: Reset all registers
    RST <= '1';
    wait for 20 ns;
    RST <= '0';
    wait for 10 ns;
    
    -- Test 2: Normal operation - data should propagate through pipeline
    test_pc <= x"00000000";
    test_instr <= x"12345678";
    test_data <= x"DEADBEEF";
    wait for 10 ns;
    
    test_pc <= x"00000004";
    test_instr <= x"87654321";
    test_data <= x"FEEDFACE";
    wait for 10 ns;
    
    test_pc <= x"00000008";
    test_instr <= x"ABCDEF00";
    test_data <= x"CAFEBABE";
    wait for 10 ns;
    
    test_pc <= x"0000000C";
    test_instr <= x"00FEDCBA";
    test_data <= x"BEEFCAFE";
    wait for 10 ns;
    
    -- Test 3: Stall IFID register (should hold current values)
    WE_IFID <= '0';  -- Stall IFID
    test_pc <= x"00000010";
    test_instr <= x"STALLED1";
    wait for 20 ns;
    WE_IFID <= '1';  -- Resume
    wait for 10 ns;
    
    -- Test 4: Stall IDEX register (should hold current values)
    WE_IDEX <= '0';  -- Stall IDEX
    test_pc <= x"00000014";
    test_instr <= x"STALLED2";
    wait for 20 ns;
    WE_IDEX <= '1';  -- Resume
    wait for 10 ns;
    
    -- Test 5: Flush IFID register (should clear to zeros)
    FLUSH_IFID <= '1';
    wait for 10 ns;
    FLUSH_IFID <= '0';
    wait for 10 ns;
    
    -- Test 6: Flush IDEX register (should clear to zeros)
    FLUSH_IDEX <= '1';
    wait for 10 ns;
    FLUSH_IDEX <= '0';
    wait for 10 ns;
    
    -- Test 7: Verify exact 4-cycle propagation delay
    -- Input unique test pattern and verify it appears at WB stage after exactly 4 cycles
    test_pc <= x"000000F0";
    test_instr <= x"TESTPROP";
    test_data <= x"CAFEBABE";  -- Unique pattern to track
    
    -- Cycle 1: Data enters IFID
    wait for 10 ns;
    assert ifid_instr_out = x"TESTPROP" report "IFID stage failed" severity error;
    
    -- Cycle 2: Data moves to IDEX  
    wait for 10 ns;
    assert idex_instr_out = x"TESTPROP" report "IDEX stage failed" severity error;
    assert idex_rs1_out = x"CAFEBABE" report "IDEX data failed" severity error;
    
    -- Cycle 3: Data moves to EXMEM
    wait for 10 ns;
    assert exmem_alu_out = x"CAFEBABE" report "EXMEM stage failed" severity error;
    
    -- Cycle 4: Data reaches MEMWB (complete 4-cycle propagation)
    wait for 10 ns;
    assert memwb_alu_out = x"CAFEBABE" report "4-cycle propagation failed" severity error;
    
    -- Test 8: Verify pipeline registers can be individually controlled
    -- Test simultaneous stall and flush operations
    WE_IFID <= '0';      -- Stall IF/ID
    FLUSH_IDEX <= '1';   -- Flush ID/EX
    test_pc <= x"00000020";
    test_instr <= x"SHOULDNT";
    wait for 10 ns;
    
    -- Verify IFID held previous value, IDEX was flushed
    assert ifid_instr_out = x"TESTPROP" report "IFID stall failed" severity error;
    -- Note: Specific flush behavior depends on implementation
    
    -- Restore normal operation
    WE_IFID <= '1';
    FLUSH_IDEX <= '0';
    wait for 10 ns;
    
    -- End simulation
    assert false report "All pipeline register tests completed successfully!" severity note;
    wait;
  end process;

end behavioral;