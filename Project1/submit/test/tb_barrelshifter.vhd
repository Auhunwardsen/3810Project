library IEEE;
use IEEE.std_logic_1164.all;

entity tb_barrelshifter is
end tb_barrelshifter;

architecture mixed of tb_barrelshifter is
  component barrelshifter is
	port (	i_data	: in  std_logic_vector(31 downto 0);
        	i_shift	: in  std_logic_vector(4 downto 0);
        	i_op    : in  std_logic_vector(1 downto 0);
        	o_result: out std_logic_vector(31 downto 0));
  end component;

  signal s_data   : std_logic_vector(31 downto 0);
  signal s_shift  : std_logic_vector(4 downto 0);
  signal s_op    : std_logic_vector(1 downto 0);
  signal s_result : std_logic_vector(31 downto 0);

begin
	DUT: barrelshifter
        	port MAP(i_data   => s_data,
            		  i_shift  => s_shift,
            		  i_op    => s_op,
            		  o_result => s_result);

    	process
    	  begin

          -- Shift Left Logical

	  -- Expected: 0x00000010
          s_data  <= x"00000001";	
          s_shift <= "00100";      	-- shift by 4
          s_op    <= "00";         	-- SLL
          wait for 100 ns;         	

	  -- Expected: 0x00FFFF00
          s_data  <= x"0000FFFF"; 	
          s_shift <= "01000";      	-- shift by 8
          s_op   <= "00";         	-- SLL
          wait for 100 ns;         

          -- Shift Right Logical

	  -- Expected: 0x00800000
          s_data  <= x"80000000";  
          s_shift <= "01000"; 		-- shift by 8
          s_op   <= "01";         	-- SRL
          wait for 100 ns;         

	  -- Expected: 0x0F000000
          s_data  <= x"F0000000"; 
          s_shift <= "00100";      	-- shift by 4
          s_op   <= "01";         	-- SRL
          wait for 100 ns;         

          --Shift Right Arithmetic

	  -- Expected: 0xFF000000
          s_data  <= x"F0000000";  	-- negative number
          s_shift <= "00100";      	-- shift by 4
          s_op   <= "10";         	-- SRA
          wait for 100 ns;         

	  -- Expected: 0xFFF00000
          s_data  <= x"F0000000";  	-- negative number
          s_shift <= "01000";      	-- shift by 8
          s_op   <= "10";         	-- SRA
          wait for 100 ns;     

	  -- Expected: 0x07000000
          s_data  <= x"70000000";  	-- positive number
          s_shift <= "00100";      	-- shift by 4
          s_op   <= "10";         	-- SRA
          wait for 100 ns;    

	  -- Expected: 0x000F0000
          s_data  <= x"0F000000";  	-- negative number
          s_shift <= "01000";      	-- shift by 8
          s_op   <= "10";         	-- SRA
          wait for 100 ns;
 
        wait;
    end process;
end mixed;
