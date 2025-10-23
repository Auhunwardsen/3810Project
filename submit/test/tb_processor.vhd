library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_processor is
end tb_processor;

architecture behavior of tb_processor is
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
    signal s_DMemData  : std_logic_vector(31 downto 0);
    signal s_DMemWr    : std_logic;
    signal s_DMemData  : std_logic_vector(31 downto 0);
    signal s_PC        : std_logic_vector(31 downto 0);
    signal s_Inst      : std_logic_vector(31 downto 0);
    signal s_ALUResult : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- Instruction memory simulation
    type t_IMem is array(0 to 63) of std_logic_vector(31 downto 0);
    signal IMem : t_IMem := (
        -- Simple program with addi instructions
        -- addi x1, x0, 5      # x1 = 5
        0 => x"00500093",
        -- addi x2, x0, 10     # x2 = 10
        1 => x"00A00113",
        -- addi x3, x1, x2     # x3 = x1 + x2 = 15
        2 => x"00208193",
        -- sw x3, 0(x0)        # Store x3 to memory address 0
        3 => x"00302023",
        -- lw x4, 0(x0)        # Load from memory address 0 into x4
        4 => x"00002203",
        -- addi x5, x4, 5      # x5 = x4 + 5 = 20
        5 => x"00520293",
        -- beq x1, x1, 2       # Branch to PC+2 if x1 == x1 (always)
        6 => x"00108263",
        -- addi x6, x0, 1      # (skipped)
        7 => x"00100313",
        -- addi x7, x0, 1      # (skipped)
        8 => x"00100393",
        -- addi x8, x0, 30     # x8 = 30
        9 => x"01E00413",
        -- halt or other terminating instruction
        10 => x"00000000",
        others => x"00000000"
    );
    
    -- Data memory simulation
    type t_DMem is array(0 to 63) of std_logic_vector(31 downto 0);
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
            o_DMemData  => s_DMemData,
            o_DMemWr    => s_DMemWr,
            i_DMemData  => s_DMemData,
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
                DMem(to_integer(unsigned(s_DMemAddr)) / 4) <= s_DMemData;
            end if;
        end if;
        -- Memory read (asynchronous)
        s_DMemData <= DMem(to_integer(unsigned(s_DMemAddr)) / 4);
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Hold reset for 100 ns
        s_RST <= '1';
        wait for 100 ns;
        s_RST <= '0';
        
        -- Run for enough cycles to execute the program
        wait for c_CLK_PERIOD * 20;
        
        -- End simulation
        wait;
    end process;
    
end behavior;