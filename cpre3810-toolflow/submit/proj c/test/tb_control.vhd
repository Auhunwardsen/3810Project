library IEEE;
use IEEE.std_logic_1164.all;

entity tb_control is
end tb_control;

architecture mixed of tb_control is
  component control is 
	port(	i_opcode:	in std_logic_vector(6 downto 0);
		o_branch:	out std_logic;
		o_memRead:	out std_logic;
		o_memToReg:	out std_logic;
		o_ALUOp:	out std_logic_vector(2 downto 0);
		o_memWrite:	out std_logic;
		o_ALUSrc:	out std_logic;
		o_regWrite:	out std_logic);
  end component;

  signal s_opcode:	std_logic_vector(6 downto 0);
  signal s_branch:	std_logic;
  signal s_memRead:	std_logic;
  signal s_memToReg:	std_logic;
  signal s_ALUOp:	std_logic_vector(2 downto 0);
  signal s_memWrite:	std_logic;
  signal s_ALUSrc:	std_logic;
  signal s_regWrite:	std_logic;

  begin
	DUT: control
		port MAP(i_opcode	=> s_opcode,
			 o_branch	=> s_branch,
			 o_memRead	=> s_memRead,
			 o_memToReg	=> s_memToReg,
			 o_ALUOp	=> s_ALUOp,
			 o_memWrite	=> s_memWrite,
			 o_ALUSrc	=> s_ALUSrc,
			 o_regWrite	=> s_regWrite);
	process
	  begin
		s_opcode <= "0110011";
		wait for 100 ns;
		s_opcode <= "0010011";
		wait for 100 ns;
		s_opcode <= "0000011";
		wait for 100 ns;
		s_opcode <= "0100011";
		wait for 100 ns;
		s_opcode <= "1100011";
		wait for 100 ns;
		s_opcode <= "1101111";
		wait for 100 ns;
		s_opcode <= "1100111";
		wait for 100 ns;
		s_opcode <= "0110111";
		wait for 100 ns;
		s_opcode <= "0010111";
		wait for 100 ns;
		s_opcode <= "0000000";
		wait for 100 ns;
		wait;
	end process;
end mixed;
