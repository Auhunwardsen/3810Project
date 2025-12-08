-- Hardware-Scheduled Processor Testbench  
-- Tests complete pipeline with assembly programs
-- Required by Section 2.e (testing)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

entity tb_processor_hw is
end tb_processor_hw;

architecture behavior of tb_processor_hw is
    -- Component Declaration for Hardware-Scheduled Pipeline
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
    signal s_InstLd    : std_logic := '0';
    signal s_InstAddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_InstExt   : std_logic_vector(31 downto 0) := (others => '0');
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- Test instructions for different hazard scenarios
    type instruction_array is array (0 to 31) of std_logic_vector(31 downto 0);
    
    -- EX->EX forwarding test instructions
    constant EX_EX_FORWARD_PROG : instruction_array := (
        0  => x"00A00093",  -- addi x1, x0, 10
        1  => x"001000B3",  -- add  x2, x1, x0  (forward x1)
        2  => x"00500193",  -- addi x3, x0, 5
        3  => x"00318233",  -- add  x4, x3, x3  (forward x3 to both)
        4  => x"003182B3",  -- add  x5, x4, x3  (forward x4 and x3)
        others => x"00000013"  -- nop
    );
    
begin
    -- Instantiate the hardware-scheduled processor
    UUT: RISCV_Processor
        port map (
            iCLK        => s_CLK,
            iRST        => s_RST,
            iInstLd     => s_InstLd,
            iInstAddr   => s_InstAddr,
            iInstExt    => s_InstExt,
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
    
    -- Procedure to load instructions
    procedure load_program(constant prog : instruction_array) is
    begin
        s_InstLd <= '1';
        for i in 0 to prog'high loop
            s_InstAddr <= std_logic_vector(to_unsigned(i*4, 32));
            s_InstExt <= prog(i);
            wait for c_CLK_PERIOD;
        end loop;
        s_InstLd <= '0';
    end procedure;
    
    -- Test process for hardware-scheduled pipeline
    test_proc: process
    begin
        -- Reset
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';
        wait for c_CLK_PERIOD;
        
        -- Test 1: EX->EX Forwarding
        report "Loading EX->EX forwarding test...";
        load_program(EX_EX_FORWARD_PROG);
        wait for c_CLK_PERIOD * 20;
        
        report "EX->EX forwarding test completed";
        report "Final ALU output: " & to_hstring(s_ALUResult);
        wait;
    end process;
    
end behavior;