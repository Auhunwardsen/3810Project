library IEEE;
use IEEE.std_logic_1164.all;

entity alu_control is
    port(
        i_ALUOp     : in std_logic_vector(2 downto 0);   -- ALUOp from main control unit
        i_Funct3    : in std_logic_vector(2 downto 0);   -- funct3 field from instruction
        i_Funct7_5  : in std_logic;                      -- bit 5 of funct7 field from instruction
        o_ALUCtrl   : out std_logic_vector(3 downto 0)   -- ALU control output
    );
end alu_control;

architecture dataflow of alu_control is
begin
    -- Process to determine ALU control signals based on ALUOp, Funct3, and Funct7_5
    process(i_ALUOp, i_Funct3, i_Funct7_5)
    begin
        -- Default ALU operation (add)
        o_ALUCtrl <= "0000";
        
        -- Main ALUOp decoder based on your existing control unit
        -- ALUOp comes from the main control unit based on instruction type:
        -- "000" for loads, stores, jumps
        -- "001" for branch instructions
        -- "010" for R-type instructions
        -- "011" for I-type ALU instructions
        -- "100" for LUI
        
        if i_ALUOp = "000" then
            -- Load/Store instructions - always use ADD for address calculation
            o_ALUCtrl <= "0000";  -- ADD
            
        elsif i_ALUOp = "001" then
            -- Branch instructions - use funct3 to determine comparison type
            case i_Funct3 is
                when "000" | "001" => -- BEQ, BNE
                    o_ALUCtrl <= "0001";  -- SUB for equality check
                when "100" | "101" => -- BLT, BGE  
                    o_ALUCtrl <= "1001";  -- SLT for signed comparison
                when "110" | "111" => -- BLTU, BGEU
                    o_ALUCtrl <= "1010";  -- SLTU for unsigned comparison
                when others =>
                    o_ALUCtrl <= "0001";  -- Default SUB
            end case;
            
        elsif i_ALUOp = "010" then
            -- R-type instructions - use funct3 and funct7_5 to determine operation
            
            -- ADD/SUB (funct3 = 000)
            if i_Funct3 = "000" then
                if i_Funct7_5 = '0' then
                    o_ALUCtrl <= "0000";  -- ADD
                else
                    o_ALUCtrl <= "0001";  -- SUB
                end if;
                
            -- SLL (funct3 = 001) - Shift Left Logical
            elsif i_Funct3 = "001" then
                o_ALUCtrl <= "0110";  -- SLL
                
            -- SLT (funct3 = 010) - Set Less Than
            elsif i_Funct3 = "010" then
                o_ALUCtrl <= "1001";  -- SLT
                
            -- SLTU (funct3 = 011) - Set Less Than Unsigned
            elsif i_Funct3 = "011" then
                o_ALUCtrl <= "1010";  -- SLTU
                
            -- XOR (funct3 = 100)
            elsif i_Funct3 = "100" then
                o_ALUCtrl <= "0100";  -- XOR
                
            -- SRL/SRA (funct3 = 101) - Shift Right Logical/Arithmetic
            elsif i_Funct3 = "101" then
                if i_Funct7_5 = '0' then
                    o_ALUCtrl <= "0111";  -- SRL
                else
                    o_ALUCtrl <= "1000";  -- SRA
                end if;
                
            -- OR (funct3 = 110)
            elsif i_Funct3 = "110" then
                o_ALUCtrl <= "0011";  -- OR
                
            -- AND (funct3 = 111)
            elsif i_Funct3 = "111" then
                o_ALUCtrl <= "0010";  -- AND
            end if;
            
        elsif i_ALUOp = "011" then
            -- I-type ALU instructions - similar to R-type but immediate instead of register
            
            -- ADDI (funct3 = 000)
            if i_Funct3 = "000" then
                o_ALUCtrl <= "0000";  -- ADD
                
            -- SLLI (funct3 = 001) - Shift Left Logical Immediate
            elsif i_Funct3 = "001" then
                o_ALUCtrl <= "1011";  -- SLLI
                
            -- SLTI (funct3 = 010) - Set Less Than Immediate
            elsif i_Funct3 = "010" then
                o_ALUCtrl <= "1001";  -- SLT
                
            -- SLTIU (funct3 = 011) - Set Less Than Immediate Unsigned
            elsif i_Funct3 = "011" then
                o_ALUCtrl <= "1010";  -- SLTU
                
            -- XORI (funct3 = 100)
            elsif i_Funct3 = "100" then
                o_ALUCtrl <= "0100";  -- XOR
                
            -- SRLI/SRAI (funct3 = 101) - Shift Right Logical/Arithmetic Immediate
            elsif i_Funct3 = "101" then
                if i_Funct7_5 = '0' then
                    o_ALUCtrl <= "1100";  -- SRLI
                else
                    o_ALUCtrl <= "1101";  -- SRAI
                end if;
                
            -- ORI (funct3 = 110)
            elsif i_Funct3 = "110" then
                o_ALUCtrl <= "0011";  -- OR
                
            -- ANDI (funct3 = 111)
            elsif i_Funct3 = "111" then
                o_ALUCtrl <= "0010";  -- AND
            end if;
            
        elsif i_ALUOp = "100" then
            -- LUI instruction (Load Upper Immediate)
            o_ALUCtrl <= "1110";  -- LUI - pass immediate value directly
        end if;
    end process;
end dataflow;