library IEEE;
use IEEE.std_logic_1164.all;

entity tb_alu_control is
end tb_alu_control;

architecture behavior of tb_alu_control is
    -- Component Declaration
    component alu_control
        port(
            i_ALUOp     : in std_logic_vector(2 downto 0);
            i_Funct3    : in std_logic_vector(2 downto 0);
            i_Funct7_5  : in std_logic;
            o_ALUCtrl   : out std_logic_vector(3 downto 0)
        );
    end component;

    -- Inputs
    signal s_ALUOp     : std_logic_vector(2 downto 0) := (others => '0');
    signal s_Funct3    : std_logic_vector(2 downto 0) := (others => '0');
    signal s_Funct7_5  : std_logic := '0';

    -- Outputs
    signal s_ALUCtrl   : std_logic_vector(3 downto 0);

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: alu_control
        port map(
            i_ALUOp     => s_ALUOp,
            i_Funct3    => s_Funct3,
            i_Funct7_5  => s_Funct7_5,
            o_ALUCtrl   => s_ALUCtrl
        );

    -- Comprehensive test process for all ALU control operations
    stim_proc: process
    begin
        -- Test Load/Store instructions (ALUOp = 000)
        s_ALUOp <= "000";
        s_Funct3 <= "000";    -- Not used for this test
        s_Funct7_5 <= '0';    -- Not used for this test
        wait for 100 ns;      -- Result should be 0000 (ADD)
        
        -- Test Branch instructions (ALUOp = 001)
        s_ALUOp <= "001";
        s_Funct3 <= "000";    -- Not used for this test
        s_Funct7_5 <= '0';    -- Not used for this test
        wait for 100 ns;      -- Result should be 0001 (SUB)
        
        -- Test R-type instructions (ALUOp = 010)
        s_ALUOp <= "010";
        
        -- Test ADD
        s_Funct3 <= "000";    -- ADD/SUB
        s_Funct7_5 <= '0';    -- ADD
        wait for 100 ns;      -- Result should be 0000 (ADD)
        
        -- Test SUB
        s_Funct3 <= "000";    -- ADD/SUB
        s_Funct7_5 <= '1';    -- SUB
        wait for 100 ns;      -- Result should be 0001 (SUB)
        
        -- Test AND
        s_Funct3 <= "111";    -- AND
        s_Funct7_5 <= '0';    -- Not used for AND
        wait for 100 ns;      -- Result should be 0010 (AND)
        
        -- Test OR
        s_Funct3 <= "110";    -- OR
        s_Funct7_5 <= '0';    -- Not used for OR
        wait for 100 ns;      -- Result should be 0011 (OR)
        
        -- Test XOR
        s_Funct3 <= "100";    -- XOR
        s_Funct7_5 <= '0';    -- Not used for XOR
        wait for 100 ns;      -- Result should be 0100 (XOR)
        
        -- Test SLL
        s_Funct3 <= "001";    -- SLL
        s_Funct7_5 <= '0';    -- Not used for SLL
        wait for 100 ns;      -- Result should be 0110 (SLL)
        
        -- Test SRL
        s_Funct3 <= "101";    -- SRL/SRA
        s_Funct7_5 <= '0';    -- SRL
        wait for 100 ns;      -- Result should be 0111 (SRL)
        
        -- Test SRA
        s_Funct3 <= "101";    -- SRL/SRA
        s_Funct7_5 <= '1';    -- SRA
        wait for 100 ns;      -- Result should be 1000 (SRA)
        
        -- Test SLT
        s_Funct3 <= "010";    -- SLT
        s_Funct7_5 <= '0';    -- Not used for SLT
        wait for 100 ns;      -- Result should be 1001 (SLT)
        
        -- Test SLTU
        s_Funct3 <= "011";    -- SLTU
        s_Funct7_5 <= '0';    -- Not used for SLTU
        wait for 100 ns;      -- Result should be 1010 (SLTU)
        
        -- Test I-type ALU instructions (ALUOp = 011)
        s_ALUOp <= "011";
        
        -- Test ADDI
        s_Funct3 <= "000";    -- ADDI
        s_Funct7_5 <= '0';    -- Not used for ADDI
        wait for 100 ns;      -- Result should be 0000 (ADD)
        
        -- Test ANDI
        s_Funct3 <= "111";    -- ANDI
        s_Funct7_5 <= '0';    -- Not used for ANDI
        wait for 100 ns;      -- Result should be 0010 (AND)
        
        -- Test ORI
        s_Funct3 <= "110";    -- ORI
        s_Funct7_5 <= '0';    -- Not used for ORI
        wait for 100 ns;      -- Result should be 0011 (OR)
        
        -- Test XORI
        s_Funct3 <= "100";    -- XORI
        s_Funct7_5 <= '0';    -- Not used for XORI
        wait for 100 ns;      -- Result should be 0100 (XOR)
        
        -- Test SLLI
        s_Funct3 <= "001";    -- SLLI
        s_Funct7_5 <= '0';    -- Not used for SLLI
        wait for 100 ns;      -- Result should be 1011 (SLLI)
        
        -- Test SRLI
        s_Funct3 <= "101";    -- SRLI/SRAI
        s_Funct7_5 <= '0';    -- SRLI
        wait for 100 ns;      -- Result should be 1100 (SRLI)
        
        -- Test SRAI
        s_Funct3 <= "101";    -- SRLI/SRAI
        s_Funct7_5 <= '1';    -- SRAI
        wait for 100 ns;      -- Result should be 1101 (SRAI)
        
        -- Test SLTI
        s_Funct3 <= "010";    -- SLTI
        s_Funct7_5 <= '0';    -- Not used for SLTI
        wait for 100 ns;      -- Result should be 1001 (SLT)
        
        -- Test SLTIU
        s_Funct3 <= "011";    -- SLTIU
        s_Funct7_5 <= '0';    -- Not used for SLTIU
        wait for 100 ns;      -- Result should be 1010 (SLTU)
        
        -- Test LUI instruction (ALUOp = 100)
        s_ALUOp <= "100";
        s_Funct3 <= "000";    -- Not used for LUI
        s_Funct7_5 <= '0';    -- Not used for LUI
        wait for 100 ns;      -- Result should be 1110 (LUI)
        
        -- End test
        wait;
    end process;
end behavior;