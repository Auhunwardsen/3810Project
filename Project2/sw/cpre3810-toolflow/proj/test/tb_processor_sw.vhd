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
    signal s_InstLd    : std_logic := '0';
    signal s_InstAddr  : std_logic_vector(31 downto 0) := (others => '0');
    signal s_InstExt   : std_logic_vector(31 downto 0) := (others => '0');

    -- Program file path; update if your hex lives elsewhere
    constant c_IMEM_PATH : string := "../../riscv/imem.hex";  -- adjust path if needed
    file f_imem : text;  -- opened in process with file_open
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
begin
    -- Instantiate the software-scheduled processor
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
    
    -- Instruction memory loader then run
    test_proc: process
        variable v_line : line;
        variable v_word : std_logic_vector(31 downto 0);
        variable v_opened : boolean;
    begin
        -- Apply reset
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';

        -- Try to load instruction memory from hex file (one 32-bit word per line, hex)
        v_opened := file_open(f_imem, c_IMEM_PATH, read_mode);
        if v_opened then
            s_InstLd <= '1';
            s_InstAddr <= (others => '0');
            while not endfile(f_imem) loop
                readline(f_imem, v_line);
                hread(v_line, v_word);
                s_InstExt <= v_word;
                -- IMem expects word addresses; increment by 4
                wait for c_CLK_PERIOD; -- present data for a cycle
                s_InstAddr <= std_logic_vector(unsigned(s_InstAddr) + 4);
            end loop;
            s_InstLd <= '0';
            file_close(f_imem);
        else
            report "IMEM hex file not found: " & c_IMEM_PATH severity warning;
        end if;

        -- Run simulation for enough cycles to execute scheduled program
        wait for c_CLK_PERIOD * 1000;

        report "Software-scheduled pipeline test completed - WB ALUOut (dec): " & integer'image(to_integer(unsigned(s_ALUResult)));
        wait;
    end process;
    
end behavior;