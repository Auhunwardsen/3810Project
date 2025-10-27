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
		o_ALUResult : out std_logic_vector(31 downto 0);
		-- Register write signals for testbench
		o_RegWr     : out std_logic;
		o_RegWrAddr : out std_logic_vector(4 downto 0);
		o_RegWrData : out std_logic_vector(31 downto 0);
		-- Control signals
		o_Halt      : out std_logic;
		o_Ovfl      : out std_logic);
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
    
    -- Branch/Jump signals
    signal s_BranchTaken: std_logic;
    signal s_BranchAddr : std_logic_vector(31 downto 0);
    signal s_JumpAddr   : std_logic_vector(31 downto 0);
    signal s_IsJAL      : std_logic;
    signal s_IsJALR     : std_logic;
    signal s_IsAUIPC    : std_logic;

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
    s_ALUIn1 <= s_PC when s_IsAUIPC = '1' else s_RS1Data;  -- AUIPC uses PC as first operand
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
    
    -- Jump address calculation for JALR
    u_jalr_adder: adder_n
        port map (
            iA   => s_RS1Data,
            iB   => s_Immediate,
            oSum => s_JumpAddr
        );
    
    -- Instruction type detection
    s_IsJAL   <= '1' when s_Instr(6 downto 0) = "1101111" else '0';
    s_IsJALR  <= '1' when s_Instr(6 downto 0) = "1100111" else '0';
    s_IsAUIPC <= '1' when s_Instr(6 downto 0) = "0010111" else '0';
    
    -- Data memory write data
    o_DMemAddr <= s_ALUResult;
    o_DMemData <= s_RS2Data;
    o_DMemWr   <= s_MemWrite;
    
    -- Write data selection for different instruction types
    process(s_IsJAL, s_IsJALR, s_IsAUIPC, s_MemToReg, s_PCplus4, s_ALUResult, i_DMemData)
    begin
        if s_IsJAL = '1' or s_IsJALR = '1' then
            -- JAL/JALR write PC+4 to register
            s_WriteData <= s_PCplus4;
        elsif s_MemToReg = '1' then
            -- Load instructions - write memory data
            s_WriteData <= i_DMemData;
        else
            -- Normal ALU result (including AUIPC which computes PC + immediate in ALU)
            s_WriteData <= s_ALUResult;
        end if;
    end process;
    
    -- Branch logic with proper condition evaluation
    process(s_Branch, s_Instr, s_RS1Data, s_RS2Data, s_Zero, s_ALUResult)
        variable v_BranchCond : std_logic;
    begin
        v_BranchCond := '0';
        
        if s_Branch = '1' then
            case s_Instr(14 downto 12) is  -- funct3 field
                when "000" =>  -- BEQ
                    v_BranchCond := s_Zero;
                when "001" =>  -- BNE
                    v_BranchCond := not s_Zero;
                when "100" =>  -- BLT
                    v_BranchCond := s_ALUResult(31);  -- MSB indicates negative (A < B)
                when "101" =>  -- BGE
                    v_BranchCond := not s_ALUResult(31) or s_Zero;  -- A >= B
                when "110" =>  -- BLTU
                    -- For unsigned comparison, check carry/borrow
                    v_BranchCond := s_ALUResult(31);  -- Simplified - may need more complex logic
                when "111" =>  -- BGEU
                    v_BranchCond := not s_ALUResult(31) or s_Zero;
                when others =>
                    v_BranchCond := '0';
            end case;
        end if;
        
        s_BranchTaken <= v_BranchCond;
    end process;
    
    -- Next address selection
    process(s_BranchTaken, s_IsJAL, s_IsJALR, s_BranchAddr, s_JumpAddr, s_PCplus4)
    begin
        if s_IsJAL = '1' then
            s_UseNextAdr <= '1';
            s_NextAdr <= s_BranchAddr;  -- JAL uses PC + immediate
        elsif s_IsJALR = '1' then
            s_UseNextAdr <= '1';
            s_NextAdr <= s_JumpAddr;    -- JALR uses RS1 + immediate
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
    
    -- Output connections for debugging
    o_PC <= s_PC;
    o_Inst <= s_Instr;
    o_ALUResult <= s_ALUResult;
    
    -- Register write outputs for testbench
    o_RegWr <= s_RegWrite;
    o_RegWrAddr <= s_Instr(11 downto 7);  -- rd field
    o_RegWrData <= s_WriteData;
    
    -- Control outputs
    o_Halt <= '1' when s_Instr(6 downto 0) = "1110011" else '0';  -- WFI/HALT instruction
    o_Ovfl <= s_Overflow;

end structural;