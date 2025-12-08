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

  -- Forwarding and hazard detection components
  component forwarding_unit is
    port(
      i_IDEX_RS1       : in std_logic_vector(4 downto 0);
      i_IDEX_RS2       : in std_logic_vector(4 downto 0);
      i_EXMEM_RD       : in std_logic_vector(4 downto 0);
      i_MEMWB_RD       : in std_logic_vector(4 downto 0);
      i_EXMEM_RegWrite : in std_logic;
      i_MEMWB_RegWrite : in std_logic;
      o_Forward_A      : out std_logic_vector(1 downto 0);
      o_Forward_B      : out std_logic_vector(1 downto 0)
    );
  end component;

  component hazard_detection is
    port(
      i_IDEX_MemRead  : in std_logic;
      i_IDEX_RD       : in std_logic_vector(4 downto 0);
      i_IFID_RS1      : in std_logic_vector(4 downto 0);
      i_IFID_RS2      : in std_logic_vector(4 downto 0);
      i_Branch        : in std_logic;
      i_Jump          : in std_logic;
      o_PCWrite       : out std_logic;
      o_IFID_Write    : out std_logic;
      o_ControlMux    : out std_logic;
      o_IFID_Flush    : out std_logic;
      o_IDEX_Flush    : out std_logic
    );
  end component;

  component mux3t1_n is
    generic(N : integer := 32);
    port(
      i_S   : in  std_logic_vector(1 downto 0);
      i_D0  : in  std_logic_vector(N-1 downto 0);
      i_D1  : in  std_logic_vector(N-1 downto 0);
      i_D2  : in  std_logic_vector(N-1 downto 0);
      o_O   : out std_logic_vector(N-1 downto 0)
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
      i_Branch    : in  std_logic;
      i_BranchAddr: in  std_logic_vector(31 downto 0);
      i_BranchTaken: in std_logic;
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_WriteData : in  std_logic_vector(31 downto 0);
      i_RS2Data   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr     : in  std_logic_vector(31 downto 0);
      
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemWrite  : out std_logic;
      o_MemRead   : out std_logic;
      o_Branch    : out std_logic;
      o_BranchAddr: out std_logic_vector(31 downto 0);
      o_BranchTaken: out std_logic;
      o_WriteData : out std_logic_vector(31 downto 0);
      o_PCplus4   : out std_logic_vector(31 downto 0);
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
      i_MemData   : in  std_logic_vector(31 downto 0);
      i_ALUResult : in  std_logic_vector(31 downto 0);
      i_PCplus4   : in  std_logic_vector(31 downto 0);
      i_RDAddr    : in  std_logic_vector(4 downto 0);
      i_Instr     : in  std_logic_vector(31 downto 0);
      o_RegWrite  : out std_logic;
      o_MemToReg  : out std_logic;
      o_MemData   : out std_logic_vector(31 downto 0);
      o_ALUResult : out std_logic_vector(31 downto 0);
      o_PCplus4   : out std_logic_vector(31 downto 0);
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
  signal s_Instr_Fetch: std_logic_vector(31 downto 0);
  
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
  signal s_RS1Data_final : std_logic_vector(31 downto 0);  -- After WB→ID forwarding check
  signal s_RS2Data_final : std_logic_vector(31 downto 0);  -- After WB→ID forwarding check
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
  signal s_IsLUI      : std_logic;

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
  signal s_EXMEM_RegWrite   : std_logic;
  signal s_EXMEM_MemToReg   : std_logic;
  signal s_EXMEM_MemWrite   : std_logic;
  signal s_EXMEM_MemRead    : std_logic;
  signal s_EXMEM_Branch     : std_logic;
  signal s_EXMEM_BranchAddr : std_logic_vector(31 downto 0);
  signal s_EXMEM_BranchTaken: std_logic;
  signal s_EXMEM_WriteData  : std_logic_vector(31 downto 0);
  signal s_EXMEM_PCplus4    : std_logic_vector(31 downto 0);
  signal s_EXMEM_ALUResult  : std_logic_vector(31 downto 0);
  signal s_EXMEM_RS2Data    : std_logic_vector(31 downto 0);
  signal s_EXMEM_RDAddr     : std_logic_vector(4 downto 0);
  signal s_EXMEM_Inst       : std_logic_vector(31 downto 0);

  -- MEM/WB pipeline register outputs
  signal s_MEMWB_RegWrite  : std_logic;
  signal s_MEMWB_MemToReg  : std_logic;
  signal s_MEMWB_ALUResult : std_logic_vector(31 downto 0);
  signal s_MEMWB_MemData   : std_logic_vector(31 downto 0);
  signal s_MEMWB_PCplus4   : std_logic_vector(31 downto 0);
  signal s_MEMWB_RDAddr    : std_logic_vector(4 downto 0);
  signal s_MEMWB_Inst      : std_logic_vector(31 downto 0);

  -- Hazard detection signals
  signal s_PCWrite       : std_logic;  -- PC write enable from hazard detection
  signal s_IFID_Write    : std_logic;  -- IF/ID write enable from hazard detection
  signal s_ControlMux    : std_logic;  -- Control mux select (1 = insert NOP)
  signal s_IFID_Flush    : std_logic;  -- IF/ID flush signal
  signal s_IDEX_Flush    : std_logic;  -- ID/EX flush signal
  signal s_Jump          : std_logic;  -- Jump signal for hazard detection

  -- Forwarding signals
  signal s_Forward_A     : std_logic_vector(1 downto 0);  -- Forward control for ALU input A
  signal s_Forward_B     : std_logic_vector(1 downto 0);  -- Forward control for ALU input B
  signal s_ALU_A         : std_logic_vector(31 downto 0);  -- ALU input A after forwarding
  signal s_ALU_B         : std_logic_vector(31 downto 0);  -- ALU input B after forwarding
  signal s_ALU_B_forwarded : std_logic_vector(31 downto 0);  -- RS2 data after forwarding (for stores)

  -- Control signals (potentially replaced with NOPs)
  signal s_RegWrite_ID   : std_logic;  -- RegWrite before ControlMux
  signal s_MemToReg_ID   : std_logic;  -- MemToReg before ControlMux
  signal s_MemWrite_ID   : std_logic;  -- MemWrite before ControlMux
  signal s_MemRead_ID    : std_logic;  -- MemRead before ControlMux
  signal s_Branch_ID     : std_logic;  -- Branch before ControlMux
  signal s_ALUSrc_ID     : std_logic;  -- ALUSrc before ControlMux
  signal s_ALUOp_ID      : std_logic_vector(2 downto 0);  -- ALUOp before ControlMux

begin

  -------------------------------------------------------------------------
  -- MEMORY MODULES (Instruction & Data Memory)
  -------------------------------------------------------------------------
  -- TODO: This is required to be your final input to your instruction memory. This provides a feasible method to externally load the memory module which means that the synthesis tool must assume it knows nothing about the values stored in the instruction memory. If this is not included, much, if not all of the design is optimized out because the synthesis tool will believe the memory to be all zeros.
  with iInstLd select
    s_IMemAddr <= s_NextInstAddr when '0',
                  iInstAddr when others;

  -- Instruction Memory (accessed in IF stage)
  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  -- Data Memory (accessed in MEM stage)
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  -------------------------------------------------------------------------
  -- STAGE 1: INSTRUCTION FETCH (IF)
  -------------------------------------------------------------------------
  -- Fetches instruction from memory and increments PC
  -- PC can be stalled by hazard detection unit
  u_fetch: fetch
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_UseNextAdr => s_UseNextAdr,
      i_Stall      => not s_PCWrite,  -- Stall when PC write disabled
      i_NextAdr    => s_NextAdr,
      o_IMemAdr    => s_NextInstAddr,
      i_IMemData   => s_Inst,  -- Instruction from memory
      o_PC         => s_PC,
      o_PCplus4    => s_PCplus4,
      o_Instr      => s_Instr_Fetch  -- Fetch unit output instruction
    );

  -------------------------------------------------------------------------
  -- PIPELINE REGISTER: IF/ID
  -------------------------------------------------------------------------
  -- Latches PC, PC+4, and instruction between IF and ID stages
  -- Can be stalled or flushed by hazard detection unit
  u_IFID: IFID_reg
    port map (
      i_CLK     => iCLK,
      i_RST     => iRST,
      i_WE      => s_IFID_Write,  -- Write enable from hazard detection
      i_flush   => s_IFID_Flush,  -- Flush on control hazards
      i_PC      => s_PC,
      i_PCplus4 => s_PCplus4,
      i_Instr   => s_Instr_Fetch,  -- Use fetch unit output
      o_PC      => s_IFID_PC,
      o_PCplus4 => s_IFID_PCplus4,
      o_Instr   => s_IFID_Inst
    );

  -------------------------------------------------------------------------
  -- STAGE 2: INSTRUCTION DECODE (ID)
  -------------------------------------------------------------------------
  -- Decodes instruction, reads registers, generates control signals
  -- Control Unit: generates all control signals based on opcode
  u_control: control
    port map (
      i_opcode   => s_IFID_Inst(6 downto 0),
      o_branch   => s_Branch_ID,
      o_memRead  => s_MemRead_ID,
      o_memToReg => s_MemToReg_ID,
      o_ALUOp    => s_ALUOp_ID,
      o_memWrite => s_MemWrite_ID,
      o_ALUSrc   => s_ALUSrc_ID,
      o_regWrite => s_RegWrite_ID
    );

  -- Detect jump instructions for hazard detection
  s_Jump <= '1' when (s_IFID_Inst(6 downto 0) = "1101111" or  -- JAL
                      s_IFID_Inst(6 downto 0) = "1100111")     -- JALR
             else '0';

  -- Hazard Detection Unit: detects load-use and control hazards
  u_hazard_detection: hazard_detection
    port map (
      i_IDEX_MemRead  => s_IDEX_MemRead,
      i_IDEX_RD       => s_IDEX_RDAddr,
      i_IFID_RS1      => s_IFID_Inst(19 downto 15),
      i_IFID_RS2      => s_IFID_Inst(24 downto 20),
      i_Branch        => s_BranchTaken,  -- Taken branch from ID stage
      i_Jump          => s_Jump,
      o_PCWrite       => s_PCWrite,
      o_IFID_Write    => s_IFID_Write,
      o_ControlMux    => s_ControlMux,
      o_IFID_Flush    => s_IFID_Flush,
      o_IDEX_Flush    => s_IDEX_Flush
    );

  -- Control Mux: inserts NOP when load-use hazard detected
  -- When ControlMux = '1', all control signals become '0' (NOP)
  s_RegWrite <= '0' when s_ControlMux = '1' else s_RegWrite_ID;
  s_MemToReg <= '0' when s_ControlMux = '1' else s_MemToReg_ID;
  s_MemWrite <= '0' when s_ControlMux = '1' else s_MemWrite_ID;
  s_MemRead  <= '0' when s_ControlMux = '1' else s_MemRead_ID;
  s_Branch   <= '0' when s_ControlMux = '1' else s_Branch_ID;
  s_ALUSrc   <= '0' when s_ControlMux = '1' else s_ALUSrc_ID;
  s_ALUOp    <= "000" when s_ControlMux = '1' else s_ALUOp_ID;

  -- Register File: reads two source registers
  u_regfile: regfile
    port map (
      i_CLK       => iCLK,
      i_RST       => iRST,
      i_WE        => s_RegWr,
      i_RS1       => s_IFID_Inst(19 downto 15),
      i_RS2       => s_IFID_Inst(24 downto 20),
      i_RD        => s_RegWrAddr,
      i_WriteData => s_RegWrData,
      o_RS1Data   => s_RS1Data,
      o_RS2Data   => s_RS2Data
    );

  -- Immediate Generator: extracts and sign-extends immediate values
  u_immgen: immgen
    port map (
      i_instr     => s_IFID_Inst,
      o_imm       => s_Immediate
    );

  -- WB→ID Forwarding: Forward from WB stage to ID stage for branch/jump comparisons
  -- This ensures branch decisions use the most recent data
  process(s_RS1Data, s_RS2Data, s_IFID_Inst, 
          s_MEMWB_RegWrite, s_MEMWB_RDAddr, s_WriteData)
    variable v_RS1_addr : std_logic_vector(4 downto 0);
    variable v_RS2_addr : std_logic_vector(4 downto 0);
  begin
    v_RS1_addr := s_IFID_Inst(19 downto 15);
    v_RS2_addr := s_IFID_Inst(24 downto 20);
    
    -- Forward RS1 from WB stage only (for branches in ID stage)
    if (s_MEMWB_RegWrite = '1' and s_MEMWB_RDAddr = v_RS1_addr and v_RS1_addr /= "00000") then
      s_RS1Data_final <= s_WriteData;  -- Forward from WB stage
    else
      s_RS1Data_final <= s_RS1Data;
    end if;
    
    -- Forward RS2 from WB stage only (for branches in ID stage)
    if (s_MEMWB_RegWrite = '1' and s_MEMWB_RDAddr = v_RS2_addr and v_RS2_addr /= "00000") then
      s_RS2Data_final <= s_WriteData;  -- Forward from WB stage
    else
      s_RS2Data_final <= s_RS2Data;
    end if;
  end process;

  -------------------------------------------------------------------------
  -- PIPELINE REGISTER: ID/EX
  -------------------------------------------------------------------------
  -- Latches control signals, register data, and immediate between ID and EX stages
  -- Can be flushed by hazard detection unit
  u_IDEX: IDEX_reg
    port map (
      i_CLK       => iCLK,
      i_RST       => iRST,
      i_WE        => '1',  -- Always write (no stalling at this register)
      i_flush     => s_IDEX_Flush,  -- Flush on control hazards
      i_RegWrite  => s_RegWrite,
      i_MemToReg  => s_MemToReg,
      i_MemWrite  => s_MemWrite,
      i_MemRead   => s_MemRead,
      i_Branch    => s_Branch,
      i_ALUSrc    => s_ALUSrc,
      i_ALUOp     => s_ALUOp,
      i_PC        => s_IFID_PC,
      i_PCplus4   => s_IFID_PCplus4,
      i_RS1Data   => s_RS1Data_final,
      i_RS2Data   => s_RS2Data_final,
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

  -------------------------------------------------------------------------
  -- STAGE 3: EXECUTE (EX)
  -------------------------------------------------------------------------
  -- Performs ALU operations with data forwarding
  
  -- Forwarding Unit: detects when to forward data from later stages
  u_forwarding: forwarding_unit
    port map (
      i_IDEX_RS1       => s_IDEX_RS1Addr,
      i_IDEX_RS2       => s_IDEX_RS2Addr,
      i_EXMEM_RD       => s_EXMEM_RDAddr,
      i_MEMWB_RD       => s_MEMWB_RDAddr,
      i_EXMEM_RegWrite => s_EXMEM_RegWrite,
      i_MEMWB_RegWrite => s_MEMWB_RegWrite,
      o_Forward_A      => s_Forward_A,
      o_Forward_B      => s_Forward_B
    );

  -- Forwarding Mux A: selects data for ALU input A (RS1)
  -- 00 = ID/EX register, 01 = MEM/WB (WB data), 10 = EX/MEM (ALU result)
  u_forward_mux_a: mux3t1_n
    generic map(N => 32)
    port map (
      i_S  => s_Forward_A,
      i_D0 => s_IDEX_RS1Data,        -- From ID/EX register
      i_D1 => s_WriteData,           -- From WB stage
      i_D2 => s_EXMEM_ALUResult,     -- From EX/MEM register
      o_O  => s_ALU_A
    );

  -- Forwarding Mux B: selects data for ALU input B (RS2 or immediate)
  -- Also used for store instructions
  u_forward_mux_b: mux3t1_n
    generic map(N => 32)
    port map (
      i_S  => s_Forward_B,
      i_D0 => s_IDEX_RS2Data,        -- From ID/EX register
      i_D1 => s_WriteData,           -- From WB stage
      i_D2 => s_EXMEM_ALUResult,     -- From EX/MEM register
      o_O  => s_ALU_B_forwarded
    );

  -- ALU Control: generates ALU operation code from instruction fields
  u_alu_control: alu_control
    port map (
      i_ALUOp    => s_IDEX_ALUOp,
      i_Funct3   => s_IDEX_Instr(14 downto 12),
      i_Funct7_5 => s_IDEX_Instr(30),
      o_ALUCtrl  => s_ALUCtrl
    );

  -- ALU Source Mux: selects between forwarded RS2 data or immediate
  u_alu_src_mux: mux2t1_n
    generic map(N => 32)
    port map (
      i_S  => s_IDEX_ALUSrc,
      i_D0 => s_ALU_B_forwarded,     -- Forwarded RS2 data
      i_D1 => s_IDEX_Immediate,      -- Immediate value
      o_O  => s_ALUIn2
    );

  -- ALU Input A Selection: AUIPC uses PC, LUI uses zero, others use forwarded RS1
  process(s_IDEX_Instr, s_ALU_A, s_IDEX_PC)
    variable v_IsAUIPC : std_logic;
    variable v_IsLUI : std_logic;
  begin
    v_IsAUIPC := '1' when s_IDEX_Instr(6 downto 0) = "0010111" else '0';
    v_IsLUI := '1' when s_IDEX_Instr(6 downto 0) = "0110111" else '0';
    
    if v_IsAUIPC = '1' then
      s_ALUIn1 <= s_IDEX_PC;  -- AUIPC: use PC
    elsif v_IsLUI = '1' then
      s_ALUIn1 <= (others => '0');  -- LUI: use 0
    else
      s_ALUIn1 <= s_ALU_A;  -- Normal: use forwarded RS1
    end if;
  end process;

  -- ALU: performs arithmetic and logic operations
  u_alu_inst: alu
    port map (
      i_ALUCtrl  => s_ALUCtrl,
      i_A        => s_ALUIn1,
      i_B        => s_ALUIn2,
      o_Result   => s_ALUResult,
      o_Zero     => s_Zero,
      o_Overflow => s_Overflow
    );

  -------------------------------------------------------------------------
  -- PIPELINE REGISTER: EX/MEM
  -------------------------------------------------------------------------
  -- Latches ALU result, memory write data, and control signals between EX and MEM stages
  u_EXMEM: EXMEM_reg
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_WE         => '1',  -- Always write (no stalling at this register)
      i_flush      => '0',  -- No flushing at this stage
      i_RegWrite   => s_IDEX_RegWrite,
      i_MemToReg   => s_IDEX_MemToReg,
      i_MemWrite   => s_IDEX_MemWrite,
      i_MemRead    => s_IDEX_MemRead,
      i_Branch     => s_IDEX_Branch,
      i_BranchAddr => s_BranchAddr,
      i_BranchTaken=> s_BranchTaken,
      i_PCplus4    => s_IDEX_PCplus4,
      i_ALUResult  => s_ALUResult,
      i_WriteData  => s_ALU_B_forwarded,  -- Use forwarded RS2 for stores
      i_RS2Data    => s_ALU_B_forwarded,  -- Use forwarded RS2 for stores
      i_RDAddr     => s_IDEX_RDAddr,
      i_Instr      => s_IDEX_Instr,
      o_RegWrite   => s_EXMEM_RegWrite,
      o_MemToReg   => s_EXMEM_MemToReg,
      o_MemWrite   => s_EXMEM_MemWrite,
      o_MemRead    => s_EXMEM_MemRead,
      o_Branch     => s_EXMEM_Branch,
      o_BranchAddr => s_EXMEM_BranchAddr,
      o_BranchTaken=> s_EXMEM_BranchTaken,
      o_WriteData  => s_EXMEM_WriteData,
      o_PCplus4    => s_EXMEM_PCplus4,
      o_ALUResult  => s_EXMEM_ALUResult,
      o_RS2Data    => s_EXMEM_RS2Data,
      o_RDAddr     => s_EXMEM_RDAddr,
      o_Instr      => s_EXMEM_Inst
    );

  -------------------------------------------------------------------------
  -- STAGE 4: MEMORY (MEM)
  -------------------------------------------------------------------------
  -- Accesses data memory for load/store instructions
  -- Data memory instantiated above, controlled by signals:
  --   s_DMemAddr <= s_EXMEM_ALUResult (address from ALU)
  --   s_DMemData <= s_EXMEM_RS2Data (write data for stores)
  --   s_DMemWr   <= s_EXMEM_MemWrite (write enable)
  --   s_DMemOut  -> passes to MEM/WB register

  -------------------------------------------------------------------------
  -- PIPELINE REGISTER: MEM/WB
  -------------------------------------------------------------------------
  -- Latches memory read data and ALU result between MEM and WB stages
  u_MEMWB: MEMWB_reg
    port map (
      i_CLK        => iCLK,
      i_RST        => iRST,
      i_WE         => '1',  -- Always write (no stalling at this register)
      i_flush      => '0',  -- No flushing at this stage
      i_RegWrite   => s_EXMEM_RegWrite,
      i_MemToReg   => s_EXMEM_MemToReg,
      i_ALUResult  => s_EXMEM_ALUResult,
      i_MemData    => s_DMemOut,
      i_RDAddr     => s_EXMEM_RDAddr,
      i_Instr      => s_EXMEM_Inst,
      i_PCplus4    => s_EXMEM_PCplus4,
      o_RegWrite   => s_MEMWB_RegWrite,
      o_MemToReg   => s_MEMWB_MemToReg,
      o_ALUResult  => s_MEMWB_ALUResult,
      o_MemData    => s_MEMWB_MemData,
      o_RDAddr     => s_MEMWB_RDAddr,
      o_Instr      => s_MEMWB_Inst,
      o_PCplus4    => s_MEMWB_PCplus4
    );

  -------------------------------------------------------------------------
  -- STAGE 5: WRITE BACK (WB)
  -------------------------------------------------------------------------
  -- Selects data to write back to register file
  -- Write-back connections defined at end of file:
  --   s_RegWr     <= s_MEMWB_RegWrite
  --   s_RegWrAddr <= s_MEMWB_RDAddr
  --   s_RegWrData <= memory data OR ALU result (based on MemToReg)

  -------------------------------------------------------------------------
  -- ID/EX STAGE COMPONENTS (Branch Resolution)
  -------------------------------------------------------------------------
  -- Note: For software-scheduled pipeline, branches resolved in ID/EX
  -- boundary to avoid control hazards via software scheduling
  
  -- Branch Address Adder: computes PC + immediate for branch target
  u_branch_adder: adder_n
    generic map(N => 32)
    port map (
      iA   => s_IFID_PC,
      iB   => s_Immediate,
      oSum => s_BranchAddr
    );

  -------------------------------------------------------------------------
  -- MEM STAGE CONNECTIONS
  -------------------------------------------------------------------------
  -- Data memory signals driven by EX/MEM pipeline register outputs
  s_DMemAddr <= s_EXMEM_ALUResult;   -- Memory address from ALU
  s_DMemData <= s_EXMEM_RS2Data;     -- Write data for stores
  s_DMemWr   <= s_EXMEM_MemWrite;    -- Write enable

  -------------------------------------------------------------------------
  -- WB STAGE LOGIC
  -------------------------------------------------------------------------
  -- Write Data Selection: chooses between ALU result and memory data
  process(s_MEMWB_Inst, s_MEMWB_MemToReg, s_MEMWB_ALUResult, s_MEMWB_MemData, s_MEMWB_PCplus4)
    variable v_LoadData : std_logic_vector(31 downto 0);
    variable v_IsJAL : std_logic;
    variable v_IsJALR : std_logic;
  begin
    v_IsJAL := '1' when s_MEMWB_Inst(6 downto 0) = "1101111" else '0';
    v_IsJALR := '1' when s_MEMWB_Inst(6 downto 0) = "1100111" else '0';
    
    if v_IsJAL = '1' or v_IsJALR = '1' then
      -- JAL/JALR write PC+4 to register (return address) - use PCplus4 from pipeline
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
  -- Compares RS1 and RS2 to determine if branch should be taken
  process(s_Branch, s_IFID_Inst, s_RS1Data_final, s_RS2Data_final)
    variable v_BranchCond : std_logic;  -- Final branch decision (1=take branch, 0=don't take)
    variable v_Zero : std_logic;        -- 1 if RS1 == RS2 (for BEQ/BNE)
    variable v_LT : std_logic;          -- 1 if RS1 < RS2 (signed comparison, for BLT/BGE)
    variable v_LTU : std_logic;         -- 1 if RS1 < RS2 (unsigned comparison, for BLTU/BGEU)
  begin
    -- Default: don't take branch
    v_BranchCond := '0';
    
    -- Compute all three comparison types in parallel
    v_Zero := '1' when s_RS1Data_final = s_RS2Data_final else '0';                      -- Equal?
    v_LT := '1' when signed(s_RS1Data_final) < signed(s_RS2Data_final) else '0';        -- Signed less than?
    v_LTU := '1' when unsigned(s_RS1Data_final) < unsigned(s_RS2Data_final) else '0';   -- Unsigned less than?
    
    -- If this is a branch instruction, determine which condition to use
    if s_Branch = '1' then
      case s_IFID_Inst(14 downto 12) is  -- funct3 field determines branch type
        when "000" =>  -- BEQ: Branch if Equal
          v_BranchCond := v_Zero;           -- Take if RS1 == RS2
        when "001" =>  -- BNE: Branch if Not Equal
          v_BranchCond := not v_Zero;       -- Take if RS1 != RS2
        when "100" =>  -- BLT: Branch if Less Than (signed)
          v_BranchCond := v_LT;             -- Take if RS1 < RS2 (signed)
        when "101" =>  -- BGE: Branch if Greater or Equal (signed)
          v_BranchCond := not v_LT;         -- Take if RS1 >= RS2 (signed)
        when "110" =>  -- BLTU: Branch if Less Than Unsigned
          v_BranchCond := v_LTU;            -- Take if RS1 < RS2 (unsigned)
        when "111" =>  -- BGEU: Branch if Greater or Equal Unsigned
          v_BranchCond := not v_LTU;        -- Take if RS1 >= RS2 (unsigned)
        when others =>
          v_BranchCond := '0';              -- Invalid funct3, don't branch
      end case;
    end if;
    
    -- Output: 1 = take branch, 0 = continue sequential execution
    s_BranchTaken <= v_BranchCond;
  end process;
  
  -- Next address selection (ID stage for branch/jump resolution)
  process(s_BranchTaken, s_BranchAddr, s_IFID_Inst, s_RS1Data_final, s_Immediate, s_PCplus4)
    variable v_IsJAL : std_logic;
    variable v_IsJALR : std_logic;
    variable v_JALRTarget : std_logic_vector(31 downto 0);
  begin
    v_IsJAL := '1' when s_IFID_Inst(6 downto 0) = "1101111" else '0';
    v_IsJALR := '1' when s_IFID_Inst(6 downto 0) = "1100111" else '0';
    v_JALRTarget := std_logic_vector(unsigned(s_RS1Data_final) + unsigned(s_Immediate));
    
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
  
  -- Output connections for synthesis
  oALUOut <= s_EXMEM_ALUResult; 
  
  -- Register write outputs for testbench - use WB stage signals
  -- RISC-V x0 is hardwired to zero - block writes to register 0
  s_RegWr <= s_MEMWB_RegWrite when s_MEMWB_RDAddr /= "00000" else '0';
  s_RegWrAddr <= s_MEMWB_RDAddr;
  s_RegWrData <= s_WriteData;
  
  -- Control outputs (halt should be detected when WFI reaches WB stage)
  s_Halt <= '1' when s_MEMWB_Inst(6 downto 0) = "1110011" else '0';
  
  -- In RISC-V, arithmetic overflow does NOT generate exceptions for standard instructions
  -- Only report overflow for specific instructions that need it (none in basic RISC-V)
  s_Ovfl <= '0';  -- Always '0' for standard RISC-V instructions
end structure;

