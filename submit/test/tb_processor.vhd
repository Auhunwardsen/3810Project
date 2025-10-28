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
    signal s_DMemData_out : std_logic_vector(31 downto 0);
    signal s_DMemWr    : std_logic;
    signal s_DMemData_in  : std_logic_vector(31 downto 0);
    signal s_PC        : std_logic_vector(31 downto 0);
    signal s_Inst      : std_logic_vector(31 downto 0);
    signal s_ALUResult : std_logic_vector(31 downto 0);
    
    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;
    
    -- Instruction memory simulation
    type t_IMem is array(0 to 63) of std_logic_vector(31 downto 0);
    signal IMem : t_IMem := (
        -- Test ADDI: Compute address
        0 => x"01400093",  -- addi x1, x0, 20    # x1 = 20
        
        -- Test ADDI: Compute value to store
        1 => x"00F00113",  -- addi x2, x0, 15    # x2 = 15
        
        -- Test SW: Store word to memory
        2 => x"00202023",  -- sw x2, 0(x1)       # MEM[20] = 15
        
        -- Test LW: Load word from memory
        3 => x"0000A183",  -- lw x3, 0(x1)       # x3 = MEM[20] = 15
        
        -- Test XORI: Transform data
        4 => x"00F1C213",  -- xori x4, x3, 15    # x4 = 15 XOR 15 = 0 (Zero flag!)
        
        -- Test SLLI: Shift left logical immediate
        5 => x"00209293",  -- slli x5, x1, 2     # x5 = 20 << 2 = 80
        
        -- Test SLT: Set less than
        6 => x"00512333",  -- slt x6, x2, x5     # x6 = (15 < 80) = 1
        
        -- Test BNE: Branch not equal (won't branch)
        7 => x"00631463",  -- bne x6, x6, 8      # Branch if x6 != x6 (false, no branch)
        
        -- This instruction executes (not skipped)
        8 => x"00100393",  -- addi x7, x0, 1     # x7 = 1
        
        -- Test AND: Logical AND
        9 => x"0020F433",  -- and x8, x1, x2     # x8 = 20 AND 15 = 4
        
        -- Halt
        10 => x"00000000", -- nop/halt
        
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
        -- Hold reset for 25 ns
        s_RST <= '1';
        wait for 25 ns;
        s_RST <= '0';
        
        -- Run for enough cycles to execute the program (12 instructions)
        wait for c_CLK_PERIOD * 15;
        
        -- End simulation
        assert false report "Test Complete" severity note;
        wait;
    end process;
    
end behavior;