library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is
    port(
        i_ALUCtrl   : in std_logic_vector(3 downto 0);   -- Control signal for ALU operation
        i_A         : in std_logic_vector(31 downto 0);  -- Input A
        i_B         : in std_logic_vector(31 downto 0);  -- Input B
        o_Result    : out std_logic_vector(31 downto 0); -- ALU result output
        o_Zero      : out std_logic;                     -- Zero flag (1 if o_Result is 0)
        o_Overflow  : out std_logic                      -- Overflow flag
    );
end alu;

architecture behavioral of alu is
    -- Internal signals
    signal s_Result  : std_logic_vector(31 downto 0);
    signal s_Zero    : std_logic;
    signal s_Overflow: std_logic;
    
begin
    -- Calculate ALU operations based on control signal
    process(i_ALUCtrl, i_A, i_B)
        -- Variables to help with calculation
        variable v_temp : std_logic_vector(31 downto 0);
    begin
        -- Default values
        s_Result <= (others => '0');
        s_Overflow <= '0';
        
        case i_ALUCtrl is
            -- ADD (0000)
            when "0000" =>
                -- Simple addition
                s_Result <= std_logic_vector(signed(i_A) + signed(i_B));
                
                -- Overflow detection for signed addition
                if ((i_A(31) = '0' and i_B(31) = '0' and s_Result(31) = '1') or
                    (i_A(31) = '1' and i_B(31) = '1' and s_Result(31) = '0')) then
                    s_Overflow <= '1';
                else
                    s_Overflow <= '0';
                end if;
            
            -- SUB (0001)
            when "0001" =>
                -- Simple subtraction
                s_Result <= std_logic_vector(signed(i_A) - signed(i_B));
                
                -- Overflow detection for subtraction
                if ((i_A(31) = '0' and i_B(31) = '1' and s_Result(31) = '1') or
                    (i_A(31) = '1' and i_B(31) = '0' and s_Result(31) = '0')) then
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
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_B(4 downto 0)))));
                s_Overflow <= '0';
            
            -- SRL - Shift Right Logical (0111)
            when "0111" =>
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_B(4 downto 0)))));
                s_Overflow <= '0';
            
            -- SRA - Shift Right Arithmetic (1000)
            when "1000" =>
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_right(signed(i_A), to_integer(unsigned(i_B(4 downto 0)))));
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
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_left(unsigned(i_A), to_integer(unsigned(i_B(4 downto 0)))));
                s_Overflow <= '0';
                
            -- SRLI - Shift Right Logical Immediate (1100)
            when "1100" =>
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_B(4 downto 0)))));
                s_Overflow <= '0';
                
            -- SRAI - Shift Right Arithmetic Immediate (1101)
            when "1101" =>
                -- Placeholder for barrel shifter implementation
                -- For now, basic implementation using numeric_std
                s_Result <= std_logic_vector(shift_right(signed(i_A), to_integer(unsigned(i_B(4 downto 0)))));
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

end behavioral;