-----------------------------------------------------------------------------
-- Entity: decoder5t32.vhd  
-- Name: Austin Hunwardsen
-- Description: decoder logic for decoder5t32.vhd using dataflow with our enable line 
-- Date: 9/18/25
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity decoder5t32 is
    port (
        i_A  : in  std_logic_vector(4 downto 0);  -- 5-bit input
        i_EN : in  std_logic;                     -- Enable input
        o_Q  : out std_logic_vector(31 downto 0)  -- 32-bit output
    );    
end entity decoder5t32;

architecture dataflow of decoder5t32 is
begin
    process (i_A, i_EN)
        variable temp : std_logic_vector(31 downto 0); 
    begin
        temp := (others => '0');  -- Initialize output to all zeros
        if i_EN = '1' then
            temp(to_integer(unsigned(i_A))) := '1';  -- Set the bit corresponding to i_A to 1
        end if;

	temp(0) := '0';

        o_Q <= temp;  -- Assign the temporary variable to the output
    end process;
end architecture;