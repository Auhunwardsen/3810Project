library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use IEEE.std_logic_textio.all;

entity tb_processor_hex is
end tb_processor_hex;

architecture behavior of tb_processor_hex is
    -- Component Declaration
    component processor
        port (
            i_CLK       : in  std_logic;
            i_RST       : in  std_logic;
            -- Memory interfaces
            o_IMemAddr  : out std_logic_vector(31 downto 0);
            i_IMemData  : in  std_logic_vector(31 downto 0);
            o_DMemAddr  : out std_logic_vector(31 downto 0);
            o_DMemData  : out std_logic_vector(31 downto 0);
            o_DMemWr    : out std_logic;
            i_DMemData  : in  std_logic_vector(31 downto 0);
            -- For testing/debugging
            o_PC        : out std_logic_vector(31 downto 0);
            o_Inst      : out std_logic_vector(31 downto 0);
            o_ALUResult : out std_logic_vector(31 downto 0)
        );
    end component;
    
    -- Signals for processor
    signal s_CLK       : std_logic := '0';
    signal s_RST       : std_logic := '0';
    signal s_IMemAddr  : std_logic_vector(31 downto 0);
    signal s_IMemData  : std_logic_vector(31 downto 0);
    signal s_DMemAddr  : std_logic_vector(31 downto 0);
    signal s_DMemData_out : std_logic_vector(31 downto 0);
    signal s_DMemWr    : std_logic;
    signal s_DMemData_in  : std_logic_vector(31 downto 0);
    signal s_PC        : std_logic_vector(31 downto 0);
    signal s_Inst      : std_logic_vector(31 downto 0);
    signal s_ALUResult : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- Instruction memory simulation (larger for hex files)
    type t_IMem is array(0 to 255) of std_logic_vector(31 downto 0);
    signal IMem : t_IMem := (others => x"00000000");
    
    -- Data memory simulation
    type t_DMem is array(0 to 255) of std_logic_vector(31 downto 0);
    signal DMem : t_DMem := (others => x"00000000");
    
begin
    -- Instantiate the processor
    UUT: processor
        port map (
            i_CLK       => s_CLK,
            i_RST       => s_RST,
            o_IMemAddr  => s_IMemAddr,
            i_IMemData  => s_IMemData,
            o_DMemAddr  => s_DMemAddr,
            o_DMemData  => s_DMemData_out,
            o_DMemWr    => s_DMemWr,
            i_DMemData  => s_DMemData_in,
            o_PC        => s_PC,
            o_Inst      => s_Inst,
            o_ALUResult => s_ALUResult
        );
    
    -- Clock process
    CLK_process: process
    begin
        s_CLK <= '0';
        wait for c_CLK_PERIOD/2;
        s_CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;
    
    -- Load instruction memory from hex file
    IMEM_LOAD: process
        file hex_file : text;
        variable hex_line : line;
        variable hex_data : std_logic_vector(31 downto 0);
        variable i : integer := 0;
        variable good : boolean;
    begin
        -- Try to open the hex file (change filename as needed)
        file_open(hex_file, "Proj1_base_test.hex", read_mode);
        
        -- Read each line from the hex file
        while not endfile(hex_file) and i < 256 loop
            readline(hex_file, hex_line);
            -- Skip empty lines
            if hex_line'length > 0 then
                hread(hex_line, hex_data, good);
                if good then
                    IMem(i) <= hex_data;
                    i := i + 1;
                end if;
            end if;
        end loop;
        
        file_close(hex_file);
        report "Loaded " & integer'image(i) & " instructions from hex file";
        wait;
    end process;
    
    -- Instruction memory read process
    IMem_process: process(s_IMemAddr)
    begin
        -- Convert byte address to word address by dividing by 4
        s_IMemData <= IMem(to_integer(unsigned(s_IMemAddr)) / 4);
    end process;
    
    -- Data memory read/write process
    DMem_process: process(s_CLK)
    begin
        if rising_edge(s_CLK) then
            -- Memory write
            if s_DMemWr = '1' then
                DMem(to_integer(unsigned(s_DMemAddr)) / 4) <= s_DMemData_out;
            end if;
        end if;
        -- Memory read (asynchronous)
        s_DMemData_in <= DMem(to_integer(unsigned(s_DMemAddr)) / 4);
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for 100 ns
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';
        
        -- Run for enough cycles to execute the program
        wait for c_CLK_PERIOD * 100;  -- Increased for longer programs
        
        -- End simulation
        report "Simulation complete";
        wait;
    end process;
    
end behavior;

-- [1] IEEE Std 1076-2008, "IEEE Standard VHDL Language Reference Manual," IEEE Computer Society, 2009.
--     File I/O operations (textio package) used for loading hex instruction files into testbench memory.