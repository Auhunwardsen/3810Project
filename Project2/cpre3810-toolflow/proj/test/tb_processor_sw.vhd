library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity tb_processor_sw is
end tb_processor_sw;

architecture behavior of tb_processor_sw is
    -- Component Declaration for Software-Scheduled Pipeline
    component RISCV_Processor
        port (
            iCLK        : in  std_logic;
            iRST        : in  std_logic;
            iInstLd     : in  std_logic;
            iInstAddr   : in  std_logic_vector(31 downto 0);
            iInstExt    : in  std_logic_vector(31 downto 0);
            oALUOut     : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signals for processor
    signal s_CLK       : std_logic := '0';
    signal s_RST       : std_logic := '0';
    signal s_ALUResult : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the software-scheduled processor
    UUT: RISCV_Processor
        port map (
            iCLK        => s_CLK,
            iRST        => s_RST,
            iInstLd     => '0',  -- Normal operation
            iInstAddr   => (others => '0'),  -- Not used when iInstLd = '0'
            iInstExt    => (others => '0'),  -- Not used when iInstLd = '0'
            oALUOut     => s_ALUResult
        );
    
    -- Clock generation
    clk_process: process
    begin
        s_CLK <= '0';
        wait for c_CLK_PERIOD/2;
        s_CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;
    
    -- Test process for software-scheduled pipeline
    test_proc: process
    begin
        -- Hold reset for 100 ns
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';
        
        -- Run simulation for enough cycles to execute scheduled program
        -- Software-scheduled pipeline needs more cycles due to NOPs
        wait for c_CLK_PERIOD * 500;
        
        report "Software-scheduled pipeline test completed - ALU output: " & to_hstring(s_ALUResult);
        wait;
    end process;
    
end behavior;