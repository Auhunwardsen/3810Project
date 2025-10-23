library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity processor is
	port(	i_CLK       : in  std_logic;
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
		o_ALUResult : out std_logic_vector(31 downto 0));
end processor;

architecture structural of processor is

    -- Component declarations
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

    component alu_control is
        port (
            i_ALUOp     : in  std_logic_vector(2 downto 0);
            i_Funct3    : in  std_logic_vector(2 downto 0);
            i_Funct7_5  : in  std_logic;
            o_ALUCtrl   : out std_logic_vector(3 downto 0)
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

    -- Register file component (you would need to implement this)
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

    -- Signal declarations

    -- Fetch signals
    signal s_PC         : std_logic_vector(31 downto 0);
    signal s_PCplus4    : std_logic_vector(31 downto 0);
    signal s_Instr      : std_logic_vector(31 downto 0);
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
    signal s_ALUResult  : std_logic_vector(31 downto 0);
    signal s_Zero       : std_logic;
    signal s_Overflow   : std_logic;
    
    -- Branch signals
    signal s_BranchTaken: std_logic;
    signal s_BranchAddr : std_logic_vector(31 downto 0);

begin
    -- Fetch unit
    u_fetch: fetch
        port map (
            i_CLK        => i_CLK,
            i_RST        => i_RST,
            i_UseNextAdr => s_UseNextAdr,
            i_Stall      => s_Stall,
            i_NextAdr    => s_NextAdr,
            o_IMemAdr    => o_IMemAddr,
            i_IMemData   => i_IMemData,
            o_PC         => s_PC,
            o_PCplus4    => s_PCplus4,
            o_Instr      => s_Instr
        );
    
    -- Control unit
    u_control: control
        port map (
            i_opcode   => s_Instr(6 downto 0),
            o_branch   => s_Branch,
            o_memRead  => s_MemRead,
            o_memToReg => s_MemToReg,
            o_ALUOp    => s_ALUOp,
            o_memWrite => s_MemWrite,
            o_ALUSrc   => s_ALUSrc,
            o_regWrite => s_RegWrite
        );
    
    -- ALU control unit
    u_alu_control: work.alu_control
        port map (
            i_ALUOp    => s_ALUOp,
            i_Funct3   => s_Instr(14 downto 12),
            i_Funct7_5 => s_Instr(30),
            o_ALUCtrl  => s_ALUCtrl
        );
    
    -- Register file
    u_regfile: regfile
        port map (
            i_CLK       => i_CLK,
            i_RST       => i_RST,
            i_WE        => s_RegWrite,
            i_RS1       => s_Instr(19 downto 15),
            i_RS2       => s_Instr(24 downto 20),
            i_RD        => s_Instr(11 downto 7),
            i_WriteData => s_WriteData,
            o_RS1Data   => s_RS1Data,
            o_RS2Data   => s_RS2Data
        );
    
    -- Immediate generator
    u_immgen: immgen
        port map (
            i_instr => s_Instr,
            o_imm   => s_Immediate
        );
    
    -- ALU source mux
    u_alu_src_mux: mux2t1_n
        port map (
            i_S  => s_ALUSrc,
            i_D0 => s_RS2Data,
            i_D1 => s_Immediate,
            o_O  => s_ALUIn2
        );
    
    -- ALU
    s_ALUIn1 <= s_RS1Data;
    u_alu: alu
        port map (
            i_ALUCtrl  => s_ALUCtrl,
            i_A        => s_ALUIn1,
            i_B        => s_ALUIn2,
            o_Result   => s_ALUResult,
            o_Zero     => s_Zero,
            o_Overflow => s_Overflow
        );
    
    -- Branch address adder
    u_branch_adder: adder_n
        port map (
            iA   => s_PC,
            iB   => s_Immediate,
            oSum => s_BranchAddr
        );
    
    -- Data memory write data
    o_DMemAddr <= s_ALUResult;
    o_DMemData <= s_RS2Data;
    o_DMemWr   <= s_MemWrite;
    
    -- Memory to register mux
    u_mem_to_reg_mux: mux2t1_n
        port map (
            i_S  => s_MemToReg,
            i_D0 => s_ALUResult,
            i_D1 => i_DMemData,
            o_O  => s_WriteData
        );
    
    -- Branch logic
    s_BranchTaken <= s_Branch and s_Zero;
    s_UseNextAdr <= s_BranchTaken;
    s_NextAdr <= s_BranchAddr when s_BranchTaken = '1' else s_PCplus4;
    
    -- Stall logic (not implemented yet)
    s_Stall <= '0';
    
    -- Output connections for debugging
    o_PC <= s_PC;
    o_Inst <= s_Instr;
    o_ALUResult <= s_ALUResult;

end structural;