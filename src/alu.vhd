library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
	port(	i_ALUCtrl	: in std_logic_vector(3 downto 0);   -- ALUOp control signal
		i_A		: in std_logic_vector(31 downto 0);  -- Input A
		i_B		: in std_logic_vector(31 downto 0);  -- Input B
		o_Result	: out std_logic_vector(31 downto 0); -- ALU result
		o_Zero		: out std_logic;                     -- Zero flag
		o_Overflow	: out std_logic);                   -- Overflow flag
end alu;

architecture structural of alu is
	-- Barrel shifter component
	component barrelshifter is
		port(	i_data	: in  std_logic_vector(31 downto 0);  	-- data to shift
			i_shift	: in  std_logic_vector(4 downto 0);   	-- shift amount
			i_op    : in  std_logic_vector(1 downto 0);   	-- 00=SLL, 01=SRL, 10=SRA
			o_result: out std_logic_vector(31 downto 0));   -- shifted output
	end component;
	
	-- Internal signals
	signal s_Result  	: std_logic_vector(31 downto 0);
	signal s_Zero    	: std_logic;
	signal s_Overflow	: std_logic;
	signal s_ShiftOp 	: std_logic_vector(1 downto 0);
	signal s_ShiftResult	: std_logic_vector(31 downto 0);
    
begin
	-- Instantiate barrel shifter component
	u_shifter: barrelshifter
		port map(
			i_data   => i_A,
			i_shift  => i_B(4 downto 0),
			i_op     => s_ShiftOp,
			o_result => s_ShiftResult
		);
		
	-- Determine shift operation based on ALU control
	process(i_ALUCtrl)
	begin
		case i_ALUCtrl is
			when "0110" | "1011" =>  -- SLL or SLLI
				s_ShiftOp <= "00";   -- SLL operation
			when "0111" | "1100" =>  -- SRL or SRLI
				s_ShiftOp <= "01";   -- SRL operation
			when "1000" | "1101" =>  -- SRA or SRAI
				s_ShiftOp <= "10";   -- SRA operation
			when others =>
				s_ShiftOp <= "00";   -- Default
		end case;
	end process;
		
	-- Main ALU operations process
	process(i_ALUCtrl, i_A, i_B, s_ShiftResult)
		variable v_temp_result : std_logic_vector(31 downto 0);
	begin
		-- Default values
		s_Result <= (others => '0');
		s_Overflow <= '0';
        
        case i_ALUCtrl is
            -- ADD (0000)
            when "0000" =>
                -- Simple addition
                v_temp_result := std_logic_vector(signed(i_A) + signed(i_B));
                s_Result <= v_temp_result;
                
                -- Overflow detection for signed addition
                if ((i_A(31) = '0' and i_B(31) = '0' and v_temp_result(31) = '1') or
                    (i_A(31) = '1' and i_B(31) = '1' and v_temp_result(31) = '0')) then
                    s_Overflow <= '1';
                else
                    s_Overflow <= '0';
                end if;
            
            -- SUB (0001)
            when "0001" =>
                -- Simple subtraction
                v_temp_result := std_logic_vector(signed(i_A) - signed(i_B));
                s_Result <= v_temp_result;
                
                -- Overflow detection for subtraction
                if ((i_A(31) = '0' and i_B(31) = '1' and v_temp_result(31) = '1') or
                    (i_A(31) = '1' and i_B(31) = '0' and v_temp_result(31) = '0')) then
                    s_Overflow <= '1';
                else
                    s_Overflow <= '0';
                end if;
            
            -- AND (0010)
            when "0010" =>
                -- Bitwise AND operation
                s_Result <= i_A and i_B;
                s_Overflow <= '0';
            
            -- OR (0011)
            when "0011" =>
                -- Bitwise OR operation
                s_Result <= i_A or i_B;
                s_Overflow <= '0';
            
            -- XOR (0100)
            when "0100" =>
                -- Bitwise XOR operation
                s_Result <= i_A xor i_B;
                s_Overflow <= '0';
                
            -- NOR (0101)
            when "0101" =>
                -- Bitwise NOR operation
                s_Result <= not(i_A or i_B);
                s_Overflow <= '0';
            
            -- SLL - Shift Left Logical (0110)
            when "0110" =>
                -- Use barrel shifter result for SLL
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
            
            -- SRL - Shift Right Logical (0111)
            when "0111" =>
                -- Use barrel shifter result for SRL
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
            
            -- SRA - Shift Right Arithmetic (1000)
            when "1000" =>
                -- Use barrel shifter result for SRA
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
            
            -- SLT - Set Less Than (1001)
            when "1001" =>
                -- Set result to 1 if A < B (signed comparison)
                if signed(i_A) < signed(i_B) then
                    s_Result <= x"00000001";
                else
                    s_Result <= x"00000000";
                end if;
                s_Overflow <= '0';
            
            -- SLTU - Set Less Than Unsigned (1010)
            when "1010" =>
                -- Set result to 1 if A < B (unsigned comparison)
                if unsigned(i_A) < unsigned(i_B) then
                    s_Result <= x"00000001";
                else
                    s_Result <= x"00000000";
                end if;
                s_Overflow <= '0';
            
            -- SLLI - Shift Left Logical Immediate (1011)
            when "1011" =>
                -- Use barrel shifter result for SLLI
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
                
            -- SRLI - Shift Right Logical Immediate (1100)
            when "1100" =>
                -- Use barrel shifter result for SRLI
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
                
            -- SRAI - Shift Right Arithmetic Immediate (1101)
            when "1101" =>
                -- Use barrel shifter result for SRAI
                s_Result <= s_ShiftResult;
                s_Overflow <= '0';
                
            -- LUI - Load Upper Immediate (1110)
            when "1110" =>
                -- For LUI, we just pass i_B directly (the immediate value)
                s_Result <= i_B;
                s_Overflow <= '0';
                
            -- Default case - return 0
            when others =>
                s_Result <= (others => '0');
                s_Overflow <= '0';
        end case;
    end process;

    -- Set zero flag if result is all zeros
    s_Zero <= '1' when s_Result = x"00000000" else '0';
    
    -- Connect internal signals to outputs
    o_Result <= s_Result;
    o_Zero <= s_Zero;
    o_Overflow <= s_Overflow;

end structural;