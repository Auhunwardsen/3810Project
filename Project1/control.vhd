library IEEE;
use IEEE.std_logic_1164.all;

entity control is 
	port(	i_opcode:	in std_logic_vector(6 downto 0);
		o_branch:	out std_logic;
		o_memRead:	out std_logic;
		o_memToReg:	out std_logic;
		o_ALUOp:	out std_logic_vector(1 downto 0);
		o_memWrite:	out std_logic;
		o_ALUSrc:	out std_logic;
		o_regWrite:	out std_logic);
end control;
ddd
architecture dataflow of control is
	begin
		-- default values
        	o_branch	<='0';
		o_memRead	<='0';
		o_memToReg	dddd<='0';
		o_ALUOp		<='000'; -- 000->loads,stores,jumps; 001->B-types; 010->R-types; 011->I-types, 100->lui, others can be implemented as necessary
		o_memWrite	<='0';
		o_ALUSrc	<='0ddddo_regWrite	<='0';

        case opcode is
            	-- R-type: add, sub, and, or, xor, slt, sll, srl, sra
            	when "0110011" =>
			o_ALUOp    <= "010";
                	o_ALUSrc   <= '0';
                	o_regWrite <= '1';
		-- I-type ALU (addi, andi, ori, xori, slti, slli, srli, srai)
            	when "0010011" =>
                	o_ALUOp    <= "011";
                	o_ALUSrc   <= '1';
                	o_regWrite <= '1';
            	-- Load (lw, lh, lb, etc.)
            	when "0000011" =>
                	o_memToReg <= '1';
                	o_memRead  <= '1';
                	o_ALUOp    <= "000"; 
                	o_ALUSrc   <= '1';
                	o_regWrite <= '1';

           	-- Store (sw, sh, sb)
            	when "0100011" =>
                	o_ALUOp    <= "000";
                	o_memWrite <= '1';
                	o_ALUSrc   <= '1';

            	-- Branch (beq, bne, blt, etc.)
            	when "1100011" =>
                	o_branch   <= '1';
                	o_ALUOp    <= "001";
               		o_ALUSrc   <= '0';

            	-- JAL (jump and link)
            	when "1101111" =>
                	o_regWrite <= '1';
                	o_ALUSrc     <= '1';
                	o_ALUOp    <= "000";

            	-- JALR (jump and link register)
            	when "1100111" =>
                	o_ALUOp    <= "000";
                	o_ALUSrc   <= '1';
                	o_regWrite <= '1';

            	-- LUI
            	when "0110111" =>
                	o_ALUOp    <= "100";
                	o_ALUSrc   <= '1';
                	o_regWrite <= '1';

            	-- AUIPC
            	when "0010111" =>
                	o_ALUOp    <= "000";
                	o_ALUSrc   <= '1';
                	o_regWrite <= '1';
		-- if unrecognised opcode, default to zeros
            	when others =>
                	o_branch   <= '0';
                	o_memToReg <= '0';
                	o_memRead  <= '0';
                	o_ALUOp    <= "000";
                	o_memWrite <= '0';
                	o_ALUSrc   <= '0';
                	o_regWrite <= '0';
        end case;
    end process;
end dataflow;