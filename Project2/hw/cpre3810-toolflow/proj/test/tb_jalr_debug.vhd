-------------------------------------------------------------------------
-- Debug Testbench for JALR Issue
-- Shows pipeline contents each cycle to help identify duplicate write
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_textio.all;
use IEEE.numeric_std.all;
library std;
use std.env.all;
use std.textio.all;

entity tb_jalr_debug is
end tb_jalr_debug;

architecture mixed of tb_jalr_debug is

constant gCLK_HPER : time := 10 ns;
constant cCLK_PER  : time := gCLK_HPER * 2;
constant N : integer := 32;

component RISCV_processor is
  generic (N : integer);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0));
end component;

signal CLK, reset : std_logic := '0';
signal reset_done : std_logic := '0';
signal alu_out : std_logic_vector(N-1 downto 0);

-- Pipeline stage signals (hierarchical access)
alias PC is <<signal MyRiscv.s_PC : std_logic_vector(N-1 downto 0)>>;
alias IFID_Inst is <<signal MyRiscv.s_IFID_Inst : std_logic_vector(N-1 downto 0)>>;
alias IDEX_Inst is <<signal MyRiscv.s_IDEX_Instr : std_logic_vector(N-1 downto 0)>>;
alias EXMEM_Inst is <<signal MyRiscv.s_EXMEM_Inst : std_logic_vector(N-1 downto 0)>>;
alias MEMWB_Inst is <<signal MyRiscv.s_MEMWB_Inst : std_logic_vector(N-1 downto 0)>>;

alias IDEX_RD is <<signal MyRiscv.s_IDEX_RDAddr : std_logic_vector(4 downto 0)>>;
alias EXMEM_RD is <<signal MyRiscv.s_EXMEM_RDAddr : std_logic_vector(4 downto 0)>>;
alias MEMWB_RD is <<signal MyRiscv.s_MEMWB_RDAddr : std_logic_vector(4 downto 0)>>;

alias IDEX_RegWrite is <<signal MyRiscv.s_IDEX_RegWrite : std_logic>>;
alias EXMEM_RegWrite is <<signal MyRiscv.s_EXMEM_RegWrite : std_logic>>;
alias MEMWB_RegWrite is <<signal MyRiscv.s_MEMWB_RegWrite : std_logic>>;

alias regWr is <<signal MyRiscv.s_RegWr : std_logic>>;
alias regWrAddr is <<signal MyRiscv.s_RegWrAddr : std_logic_vector(4 downto 0)>>;
alias regWrData is <<signal MyRiscv.s_RegWrData : std_logic_vector(N-1 downto 0)>>;

alias s_Jump is <<signal MyRiscv.s_Jump : std_logic>>;
alias s_ControlHazard is <<signal MyRiscv.s_ControlHazard : std_logic>>;
alias s_IFID_Flush is <<signal MyRiscv.s_IFID_Flush : std_logic>>;
alias s_IDEX_Flush is <<signal MyRiscv.s_IDEX_Flush : std_logic>>;

alias halt is <<signal MyRiscv.s_Halt : std_logic>>;

begin

  MyRiscv: RISCV_processor
  generic map(N => N)
  port map(
    iCLK      => CLK,
    iRST      => reset,
    iInstLd   => '0',
    iInstAddr => (others => '-'),
    iInstExt  => (others => '-'),
    oALUOut   => alu_out);

  -- Clock generation
  P_CLK: process
  begin
    CLK <= '1';
    wait for gCLK_HPER;
    CLK <= '0';
    wait for gCLK_HPER;
  end process;

  -- Reset
  P_RST: process
  begin
    reset <= '0';
    wait for gCLK_HPER/2;
    reset <= '1';
    wait for gCLK_HPER*2;
    reset <= '0';
    reset_done <= '1';
    wait;
  end process;

  -- Debug output showing pipeline contents
  P_DEBUG: process (CLK)
    variable my_line : LINE;
    variable cycle_cnt : integer := 0;

    -- Helper function to decode instruction name
    function get_instr_name(inst : std_logic_vector(31 downto 0)) return string is
      variable opcode : std_logic_vector(6 downto 0);
    begin
      opcode := inst(6 downto 0);
      if inst = x"00000000" then
        return "NOP     ";
      elsif opcode = "0110111" then
        return "LUI     ";
      elsif opcode = "0010111" then
        return "AUIPC   ";
      elsif opcode = "1101111" then
        return "JAL     ";
      elsif opcode = "1100111" then
        return "JALR    ";
      elsif opcode = "1100011" then
        return "BRANCH  ";
      elsif opcode = "0000011" then
        return "LOAD    ";
      elsif opcode = "0100011" then
        return "STORE   ";
      elsif opcode = "0010011" then
        return "ALUI    ";
      elsif opcode = "0110011" then
        return "ALUR    ";
      elsif inst = x"10500073" then
        return "WFI     ";
      else
        return "UNKNOWN ";
      end if;
    end function;

  begin
    if (rising_edge(CLK) and (reset_done = '1')) then

      -- Print header every 10 cycles
      if (cycle_cnt mod 10 = 0) then
        write(my_line, string'("===================================================================="));
        writeline(output, my_line);
        write(my_line, string'("CYC PC       IF/ID    ID/EX    EX/MEM   MEM/WB   | WB?  Reg  Value   "));
        writeline(output, my_line);
        write(my_line, string'("===================================================================="));
        writeline(output, my_line);
      end if;

      -- Cycle number
      write(my_line, cycle_cnt);
      write(my_line, string'("  "));

      -- PC
      hwrite(my_line, PC);
      write(my_line, string'(" "));

      -- Pipeline stages
      write(my_line, get_instr_name(IFID_Inst));
      write(my_line, string'(" "));
      write(my_line, get_instr_name(IDEX_Inst));
      write(my_line, string'(" "));
      write(my_line, get_instr_name(EXMEM_Inst));
      write(my_line, string'(" "));
      write(my_line, get_instr_name(MEMWB_Inst));
      write(my_line, string'(" | "));

      -- Register write info
      if (regWr = '1') then
        write(my_line, string'("YES  "));
        write(my_line, string'("x"));
        write(my_line, to_integer(unsigned(regWrAddr)));
        write(my_line, string'("   "));
        hwrite(my_line, regWrData);
      else
        write(my_line, string'("NO   ---  --------"));
      end if;

      writeline(output, my_line);

      -- Show control signals if active
      if (s_Jump = '1' or s_ControlHazard = '1' or s_IFID_Flush = '1') then
        write(my_line, string'("    -> Jump="));
        write(my_line, s_Jump);
        write(my_line, string'(" CtrlHaz="));
        write(my_line, s_ControlHazard);
        write(my_line, string'(" IFID_Flush="));
        write(my_line, s_IFID_Flush);
        write(my_line, string'(" IDEX_Flush="));
        write(my_line, s_IDEX_Flush);
        writeline(output, my_line);
      end if;

      if (halt = '1') then
        write(my_line, string'("===================================================================="));
        writeline(output, my_line);
        write(my_line, string'("HALTED at cycle "));
        write(my_line, cycle_cnt);
        writeline(output, my_line);
        stop(2);
      end if;

      cycle_cnt := cycle_cnt + 1;

      -- Safety stop after 50 cycles
      if cycle_cnt > 50 then
        write(my_line, string'("Stopping after 50 cycles"));
        writeline(output, my_line);
        stop(2);
      end if;
    end if;
  end process;

end mixed;
