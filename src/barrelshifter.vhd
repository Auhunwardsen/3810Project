library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity barrelshifter is
	port (	i_data	: in  std_logic_vector(31 downto 0);  	-- data to shift
        	i_shift	: in  std_logic_vector(4 downto 0);   	-- shift amount
        	i_op    : in  std_logic_vector(1 downto 0);   	-- 00=SLL, 01=SRL, 10=SRA
        	o_result: out std_logic_vector(31 downto 0));   -- shifted output
end BarrelShifter;

architecture dataflow of barrelshifter is
	signal s_shifted : std_logic_vector(31 downto 0);
  begin
    process(i_data, i_shift, i_op)
    begin
	case i_op is

          -- Shift Left Logical (SLL/SLLI)
          when "00" =>
            s_shifted <= std_logic_vector(shift_left(unsigned(i_data), to_integer(unsigned(i_shift))));

          -- Shift Right Logical (SRL/SRLI)
          when "01" =>
            s_shifted <= std_logic_vector(shift_right(unsigned(i_data), to_integer(unsigned(i_shift))));

          -- Shift Right Arithmetic (SRA/SRAI)
          when "10" =>
            s_shifted <= std_logic_vector(shift_right(signed(i_data), to_integer(unsigned(i_shift))));

          -- Default
          when others =>
            s_shifted <= i_data;

	end case;
  end process;
  o_result <= s_shifted;
end dataflow;
