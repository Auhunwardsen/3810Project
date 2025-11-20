-------------------------------------------------------------------------
-- Henry Duwe
-- Department of Electrical and Computer Engineering
-- Iowa State University
-------------------------------------------------------------------------


-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0)); -- TODO: Hook this up to the output of the ALU. It is important for synthesis that you have this output that can effectively be impacted by all other components so they are not optimized away.

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic; -- TODO: use this signal as the final active high data memory write enable signal
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory address input
  signal s_DMemData     : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input
  signal s_DMemOut      : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the data memory output
 
  -- Required register file signals 
  signal s_RegWr        : std_logic; -- TODO: use this signal as the final active high write enable input to the register file
  signal s_RegWrAddr    : std_logic_vector(4 downto 0); -- TODO: use this signal as the final destination register address input
  signal s_RegWrData    : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the final data memory data input

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0); -- Do not assign this signal, assign to s_NextInstAddr instead
  signal s_NextInstAddr : std_logic_vector(N-1 downto 0); -- TODO: use this signal as your intended final instruction memory address input.
  signal s_Inst         : std_logic_vector(N-1 downto 0); -- TODO: use this signal as the instruction signal 

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;  -- TODO: this signal indicates to the simulation that intended program execution has completed. (Use WFI with Opcode: 111 0011)

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;  -- TODO: this signal indicates an overflow exception would have been initiated

  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  -- Component declarations for processor implementation
  component fetch is
    port (
      i_CLK        : in  std_logic;
      i_RST        : in  std_logic;
      i_UseNextAdr : in  std_logic;
      i_Stall      : in  std_logic;
      i_NextAdr    : in  std_logic_vector(31 downto 0);
      o_IMemAdr    : out std_logic_vector(31 downto 0);
      i_IMemData   : in  std_logic_vector(31 downto 0);
      o_PC         : out std_logic_vector(31 downto 0);
      o_PCplus4    : out std_logic_vector(31 downto 0);
      o_Instr      : out std_logic_vector(31 downto 0)
    );
  end component;

  component control is
    port (
      i_opcode   : in  std_logic_vector(6 downto 0);
      o_branch   : out std_logic;
      o_memRead  : out std_logic;
      o_memToReg : out std_logic;
      o_ALUOp    : out std_logic_vector(2 downto 0);
      o_memWrite : out std_logic;
      o_ALUSrc   : out std_logic;
      o_regWrite : out std_logic
    );
  end component;

  component alu is
    port (
      i_ALUCtrl   : in  std_logic_vector(3 downto 0);
      i_A         : in  std_logic_vector(31 downto 0);
      i_B         : in  std_logic_vector(31 downto 0);
      o_Result    : out std_logic_vector(31 downto 0);
      o_Zero      : out std_logic;
      o_Overflow  : out std_logic
    );
  end component;

  component alu_control is
    port (
      i_ALUOp     : in  std_logic_vector(2 downto 0);
      i_Funct3    : in  std_logic_vector(2 downto 0);
      i_Funct7_5  : in  std_logic;
      o_ALUCtrl   : out std_logic_vector(3 downto 0)
    );
  end component;

  component immgen is
    port (
      i_instr     : in  std_logic_vector(31 downto 0);
      o_imm       : out std_logic_vector(31 downto 0)
    );
  end component;

  component adder_n is
    generic (N : integer := 32);
    port (
      iA          : in  std_logic_vector(N-1 downto 0);
      iB          : in  std_logic_vector(N-1 downto 0);
      oSum        : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component mux2t1_n is
    generic (N : integer := 32);
    port (
      i_S         : in  std_logic;
      i_D0        : in  std_logic_vector(N-1 downto 0);
      i_D1        : in  std_logic_vector(N-1 downto 0);
      o_O         : out std_logic_vector(N-1 downto 0)
    );
  end component;

  component regfile is
    port (
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_RS1       : in  std_logic_vector(4 downto 0);
      i_RS2       : in  std_logic_vector(4 downto 0);
      i_RD        : in  std_logic_vector(4 downto 0);
      i_WriteData : in  std_logic_vector(31 downto 0);
      o_RS1Data   : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Pipeline register components
  component IFID_reg is
    port(
      i_CLK     : in  std_logic;
      i_RST     : in  std_logic;
      i_WE      : in  std_logic;
      i_flush   : in  std_logic;
      i_PC      : in  std_logic_vector(31 downto 0);
      i_PCplus4 : in  std_logic_vector(31 downto 0);
      i_Instr   : in  std_logic_vector(31 downto 0);
      o_PC      : out std_logic_vector(31 downto 0);
      o_PCplus4 : out std_logic_vector(31 downto 0);
      o_Instr   : out std_logic_vector(31 downto 0)
    );
  end component;

  component IDEX_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_MemWrite  : in  std_logic;
      i_MemRead   : in  std_logic;
      i_Branch    : in  std_logic;
      i_ALUSrc    : in  std_logic;
      i_ALUOp     : in  std_logic_vector(2 downto 0);
      i_PC        : in  std_logic_vector(31 downto 0);
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_RS1Data   : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_Immediate : in  std_logic_vector(31 downto 0);
      i_RS1Addr   : in  std_logic_vector(4 downto 0);
      i_RS2Addr   : in  std_logic_vector(4 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr     : in  std_logic_vector(31 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_Branch    : out std_logic;
      o_ALUSrc    : out std_logic;
      o_ALUOp     : out std_logic_vector(2 downto 0);
      o_PC        : out std_logic_vector(31 downto 0);
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_RS1Data   : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0);
      o_Immediate : out std_logic_vector(31 downto 0);
      o_RS1Addr   : out std_logic_vector(4 downto 0);
      o_RS2Addr   : out std_logic_vector(4 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0);
      o_Instr     : out std_logic_vector(31 downto 0)
    );
  end component;

  component EXMEM_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_MemWrite  : in  std_logic;
      i_MemRead   : in  std_logic;
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr   : in  std_logic_vector(31 downto 0);
      
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_PCBranch  : out std_logic_vector(31 downto 0);
      o_PCSrc     : out std_logic;
      o_ALUResult : out std_logic_vector(31 downto 0);
      o_RS2Data   : out std_logic_vector(31 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0);
      o_Instr     : out std_logic_vector(31 downto 0)
    );
  end component;

  component MEMWB_reg is
    port(
      i_CLK       : in  std_logic;
      i_RST       : in  std_logic;
      i_WE        : in  std_logic;
      i_flush     : in  std_logic;
      i_RegWrite  : in  std_logic;
      i_MemToReg  : in  std_logic;
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_MemData   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr   : in  std_logic_vector(31 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_PCplus4   : out std_logic_vector(31 downto 0);
      o_ALUResult : out std_logic_vector(31 downto 0);
      o_MemData   : out std_logic_vector(31 downto 0);
      o_RDAddr    : out std_logic_vector(4 downto 0);
      o_Instr     : out std_logic_vector(31 downto 0)
    );
  end component;

  -- Processor internal signals
  signal s_PC         : std_logic_vector(31 downto 0);
  signal s_PCplus4    : std_logic_vector(31 downto 0);
  signal s_UseNextAdr : std_logic;
  signal s_NextAdr    : std_logic_vector(31 downto 0);
  signal s_Stall      : std_logic;
  
  -- Control signals
  signal s_Branch     : std_logic;
  signal s_MemRead    : std_logic;
  signal s_MemToReg   : std_logic;
  signal s_ALUOp      : std_logic_vector(2 downto 0);
  signal s_MemWrite   : std_logic;
  signal s_ALUSrc     : std_logic;
  signal s_RegWrite   : std_logic;
  
  -- ALU control signals
  signal s_ALUCtrl    : std_logic_vector(3 downto 0);
  
  -- Register file signals
  signal s_RS1Data    : std_logic_vector(31 downto 0);
  signal s_RS2Data    : std_logic_vector(31 downto 0);
  signal s_WriteData  : std_logic_vector(31 downto 0);
  
  -- Immediate generator signals
  signal s_Immediate  : std_logic_vector(31 downto 0);
  
  -- ALU signals
  signal s_ALUIn1     : std_logic_vector(31 downto 0);
  signal s_ALUIn2     : std_logic_vector(31 downto 0);
  signal s_ALUIn2_sel : std_logic_vector(31 downto 0);
  signal s_ALUResult  : std_logic_vector(31 downto 0);
  signal s_Zero       : std_logic;
  signal s_Overflow   : std_logic;
  
  -- Branch/Jump signals
  signal s_BranchTaken: std_logic;
  signal s_BranchAddr : std_logic_vector(31 downto 0);
  signal s_IsAUIPC    : std_logic;
  signal s_IsJAL      : std_logic;
  signal s_IsJALR     : std_logic;

  -- Pipeline register signals
  -- IF/ID pipeline register outputs
  signal s_IFID_PC      : std_logic_vector(31 downto 0);
  signal s_IFID_PCplus4 : std_logic_vector(31 downto 0);
  signal s_IFID_Inst    : std_logic_vector(31 downto 0);
  
  -- ID/EX pipeline register outputs  
  signal s_IDEX_RegWrite  : std_logic;
  signal s_IDEX_MemToReg  : std_logic;
  signal s_IDEX_MemWrite  : std_logic;
  signal s_IDEX_MemRead   : std_logic;
  signal s_IDEX_Branch    : std_logic;
  signal s_IDEX_ALUSrc    : std_logic;
  signal s_IDEX_ALUOp     : std_logic_vector(2 downto 0);
  signal s_IDEX_PC        : std_logic_vector(31 downto 0);
  signal s_IDEX_PCplus4   : std_logic_vector(31 downto 0);
  signal s_IDEX_RS1Data   : std_logic_vector(31 downto 0);
  signal s_IDEX_RS2Data   : std_logic_vector(31 downto 0);
  signal s_IDEX_Immediate : std_logic_vector(31 downto 0);
  signal s_IDEX_RS1Addr   : std_logic_vector(4 downto 0);
  signal s_IDEX_RS2Addr   : std_logic_vector(4 downto 0);
  signal s_IDEX_RDAddr    : std_logic_vector(4 downto 0);
  signal s_IDEX_Instr     : std_logic_vector(31 downto 0);
  
  -- EX/MEM pipeline register outputs
  signal s_EXMEM_RegWrite  : std_logic;
  signal s_EXMEM_MemToReg  : std_logic;
  signal s_EXMEM_MemWrite  : std_logic;
  signal s_EXMEM_MemRead   : std_logic;
  signal s_EXMEM_PCplus4   : std_logic_vector(31 downto 0);
  signal s_EXMEM_PCBranch  : std_logic_vector(31 downto 0);
  signal s_EXMEM_PCSrc     : std_logic;
  signal s_EXMEM_ALUResult : std_logic_vector(31 downto 0);
  signal s_EXMEM_RS2Data   : std_logic_vector(31 downto 0);
  signal s_EXMEM_RDAddr    : std_logic_vector(4 downto 0);
  signal s_EXMEM_Inst    : std_logic_vector(31 downto 0);

  -- MEM/WB pipeline register outputs
  signal s_MEMWB_RegWrite  : std_logic;
  signal s_MEMWB_MemToReg  : std_logic;
  signal s_MEMWB_PCplus4   : std_logic_vector(31 downto 0);
  signal s_MEMWB_ALUResult : std_logic_vector(31 downto 0);
  signal s_MEMWB_MemData   : std_logic_vector(31 downto 0);
  signal s_MEMWB_RDAddr    : std_logic_vector(4 downto 0);
  signal s_MEMWB_Inst    : std_logic_vector(31 downto 0);

begin

  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
      iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -- Processor Implementation
  
  -- Fetch unit
  u_fetch: fetch
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_UseNextAdr => s_UseNextAdr,
      i_Stall      => s_Stall,
      i_NextAdr    => s_NextAdr,
      o_IMemAdr    => s_NextInstAddr,
      i_IMemData   => s_Inst,
      o_PC         => s_PC,
      o_PCplus4    => s_PCplus4,
      o_Instr      => open  -- Not needed, we use s_Inst directly
    );

  -- IF/ID Pipeline Register
  u_IFID: IFID_reg
    port map (
      i_CLK     => iCLK,
      i_RST     => iRST,
      i_WE      => '1',  -- Always enabled for software-scheduled pipeline
      i_flush   => '0',  -- No flushing in software-scheduled pipeline
      i_PC      => s_PC,
      i_PCplus4 => s_PCplus4,
      i_Instr   => s_Inst,
      o_PC      => s_IFID_PC,
      o_PCplus4 => s_IFID_PCplus4,
      o_Instr   => s_IFID_Inst
    );

  -- ID/EX Pipeline Register
  u_IDEX: IDEX_reg
    port map (
      i_CLK       => iCLK,
      i_RST       => iRST,
      i_WE        => '1',  -- Always enabled for software-scheduled pipeline
      i_flush     => '0',  -- No flushing in software-scheduled pipeline
      i_RegWrite  => s_RegWrite,
      i_MemToReg  => s_MemToReg,
      i_MemWrite  => s_MemWrite,
      i_MemRead   => s_MemRead,
      i_Branch    => s_Branch,
      i_ALUSrc    => s_ALUSrc,
      i_ALUOp     => s_ALUOp,
      i_PC        => s_IFID_PC,
      i_PCplus4   => s_IFID_PCplus4,
      i_RS1Data   => s_RS1Data,
      i_RS2Data   => s_RS2Data,
      i_Immediate => s_Immediate,
      i_RS1Addr   => s_IFID_Inst(19 downto 15),
      i_RS2Addr   => s_IFID_Inst(24 downto 20),
      i_RDAddr    => s_IFID_Inst(11 downto 7),
      i_Instr     => s_IFID_Inst,
      o_RegWrite  => s_IDEX_RegWrite,
      o_MemToReg  => s_IDEX_MemToReg,
      o_MemWrite  => s_IDEX_MemWrite,
      o_MemRead   => s_IDEX_MemRead,
      o_Branch    => s_IDEX_Branch,
      o_ALUSrc    => s_IDEX_ALUSrc,
      o_ALUOp     => s_IDEX_ALUOp,
      o_PC        => s_IDEX_PC,
      o_PCplus4   => s_IDEX_PCplus4,
      o_RS1Data   => s_IDEX_RS1Data,
      o_RS2Data   => s_IDEX_RS2Data,
      o_Immediate => s_IDEX_Immediate,
      o_RS1Addr   => s_IDEX_RS1Addr,
      o_RS2Addr   => s_IDEX_RS2Addr,
      o_RDAddr    => s_IDEX_RDAddr,
      o_Instr     => s_IDEX_Instr
    );

  -- EX/MEM Pipeline Register
  u_EXMEM: EXMEM_reg
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_WE         => '1',  -- Always enabled for software-scheduled pipeline
      i_flush      => '0',  -- No flushing in software-scheduled pipeline
      i_RegWrite   => s_IDEX_RegWrite,
      i_MemToReg   => s_IDEX_MemToReg,
      i_MemWrite   => s_IDEX_MemWrite,
      i_MemRead    => s_IDEX_MemRead,
      i_PCplus4    => s_IDEX_PCplus4,
      i_ALUResult  => s_ALUResult,
      i_RS2Data    => s_IDEX_RS2Data,
      i_RDAddr     => s_IDEX_RDAddr,
      i_Instr      => s_IDEX_Instr,
      o_RegWrite   => s_EXMEM_RegWrite,
      o_MemToReg   => s_EXMEM_MemToReg,
      o_MemWrite   => s_EXMEM_MemWrite,
      o_MemRead    => s_EXMEM_MemRead,
      o_PCplus4    => s_EXMEM_PCplus4,
      o_ALUResult  => s_EXMEM_ALUResult,
      o_RS2Data    => s_EXMEM_RS2Data,
      o_RDAddr     => s_EXMEM_RDAddr,
      o_Instr      => s_EXMEM_Inst
    );

  -- MEM/WB Pipeline Register
  u_MEMWB: MEMWB_reg
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_WE         => '1',  -- Always enabled for software-scheduled pipeline
      i_flush      => '0',  -- No flushing in software-scheduled pipeline
      i_RegWrite   => s_EXMEM_RegWrite,
      i_MemToReg   => s_EXMEM_MemToReg,
      i_PCplus4    => s_EXMEM_PCplus4,
      i_ALUResult  => s_EXMEM_ALUResult,
      i_MemData    => s_DMemOut,
      i_RDAddr     => s_EXMEM_RDAddr,
      i_Instr      => s_EXMEM_Inst,
      o_RegWrite   => s_MEMWB_RegWrite,
      o_MemToReg   => s_MEMWB_MemToReg,
      o_PCplus4    => s_MEMWB_PCplus4,
      o_ALUResult  => s_MEMWB_ALUResult,
      o_MemData    => s_MEMWB_MemData,
      o_RDAddr     => s_MEMWB_RDAddr,
      o_Instr      => s_MEMWB_Inst
    );
  
  -- Control unit 
  u_control: control
    port map (
      i_opcode   => s_IFID_Inst(6 downto 0), 
      o_branch   => s_Branch,
      o_memRead  => s_MemRead,
      o_memToReg => s_MemToReg,
      o_ALUOp    => s_ALUOp,
      o_memWrite => s_MemWrite,
      o_ALUSrc   => s_ALUSrc,
      o_regWrite => s_RegWrite
    );
  
  -- ALU control unit -- Update by the group: use pipelined signals from ID/EX register
  u_alu_control: alu_control
    port map (
      i_ALUOp    => s_IDEX_ALUOp, 
      i_Funct3   => s_IDEX_Instr(14 downto 12), 
      i_Funct7_5 => s_IDEX_Instr(30), 
      o_ALUCtrl  => s_ALUCtrl
    );
  
  -- Register file -- Update by the group: use pipelined signals
  u_regfile: regfile
    port map (
      i_CLK       => iCLK,
      i_RST       => iRST,
      i_WE        => s_MEMWB_RegWrite, 
      i_RS1       => s_IFID_Inst(19 downto 15),  
      i_RS2       => s_IFID_Inst(24 downto 20), 
      i_RD        => s_MEMWB_RDAddr, 
      i_WriteData => s_WriteData, -- Update by the group: ensure this uses WB stage data
      o_RS1Data   => s_RS1Data,
      o_RS2Data   => s_RS2Data
    );
  
  -- Immediate generator -- Update by the group: use IF/ID register output
  u_immgen: immgen
    port map (
      i_instr => s_IFID_Inst, -- Update by the group: change to s_IFID_Instr for ID stage
      o_imm   => s_Immediate
    );
  
  -- ALU source mux (operates in EX stage with ID/EX register data)
  u_alu_src_mux: mux2t1_n
    generic map(N => 32)
    port map (
      i_S  => s_IDEX_ALUSrc,
      i_D0 => s_IDEX_RS2Data,
      i_D1 => s_IDEX_Immediate,
      o_O  => s_ALUIn2
    );
  
  -- ALU input selection (EX stage logic)
  s_IsAUIPC <= '1' when s_IDEX_Instr(6 downto 0) = "0010111" else '0';
  s_IsJAL   <= '1' when s_IDEX_Instr(6 downto 0) = "1101111" else '0';
  s_IsJALR  <= '1' when s_IDEX_Instr(6 downto 0) = "1100111" else '0';
  
  -- For AUIPC, use PC directly (already includes base address); otherwise use RS1 data
  s_ALUIn1 <= s_IDEX_PC when s_IsAUIPC = '1' else s_IDEX_RS1Data;
  
  -- ALU (operates in EX stage)
  u_alu: alu
    port map (
      i_ALUCtrl  => s_ALUCtrl,
      i_A        => s_ALUIn1,
      i_B        => s_ALUIn2,
      o_Result   => s_ALUResult,
      o_Zero     => s_Zero,
      o_Overflow => s_Overflow
    );
  
  -- Branch address adder (ID stage - for software scheduled, branches resolved early)
  u_branch_adder: adder_n
    generic map(N => 32)
    port map (
      iA   => s_IFID_PC,
      iB   => s_Immediate,
      oSum => s_BranchAddr
    );
  
  -- Data memory connections -- Update by the group: use EX/MEM register outputs for MEM stage
  s_DMemAddr <= s_EXMEM_ALUResult;
  s_DMemData <= s_EXMEM_RS2Data;
  s_DMemWr   <= s_EXMEM_MemWrite;
  
  -- Write data selection with proper load handling (WB stage)
  process(s_MEMWB_Inst, s_MEMWB_MemToReg, s_MEMWB_PCplus4, s_MEMWB_ALUResult, s_MEMWB_MemData)
    variable v_LoadData : std_logic_vector(31 downto 0);
    variable v_IsJAL : std_logic;
    variable v_IsJALR : std_logic;
  begin
    v_IsJAL := '1' when s_MEMWB_Inst(6 downto 0) = "1101111" else '0';
    v_IsJALR := '1' when s_MEMWB_Inst(6 downto 0) = "1100111" else '0';
    
    if v_IsJAL = '1' or v_IsJALR = '1' then
      -- JAL/JALR write PC+4 to register (return address)
      s_WriteData <= s_MEMWB_PCplus4;
    elsif s_MEMWB_MemToReg = '1' then
      -- Load instructions - handle different load types with proper sign extension
      case s_MEMWB_Inst(14 downto 12) is  -- funct3 field for load instructions
        when "000" =>  -- LB (Load Byte) - sign extend byte
          if s_MEMWB_MemData(7) = '1' then
            v_LoadData := x"FFFFFF" & s_MEMWB_MemData(7 downto 0);
          else
            v_LoadData := x"000000" & s_MEMWB_MemData(7 downto 0);
          end if;
          s_WriteData <= v_LoadData;
          
        when "001" =>  -- LH (Load Halfword) - sign extend halfword
          if s_MEMWB_MemData(15) = '1' then
            v_LoadData := x"FFFF" & s_MEMWB_MemData(15 downto 0);
          else
            v_LoadData := x"0000" & s_MEMWB_MemData(15 downto 0);
          end if;
          s_WriteData <= v_LoadData;
          
        when "010" =>  -- LW (Load Word) - full 32-bit word
          s_WriteData <= s_MEMWB_MemData;
          
        when "100" =>  -- LBU (Load Byte Unsigned) - zero extend byte
          s_WriteData <= x"000000" & s_MEMWB_MemData(7 downto 0);
          
        when "101" =>  -- LHU (Load Halfword Unsigned) - zero extend halfword
          s_WriteData <= x"0000" & s_MEMWB_MemData(15 downto 0);
          
        when others =>  -- Default to LW
          s_WriteData <= s_MEMWB_MemData;
      end case;
    else
      -- ALU result for normal operations
      s_WriteData <= s_MEMWB_ALUResult;
    end if;
  end process;
  
  -- Branch condition evaluation (ID stage for software-scheduled pipeline)
  process(s_Branch, s_IFID_Inst, s_RS1Data, s_RS2Data)
    variable v_BranchCond : std_logic;
    variable v_Zero : std_logic;
    variable v_LT : std_logic;
    variable v_LTU : std_logic;
  begin
    v_BranchCond := '0';
    v_Zero := '1' when s_RS1Data = s_RS2Data else '0';
    v_LT := '1' when signed(s_RS1Data) < signed(s_RS2Data) else '0';
    v_LTU := '1' when unsigned(s_RS1Data) < unsigned(s_RS2Data) else '0';
    
    if s_Branch = '1' then
      case s_IFID_Inst(14 downto 12) is  -- funct3 field
        when "000" =>  -- BEQ
          v_BranchCond := v_Zero;
        when "001" =>  -- BNE
          v_BranchCond := not v_Zero;
        when "100" =>  -- BLT
          v_BranchCond := v_LT;
        when "101" =>  -- BGE
          v_BranchCond := not v_LT;
        when "110" =>  -- BLTU
          v_BranchCond := v_LTU;
        when "111" =>  -- BGEU
          v_BranchCond := not v_LTU;
        when others =>
          v_BranchCond := '0';
      end case;
    end if;
    
    s_BranchTaken <= v_BranchCond;
  end process;
  
  -- Next address selection (ID stage for software-scheduled pipeline)
  process(s_BranchTaken, s_BranchAddr, s_IFID_Inst, s_RS1Data, s_Immediate, s_PCplus4)
    variable v_IsJAL : std_logic;
    variable v_IsJALR : std_logic;
    variable v_JALRTarget : std_logic_vector(31 downto 0);
  begin
    v_IsJAL := '1' when s_IFID_Inst(6 downto 0) = "1101111" else '0';
    v_IsJALR := '1' when s_IFID_Inst(6 downto 0) = "1100111" else '0';
    v_JALRTarget := std_logic_vector(unsigned(s_RS1Data) + unsigned(s_Immediate));
    
    if v_IsJAL = '1' then
      s_UseNextAdr <= '1';
      s_NextAdr <= s_BranchAddr;  -- JAL: PC + immediate
    elsif v_IsJALR = '1' then
      s_UseNextAdr <= '1';
      s_NextAdr <= v_JALRTarget;  -- JALR: RS1 + immediate
    elsif s_BranchTaken = '1' then
      s_UseNextAdr <= '1';
      s_NextAdr <= s_BranchAddr;  -- Branch to PC + immediate
    else
      s_UseNextAdr <= '0';
      s_NextAdr <= s_PCplus4;     -- Normal PC + 4
    end if;
  end process;
  
  -- Stall logic (not implemented yet)
  s_Stall <= '0';
  
  -- Output connections -- Update by the group: use pipelined ALU result
  oALUOut <= s_EXMEM_ALUResult; 
  
  -- Register write outputs for testbench -- Update by the group: use WB stage signals
  s_RegWr <= s_MEMWB_RegWrite; 
  s_RegWrAddr <= s_MEMWB_RDAddr;  -- Update by the group: change to s_MEMWB_RDAddr
  s_RegWrData <= s_WriteData; -- Update by the group: ensure this uses final WB stage data
  
  -- Control outputs (halt should be detected when WFI reaches WB stage)
  s_Halt <= '1' when s_MEMWB_Inst(6 downto 0) = "1110011" else '0';
  
  -- In RISC-V, arithmetic overflow does NOT generate exceptions for standard instructions
  -- Only report overflow for specific instructions that need it (none in basic RISC-V)
  s_Ovfl <= '0';  -- Always '0' for standard RISC-V instructions
end structure;

