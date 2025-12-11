-- Simple Pipeline Registers Testbench for Software-Scheduled Pipeline
-- This testbench just runs the processor - no need for complex register testing

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.RISCV_types.all;

entity tb_pipeline_registers_simple is
end tb_pipeline_registers_simple;

architecture behavior of tb_pipeline_registers_simple is
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
    
    signal s_CLK       : std_logic := '0';
    signal s_RST       : std_logic := '0';
    signal s_ALUResult : std_logic_vector(31 downto 0);
    signal s_InstLd    : std_logic := '0';
    signal s_InstAddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_InstExt   : std_logic_vector(31 downto 0) := (others => '0');
    
    constant c_CLK_PERIOD : time := 10 ns;
    
    type mem_array is array (0 to 15) of std_logic_vector(31 downto 0);
    constant test_program : mem_array := (
        0  => x"10011137",  -- LUI x2, 0x10011
        1  => x"00000013",  -- NOP
        2  => x"00000013",  -- NOP  
        3  => x"03410193",  -- ADDI x3, x2, 0x034
        4  => x"00000013",  -- NOP
        5  => x"00000013",  -- NOP
        6  => x"00310233",  -- ADD x4, x2, x3
        7  => x"00000013",  -- NOP
        8  => x"00000013",  -- NOP
        9  => x"00000013",  -- NOP
        others => x"00000013"
    );
    
begin
    UUT: RISCV_Processor
        generic map(N => 32)
        port map (
            iCLK        => s_CLK,
            iRST        => s_RST,
            iInstLd     => s_InstLd,
            iInstAddr   => s_InstAddr,
            iInstExt    => s_InstExt,
            oALUOut     => s_ALUResult
        );
    
    clk_process: process
    begin
        s_CLK <= '0';
        wait for c_CLK_PERIOD/2;
        s_CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;
    
    test_proc: process
    begin
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';

        s_InstLd <= '1';
        for i in 0 to 15 loop
            s_InstAddr <= std_logic_vector(to_unsigned(i * 4, 32));
            s_InstExt <= test_program(i);
            wait for c_CLK_PERIOD;
        end loop;
        s_InstLd <= '0';

        wait for c_CLK_PERIOD * 50;
        
        report "Pipeline registers test complete";
        wait;
    end process;
    
end behavior;
