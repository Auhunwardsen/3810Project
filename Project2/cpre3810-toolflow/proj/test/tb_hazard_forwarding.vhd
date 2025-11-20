-- Testbench for Hazard Detection and Forwarding Units
-- Tests all hazard detection scenarios and forwarding paths
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_hazard_forwarding is
end tb_hazard_forwarding;

architecture behavioral of tb_hazard_forwarding is
  
  -- Clock period
  constant CLK_PERIOD : time := 10 ns;
  
  -- Test signals
  signal CLK : std_logic := '0';
  
  -- Hazard Detection Unit signals
  signal IDEX_MemRead  : std_logic := '0';
  signal IDEX_RD       : std_logic_vector(4 downto 0) := "00000";
  signal IFID_RS1      : std_logic_vector(4 downto 0) := "00000";
  signal IFID_RS2      : std_logic_vector(4 downto 0) := "00000";
  signal Branch        : std_logic := '0';
  signal Jump          : std_logic := '0';
  signal PCWrite       : std_logic;
  signal IFID_Write    : std_logic;
  signal ControlMux    : std_logic;
  signal IFID_Flush    : std_logic;
  signal IDEX_Flush    : std_logic;
  
  -- Forwarding Unit signals
  signal FWD_IDEX_RS1      : std_logic_vector(4 downto 0) := "00000";
  signal FWD_IDEX_RS2      : std_logic_vector(4 downto 0) := "00000";
  signal FWD_EXMEM_RD      : std_logic_vector(4 downto 0) := "00000";
  signal FWD_MEMWB_RD      : std_logic_vector(4 downto 0) := "00000";
  signal FWD_EXMEM_RegWrite : std_logic := '0';
  signal FWD_MEMWB_RegWrite : std_logic := '0';
  signal Forward_A         : std_logic_vector(1 downto 0);
  signal Forward_B         : std_logic_vector(1 downto 0);
  
  -- Component declarations
  component hazard_detection is
    port(
      i_IDEX_MemRead  : in std_logic;
      i_IDEX_RD       : in std_logic_vector(4 downto 0);
      i_IFID_RS1      : in std_logic_vector(4 downto 0);
      i_IFID_RS2      : in std_logic_vector(4 downto 0);
      i_Branch        : in std_logic;
      i_Jump          : in std_logic;
      o_PCWrite       : out std_logic;
      o_IFID_Write    : out std_logic;
      o_ControlMux    : out std_logic;
      o_IFID_Flush    : out std_logic;
      o_IDEX_Flush    : out std_logic
    );
  end component;
  
  component forwarding_unit is
    port(
      i_IDEX_RS1      : in std_logic_vector(4 downto 0);
      i_IDEX_RS2      : in std_logic_vector(4 downto 0);
      i_EXMEM_RD      : in std_logic_vector(4 downto 0);
      i_MEMWB_RD      : in std_logic_vector(4 downto 0);
      i_EXMEM_RegWrite : in std_logic;
      i_MEMWB_RegWrite : in std_logic;
      o_Forward_A     : out std_logic_vector(1 downto 0);
      o_Forward_B     : out std_logic_vector(1 downto 0)
    );
  end component;

