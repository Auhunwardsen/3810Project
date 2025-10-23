library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_alu is
end tb_alu;

architecture behavior of tb_alu is
    -- Component Declaration
    component alu
        port(
            i_ALUCtrl   : in std_logic_vector(3 downto 0);
            i_A         : in std_logic_vector(31 downto 0);
            i_B         : in std_logic_vector(31 downto 0);
            o_Result    : out std_logic_vector(31 downto 0);
            o_Zero      : out std_logic;
            o_Overflow  : out std_logic
        );
    end component;

    -- Inputs
    signal s_ALUCtrl   : std_logic_vector(3 downto 0) := (others => '0');
    signal s_A         : std_logic_vector(31 downto 0) := (others => '0');
    signal s_B         : std_logic_vector(31 downto 0) := (others => '0');

    -- Outputs
    signal s_Result    : std_logic_vector(31 downto 0);
    signal s_Zero      : std_logic;
    signal s_Overflow  : std_logic;

begin
    -- Instantiate the Unit Under Test (UUT)
    UUT: alu
        port map(
            i_ALUCtrl   => s_ALUCtrl,
            i_A         => s_A,
            i_B         => s_B,
            o_Result    => s_Result,
            o_Zero      => s_Zero,
            o_Overflow  => s_Overflow
        );

    -- Comprehensive test process for all ALU operations
    stim_proc: process
    begin
        -- Test ADD operations (0000)
        s_ALUCtrl <= "0000";  -- ADD operation
        
        -- Normal case
        s_A <= x"00000005";   -- 5
        s_B <= x"00000007";   -- 7
        wait for 100 ns;      -- Result should be 12 (0x0000000C)
        
        -- Edge case: adding zero
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: positive overflow
        s_A <= x"7FFFFFFF";   -- Maximum positive 32-bit signed integer
        s_B <= x"00000001";   -- 1
        wait for 100 ns;      -- Result should be 0x80000000 with overflow flag set
        
        -- Edge case: negative overflow
        s_A <= x"80000000";   -- Minimum negative 32-bit signed integer
        s_B <= x"80000000";   -- Another large negative
        wait for 100 ns;      -- Result should be 0x00000000 with overflow flag set
        
        -- Test SUB operations (0001)
        s_ALUCtrl <= "0001";  -- SUB operation
        
        -- Normal case
        s_A <= x"0000000A";   -- 10
        s_B <= x"00000003";   -- 3
        wait for 100 ns;      -- Result should be 7 (0x00000007)
        
        -- Edge case: subtracting zero
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: result is zero
        s_A <= x"00000005";   -- 5
        s_B <= x"00000005";   -- 5
        wait for 100 ns;      -- Result should be 0 with zero flag set
        
        -- Edge case: negative result
        s_A <= x"00000003";   -- 3
        s_B <= x"00000005";   -- 5
        wait for 100 ns;      -- Result should be -2 (0xFFFFFFFE)
        
        -- Edge case: overflow
        s_A <= x"80000000";   -- Minimum negative 32-bit signed integer
        s_B <= x"00000001";   -- 1
        wait for 100 ns;      -- Result should be 0x7FFFFFFF with overflow flag set
        
        -- Test AND operations (0010)
        s_ALUCtrl <= "0010";  -- AND operation
        
        -- Normal case
        s_A <= x"0000FFFF";   -- 0000...1111
        s_B <= x"FFFF0000";   -- 1111...0000
        wait for 100 ns;      -- Result should be 0x00000000
        
        -- Edge case: AND with all ones
        s_A <= x"ABCDEF01";
        s_B <= x"FFFFFFFF";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: AND with all zeros
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Test OR operations (0011)
        s_ALUCtrl <= "0011";  -- OR operation
        
        -- Normal case
        s_A <= x"0000FFFF";   -- 0000...1111
        s_B <= x"FFFF0000";   -- 1111...0000
        wait for 100 ns;      -- Result should be 0xFFFFFFFF
        
        -- Edge case: OR with all zeros
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: OR with all ones
        s_A <= x"ABCDEF01";
        s_B <= x"FFFFFFFF";
        wait for 100 ns;      -- Result should be 0xFFFFFFFF
        
        -- Test XOR operations (0100)
        s_ALUCtrl <= "0100";  -- XOR operation
        
        -- Normal case
        s_A <= x"0000FFFF";   -- 0000...1111
        s_B <= x"FFFF0000";   -- 1111...0000
        wait for 100 ns;      -- Result should be 0xFFFFFFFF
        
        -- Edge case: XOR with itself
        s_A <= x"ABCDEF01";
        s_B <= x"ABCDEF01";
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Edge case: XOR with all zeros
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: XOR with all ones
        s_A <= x"ABCDEF01";
        s_B <= x"FFFFFFFF";
        wait for 100 ns;      -- Result should be 0x543210FE
        
        -- Test NOR operations (0101)
        s_ALUCtrl <= "0101";  -- NOR operation
        
        -- Normal case
        s_A <= x"0000FFFF";   -- 0000...1111
        s_B <= x"FFFF0000";   -- 1111...0000
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Edge case: NOR with all zeros
        s_A <= x"00000000";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xFFFFFFFF
        
        -- Edge case: NOR with all ones
        s_A <= x"FFFFFFFF";
        s_B <= x"FFFFFFFF";
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Test shift operations (with placeholders for barrel shifter)
        
        -- Test SLL operations (0110)
        s_ALUCtrl <= "0110";  -- SLL operation
        
        -- Normal case
        s_A <= x"00000001";   -- 1
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0x00000010
        
        -- Edge case: Shift by 0
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: Shift by 31
        s_A <= x"00000001";
        s_B <= x"0000001F";   -- Shift by 31
        wait for 100 ns;      -- Result should be 0x80000000
        
        -- Edge case: Shift by 32 (should be 0 as only bottom 5 bits are used)
        s_A <= x"00000001";
        s_B <= x"00000020";   -- Shift by 32
        wait for 100 ns;      -- Result should be 0x00000001 (32 mod 32 = 0)
        
        -- Test SRL operations (0111)
        s_ALUCtrl <= "0111";  -- SRL operation
        
        -- Normal case
        s_A <= x"00000010";   -- 16
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Edge case: Shift by 0
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: Shift a 1 in MSB
        s_A <= x"80000000";
        s_B <= x"0000001F";   -- Shift by 31
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Test SRA operations (1000)
        s_ALUCtrl <= "1000";  -- SRA operation
        
        -- Normal case with positive number
        s_A <= x"00000010";   -- 16
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Normal case with negative number
        s_A <= x"80000010";   -- Negative number
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0xF8000001 (sign-extended)
        
        -- Edge case: Shift by 0
        s_A <= x"ABCDEF01";
        s_B <= x"00000000";
        wait for 100 ns;      -- Result should be 0xABCDEF01
        
        -- Edge case: Shift a negative number all the way
        s_A <= x"80000000";   -- Minimum negative 32-bit signed integer
        s_B <= x"0000001F";   -- Shift by 31
        wait for 100 ns;      -- Result should be 0xFFFFFFFF (all 1's due to sign extension)
        
        -- Test SLT operations (1001)
        s_ALUCtrl <= "1001";  -- SLT operation
        
        -- Normal case: A < B
        s_A <= x"00000005";   -- 5
        s_B <= x"00000007";   -- 7
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Normal case: A > B
        s_A <= x"00000007";   -- 7
        s_B <= x"00000005";   -- 5
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Edge case: A = B
        s_A <= x"00000005";   -- 5
        s_B <= x"00000005";   -- 5
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Edge case: Negative vs. Positive
        s_A <= x"FFFFFFFF";   -- -1 in 2's complement
        s_B <= x"00000001";   -- 1
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Test SLTU operations (1010)
        s_ALUCtrl <= "1010";  -- SLTU operation
        
        -- Normal case: A < B (unsigned)
        s_A <= x"00000005";   -- 5
        s_B <= x"00000007";   -- 7
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- Special case: A would be < B signed, but A > B unsigned
        s_A <= x"FFFFFFFF";   -- -1 in signed, max unsigned value
        s_B <= x"00000001";   -- 1
        wait for 100 ns;      -- Result should be 0x00000000 with zero flag set
        
        -- Test shift immediate operations
        -- These should behave similarly to non-immediate shifts, but are provided separately
        
        -- SLLI (1011)
        s_ALUCtrl <= "1011";  -- SLLI operation
        s_A <= x"00000001";   -- 1
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0x00000010
        
        -- SRLI (1100)
        s_ALUCtrl <= "1100";  -- SRLI operation
        s_A <= x"00000010";   -- 16
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0x00000001
        
        -- SRAI (1101)
        s_ALUCtrl <= "1101";  -- SRAI operation
        s_A <= x"80000010";   -- Negative number
        s_B <= x"00000004";   -- Shift by 4
        wait for 100 ns;      -- Result should be 0xF8000001 (sign-extended)
        
        -- Test LUI operation (1110)
        s_ALUCtrl <= "1110";  -- LUI operation
        s_A <= x"00000000";   -- A is ignored for LUI
        s_B <= x"12345000";   -- Some immediate value
        wait for 100 ns;      -- Result should be 0x12345000
        
        -- End test
        wait;
    end process;
end behavior;