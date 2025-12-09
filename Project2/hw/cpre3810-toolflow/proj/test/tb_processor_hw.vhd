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
    
    -- Example instruction memory (replace with your test program)
    type t_instr_mem is array (0 to 15) of std_logic_vector(31 downto 0);
    constant c_instr_mem : t_instr_mem := (
        0 => x"00000013", -- NOP
        1 => x"00100093", -- ADDI x1, x0, 1
        2 => x"00200113", -- ADDI x2, x0, 2
        3 => x"002081b3", -- ADD x3, x1, x2
        4 => x"00310233", -- ADD x4, x2, x3
        5 => x"004183b3", -- ADD x7, x3, x4
        6 => x"00000013", -- NOP
        7 => x"00000013", -- NOP
        8 => x"00000013", -- NOP
        9 => x"00000013", -- NOP
        10 => x"00000013", -- NOP
        11 => x"00000013", -- NOP
        12 => x"00000013", -- NOP
        13 => x"00000013", -- NOP
        14 => x"00c0006f", -- JAL x0, 12 (jump to PC+12)
        15 => x"00208063"  -- BEQ x1, x2, 8 (branch to PC+8 if x1==x2)
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
    
    -- Instruction memory loading
    instr_load_proc: process
    begin
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';
        -- Load instructions into memory
        for i in 0 to 15 loop
            s_InstLd   <= '1';
            s_InstAddr <= std_logic_vector(to_unsigned(i*4, 32));
            s_InstExt  <= c_instr_mem(i);
            wait for c_CLK_PERIOD;
        end loop;
        s_InstLd <= '0';
        s_InstAddr <= (others => '0');
        s_InstExt  <= (others => '0');
        wait;
    end process;
    
    -- Test process for hardware-scheduled pipeline with hazard detection/forwarding
    test_proc: process
    begin
        -- Wait for instruction loading to complete
        wait for 300 ns;
        -- Run simulation for enough cycles to handle hazards and stalls
        wait for c_CLK_PERIOD * 400;
        report "Hardware-scheduled pipeline test completed - ALU output: ";
        wait;
    end process;
    
end behavior;