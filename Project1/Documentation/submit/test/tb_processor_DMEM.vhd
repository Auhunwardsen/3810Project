library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_processor_DMEM is
end tb_processor_DMEM;

architecture behavior of tb_processor_DMEM is
    -------------------------------------------------------------------
    -- Component Declaration
    -------------------------------------------------------------------
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
            -- Debug / observation
            o_PC        : out std_logic_vector(31 downto 0);
            o_Inst      : out std_logic_vector(31 downto 0);
            o_ALUResult : out std_logic_vector(31 downto 0)
        );
    end component;

    -------------------------------------------------------------------
    -- Signal Declarations
    -------------------------------------------------------------------
    signal s_CLK          : std_logic := '0';
    signal s_RST          : std_logic := '0';
    signal s_IMemAddr     : std_logic_vector(31 downto 0);
    signal s_IMemData     : std_logic_vector(31 downto 0);
    signal s_DMemAddr     : std_logic_vector(31 downto 0);
    signal s_DMemData_out : std_logic_vector(31 downto 0);
    signal s_DMemWr       : std_logic;
    signal s_DMemData_in  : std_logic_vector(31 downto 0);
    signal s_PC           : std_logic_vector(31 downto 0);
    signal s_Inst         : std_logic_vector(31 downto 0);
    signal s_ALUResult    : std_logic_vector(31 downto 0);

    constant c_CLK_PERIOD : time := 10 ns;

    -------------------------------------------------------------------
    -- Simple Instruction Memory
    -------------------------------------------------------------------
    type t_IMem is array(0 to 31) of std_logic_vector(31 downto 0);
    signal IMem : t_IMem := (
        -- ADDI: compute an address
        0 => x"00500093", -- addi x1,x0,5
        -- SW: store x1 to memory[0]
        1 => x"00102023", -- sw x1,0(x0)
        -- LW: load x2 from memory[0]
        2 => x"00002103", -- lw x2,0(x0)
        -- XORI: transform data
        3 => x"0FF14113", -- xori x2,x2,0xFF
        -- SLLI: shift left
        4 => x"00111193", -- slli x3,x2,1
        -- SLT: comparison (x3 < x1)
        5 => x"0011A213", -- slt x4,x3,x1
        -- BNE: branch if not equal (x4!=0) skip next ADDI
        6 => x"00422463", -- bne x4,x0,8
        -- ADDI (skipped if branch taken)
        7 => x"00100293", -- addi x5,x0,1
        -- ADDI (executed after branch)
        8 => x"00A00293", -- addi x5,x0,10
        -- NOP
        9 => x"00000013",
        others => x"00000000"
    );

    -------------------------------------------------------------------
    -- Simple Data Memory
    -------------------------------------------------------------------
    type t_DMem is array(0 to 63) of std_logic_vector(31 downto 0);
    signal DMem : t_DMem := (others => x"00000000");

begin
    -------------------------------------------------------------------
    -- Instantiate processor
    -------------------------------------------------------------------
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

    -------------------------------------------------------------------
    -- Clock process
    -------------------------------------------------------------------
    CLK_process: process
    begin
        s_CLK <= '0';
        wait for c_CLK_PERIOD/2;
        s_CLK <= '1';
        wait for c_CLK_PERIOD/2;
    end process;

    -------------------------------------------------------------------
    -- IMem behavior (word addressed)
    -------------------------------------------------------------------
    IMem_process: process(s_IMemAddr)
    begin
        s_IMemData <= IMem(to_integer(unsigned(s_IMemAddr(7 downto 2))));
    end process;

    -------------------------------------------------------------------
    -- DMem behavior
    -------------------------------------------------------------------
    DMem_process: process(s_CLK)
    begin
        if rising_edge(s_CLK) then
            if s_DMemWr = '1' then
                DMem(to_integer(unsigned(s_DMemAddr(7 downto 2)))) <= s_DMemData_out;
            end if;
        end if;
        s_DMemData_in <= DMem(to_integer(unsigned(s_DMemAddr(7 downto 2))));
    end process;

    -------------------------------------------------------------------
    -- Stimulus
    -------------------------------------------------------------------
    stim_proc: process
    begin
        s_RST <= '1';
        wait for 20 ns;
        s_RST <= '0';

        -- Finish instructions
        wait for c_CLK_PERIOD * 40;
        wait;
    end process;

end behavior;