begin

  -- Clock generation
  CLK <= not CLK after CLK_PERIOD/2;
  
  -- Instantiate Hazard Detection Unit
  UUT_HAZARD: hazard_detection
    port map(
      i_IDEX_MemRead  => IDEX_MemRead,
      i_IDEX_RD       => IDEX_RD,
      i_IFID_RS1      => IFID_RS1,
      i_IFID_RS2      => IFID_RS2,
      i_Branch        => Branch,
      i_Jump          => Jump,
      o_PCWrite       => PCWrite,
      o_IFID_Write    => IFID_Write,
      o_ControlMux    => ControlMux,
      o_IFID_Flush    => IFID_Flush,
      o_IDEX_Flush    => IDEX_Flush
    );
  
  -- Instantiate Forwarding Unit
  UUT_FORWARD: forwarding_unit
    port map(
      i_IDEX_RS1      => FWD_IDEX_RS1,
      i_IDEX_RS2      => FWD_IDEX_RS2,
      i_EXMEM_RD      => FWD_EXMEM_RD,
      i_MEMWB_RD      => FWD_MEMWB_RD,
      i_EXMEM_RegWrite => FWD_EXMEM_RegWrite,
      i_MEMWB_RegWrite => FWD_MEMWB_RegWrite,
      o_Forward_A     => Forward_A,
      o_Forward_B     => Forward_B
    );
  
  -- Test process
  test_proc: process
  begin
    
    -- Test 1: Load-use hazard detection
    report "Test 1: Load-Use Hazard Detection";
    IDEX_MemRead <= '1';        -- Previous instruction is a load
    IDEX_RD <= "00001";         -- Load targets register x1
    IFID_RS1 <= "00001";        -- Current instruction uses x1
    IFID_RS2 <= "00010";        -- Current instruction uses x2
    Branch <= '0';
    Jump <= '0';
    wait for CLK_PERIOD;
    
    -- Expected: PCWrite = '0', IFID_Write = '0', ControlMux = '1' (stall)
    assert PCWrite = '0' report "Load-use hazard: PCWrite should be 0" severity error;
    assert IFID_Write = '0' report "Load-use hazard: IFID_Write should be 0" severity error;
    assert ControlMux = '1' report "Load-use hazard: ControlMux should be 1" severity error;
    
    -- Test 2: No hazard
    report "Test 2: No Hazard";
    IDEX_MemRead <= '0';        -- Not a load
    IDEX_RD <= "00001";         
    IFID_RS1 <= "00010";        -- Different register
    IFID_RS2 <= "00011";        -- Different register
    wait for CLK_PERIOD;
    
    -- Expected: PCWrite = '1', IFID_Write = '1', ControlMux = '0' (no stall)
    assert PCWrite = '1' report "No hazard: PCWrite should be 1" severity error;
    assert IFID_Write = '1' report "No hazard: IFID_Write should be 1" severity error;
    assert ControlMux = '0' report "No hazard: ControlMux should be 0" severity error;
    
    -- Test 3: Branch hazard
    report "Test 3: Branch Hazard";
    Branch <= '1';              -- Branch instruction
    wait for CLK_PERIOD;
    
    -- Expected: IFID_Flush = '1', IDEX_Flush = '1'
    assert IFID_Flush = '1' report "Branch hazard: IFID_Flush should be 1" severity error;
    assert IDEX_Flush = '1' report "Branch hazard: IDEX_Flush should be 1" severity error;
    
    Branch <= '0';              -- Clear branch
    wait for CLK_PERIOD;
    
    -- Test 4: EX/MEM to EX forwarding
    report "Test 4: EX/MEM to EX Forwarding";
    FWD_IDEX_RS1 <= "00001";        -- Current instruction uses x1
    FWD_IDEX_RS2 <= "00010";        -- Current instruction uses x2
    FWD_EXMEM_RD <= "00001";        -- EX/MEM stage writes to x1
    FWD_EXMEM_RegWrite <= '1';      -- EX/MEM stage has RegWrite enabled
    FWD_MEMWB_RD <= "00000";        
    FWD_MEMWB_RegWrite <= '0';
    wait for CLK_PERIOD;
    
    -- Expected: Forward_A = "10" (EX/MEM), Forward_B = "00" (no forwarding)
    assert Forward_A = "10" report "EX/MEM forwarding: Forward_A should be 10" severity error;
    assert Forward_B = "00" report "No forwarding for B: Forward_B should be 00" severity error;
    
    -- Test 5: MEM/WB to EX forwarding
    report "Test 5: MEM/WB to EX Forwarding";
    FWD_EXMEM_RD <= "00000";        -- EX/MEM doesn't write to x1
    FWD_EXMEM_RegWrite <= '0';      
    FWD_MEMWB_RD <= "00001";        -- MEM/WB stage writes to x1
    FWD_MEMWB_RegWrite <= '1';      -- MEM/WB stage has RegWrite enabled
    wait for CLK_PERIOD;
    
    -- Expected: Forward_A = "01" (MEM/WB)
    assert Forward_A = "01" report "MEM/WB forwarding: Forward_A should be 01" severity error;
    
    -- Test 6: No forwarding (register x0)
    report "Test 6: No Forwarding for x0";
    FWD_IDEX_RS1 <= "00000";        -- Using x0 (always zero)
    FWD_EXMEM_RD <= "00000";        -- Writing to x0
    FWD_EXMEM_RegWrite <= '1';      
    wait for CLK_PERIOD;
    
    -- Expected: Forward_A = "00" (no forwarding for x0)
    assert Forward_A = "00" report "No forwarding for x0: Forward_A should be 00" severity error;
    
    -- Test 7: Priority forwarding (EX/MEM over MEM/WB)
    report "Test 7: Priority Forwarding";
    FWD_IDEX_RS1 <= "00001";        -- Using x1
    FWD_EXMEM_RD <= "00001";        -- EX/MEM writes to x1
    FWD_EXMEM_RegWrite <= '1';      
    FWD_MEMWB_RD <= "00001";        -- MEM/WB also writes to x1
    FWD_MEMWB_RegWrite <= '1';      
    wait for CLK_PERIOD;
    
    -- Expected: Forward_A = "10" (EX/MEM has priority)
    assert Forward_A = "10" report "Priority forwarding: Forward_A should be 10 (EX/MEM priority)" severity error;
    
    report "All tests completed successfully!";
    wait;
    
  end process;

end behavioral;