library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_processor_sw is
end tb_processor_sw;

architecture behavior of tb_processor_sw is
    -- Component Declaration for Software-Scheduled Pipeline
    component riscv_processor
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
    
    -- Simple test program: LUI x2, 0x10011; ADDI x3, x2, 0x034; ADD x4, x2, x3
    type mem_array is array (0 to 15) of std_logic_vector(31 downto 0);
    constant test_program : mem_array := (
        0  => x"10011137",  -- LUI x2, 0x10011 (loads 0x10011000 into x2)
        1  => x"00000013",  -- NOP (ADDI x0, x0, 0)
        2  => x"00000013",  -- NOP  
        3  => x"03410193",  -- ADDI x3, x2, 0x034 (x3 = x2 + 0x034 = 0x10011034)
        4  => x"00000013",  -- NOP
        5  => x"00000013",  -- NOP
        6  => x"00310233",  -- ADD x4, x2, x3 (x4 = x2 + x3)
        7  => x"00000013",  -- NOP
        8  => x"00000013",  -- NOP
        9  => x"00100073",  -- EBREAK (end simulation marker)
        others => x"00000013"  -- Fill rest with NOPs
    );
    
begin
    -- Instantiate the software-scheduled processor
    UUT: riscv_processor
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
    
    -- Load test program and run
    test_proc: process
    begin
        -- Apply reset
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';

        -- Load hardcoded test program into instruction memory
        s_InstLd <= '1';
        for i in 0 to 15 loop
            s_InstAddr <= std_logic_vector(to_unsigned(i * 4, 32));
            s_InstExt <= test_program(i);
            wait for c_CLK_PERIOD;
        end loop;
        s_InstLd <= '0';

        -- Run simulation for enough cycles to execute test program
        -- LUI takes 5 cycles to WB, ADDI takes 5 more, ADD takes 5 more = ~20 cycles
        wait for c_CLK_PERIOD * 50;

        report "Test completed - Final WB ALUOut: " & integer'image(to_integer(unsigned(s_ALUResult)));
        wait;
    end process;
    
end behavior;