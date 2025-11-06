library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use STD.textio.all;

library work;
use work.RISCV_types.all;

entity tb_processor is
end tb_processor;

architecture behavior of tb_processor is
    -- Component Declaration for RISCV_Processor
    component RISCV_Processor
        generic(N : integer := DATA_WIDTH);
        port(
            iCLK            : in std_logic;
            iRST            : in std_logic;
            iInstLd         : in std_logic;
            iInstAddr       : in std_logic_vector(N-1 downto 0);
            iInstExt        : in std_logic_vector(N-1 downto 0);
            oALUOut         : out std_logic_vector(N-1 downto 0)
        );
    end component;
    
    -- Signals for RISCV_Processor
    signal s_CLK       : std_logic := '0';
    signal s_RST       : std_logic := '0';
    signal s_InstLd    : std_logic := '0';
    signal s_InstAddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_InstExt   : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALUResult : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the RISCV_Processor
    UUT: RISCV_Processor
        generic map(N => 32)
        port map (
            iCLK      => s_CLK,
            iRST      => s_RST,
            iInstLd   => s_InstLd,
            iInstAddr => s_InstAddr,
            iInstExt  => s_InstExt,
            oALUOut   => s_ALUResult
        );
    
    -- Clock process
    CLK_process: process
    begin
        s_CLK <= '0';
        wait for c_CLK_PERIOD/2;
        s_CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for 25 ns
        s_RST <= '1';
        wait for 25 ns;
        s_RST <= '0';
        
        -- Run for enough cycles to execute the program
        wait for c_CLK_PERIOD * 50;
        
        -- End simulation
        assert false report "Test Complete - ALU Result: " & integer'image(to_integer(unsigned(s_ALUResult))) severity note;
        wait;
    end process;

end behavior;