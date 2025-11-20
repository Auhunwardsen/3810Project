library IEEE;
use IEEE.std_logic_1164.all;

entity immgen is
    port (    i_instr : in  std_logic_vector(31 downto 0);    -- full instruction
            o_imm   : out std_logic_vector(31 downto 0));   -- 32-bit sign-extended immediate
end immgen;

architecture dataflow of immgen is
    signal opcode : std_logic_vector(6 downto 0);
    signal imm    : std_logic_vector(31 downto 0);
begin
    opcode <= i_instr(6 downto 0);

  process(i_instr, opcode)
  begin
	case opcode is

	-- I-type: Immediate = instr[31:20]
        when "0010011" | "0000011" | "1100111" =>
        	imm <= (31 downto 11 => i_instr(31)) & i_instr(30 downto 20);

        -- S-type: Immediate = instr[31:25], instr[11:7]
        when "0100011" =>
		imm <= (31 downto 11 => i_instr(31)) & i_instr(30 downto 25) & i_instr(11 downto 7);

        -- B-type: Immediate = instr[31], instr[7], instr[30:25], instr[11:8], 0 (shift left 1)
        when "1100011" =>
                imm <= (31 downto 12 => i_instr(31)) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8) & '0';

        -- U-type: Immediate = instr[31:12], 12'b0 (shift left 12)
        when "0110111" | "0010111" =>
		imm <= i_instr(31 downto 12) & x"000";

        -- J-type: Immediate = instr[31], instr[19:12], instr[20], instr[30:21], 0 (shift left 1)
        when "1101111" =>
                imm <= (31 downto 20 => i_instr(31)) & i_instr(19 downto 12) & i_instr(20) & i_instr(30 downto 21) & '0';

        -- Default case (for unrecognized opcodes)
        when others =>
                imm <= (others => '0');

        end case;
    end process;

    o_imm <= imm;
end dataflow;
