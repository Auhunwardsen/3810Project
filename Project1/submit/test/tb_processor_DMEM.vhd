library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.RISCV_types.all;

entity tb_processor_DMEM is
end tb_processor_DMEM;

architecture behavior of tb_processor_DMEM is
    -------------------------------------------------------------------
    -- Component Declaration for RISCV_Processor
    -------------------------------------------------------------------
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

    -------------------------------------------------------------------
    -- Signal Declarations
    -------------------------------------------------------------------
    signal s_CLK          : std_logic := '0';
    signal s_RST          : std_logic := '0';
    signal s_InstLd       : std_logic := '0';
    signal s_InstAddr     : std_logic_vector(31 downto 0) := (others => '0');
    signal s_InstExt      : std_logic_vector(31 downto 0) := (others => '0');
    signal s_ALUResult    : std_logic_vector(31 downto 0);

    constant c_CLK_PERIOD : time := 10 ns;

    begin
    -------------------------------------------------------------------
    -- Instantiate RISCV_Processor
    -------------------------------------------------------------------
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
    -- Stimulus
    -------------------------------------------------------------------
    stim_proc: process
    begin
        s_RST <= '1';
        wait for 20 ns;
        s_RST <= '0';

        -- Run simulation for enough cycles
        wait for c_CLK_PERIOD * 40;
        
        assert false report "Test Complete - ALU Result: " & integer'image(to_integer(unsigned(s_ALUResult))) severity note;
        wait;
    end process;

end behavior;

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
