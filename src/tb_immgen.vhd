library IEEE;
use IEEE.std_logic_1164.all;

entity tb_immgen is
end tb_immgen;

architecture mixed of tb_immgen is
  component immgen is 
	port(	i_instr : in  std_logic_vector(31 downto 0);
        	o_imm   : out std_logic_vector(31 downto 0));
  end component;

  signal s_instr:	std_logic_vector(31 downto 0);
  signal s_imm: 	std_logic_vector(31 downto 0);

  begin
	DUT: immgen
		port MAP(i_instr	=> s_instr,
        		 o_imm   	=> s_imm);
	process
	  begin
        	-- I-type: addi x5, x6, -4  (opcode 0010011)
        	-- imm[11:0] = 111111111100 (expected 0xFFFFFFFC)
        	s_instr <= "111111111100" & "00110" & "000" & "00101" & "0010011";
        	wait for 100 ns;

        	-- I-type: lw x5, 8(x2) (opcode 0000011)
        	-- imm[11:0] = 000000001000 (expected 0x00000008)
        	s_instr <= "000000001000" & "00010" & "010" & "00101" & "0000011";
        	wait for 100 ns;

        	-- I-type: jalr x1, 0(x0) (opcode 1100111)
        	-- imm[11:0] = 00000000000 (expected 0x00000000)
        	s_instr <= "000000000000" & "00000" & "000" & "00001" & "1100111";
        	wait for 100 ns;

                -- S-type: sw x5, 16(x2)  (opcode 0100011)
        	-- imm[11:5] = 0000000, imm[4:0] = 10000 (expected 0x00000010)
     		s_instr <= "0000000" & "00101" & "00010" & "010" & "10000" & "0100011";
        	wait for 100 ns;

        	-- B-type: beq x1, x2, 12  (opcode 1100011)
        	-- imm[12] = 0, imm[10:5] = 000000, imm[4:1] = 0110, imm[11]= 0, imm[0] = 0 (expected 0x0000000C)
        	s_instr <= "0000000" & "00010" & "00001" & "000" & "00110" & "1100011";
        	wait for 100 ns;

        	-- U-type: lui x5, 0x12345  (opcode 0110111)
        	-- imm[31:12]=00010010001101000101, imm[11:0]=000000000000 (expected 0x12345000)
        	s_instr <= "00010010001101000101" & "00101" & "0110111";
        	wait for 100 ns;

        	-- J-type: jal x1, 256 (opcode 1101111)
        	-- imm spread: imm[20] = 0, imm[10:1] = 0000000001, imm[11] = 0, imm[19:12] = 00000000, imm[0] = 0 (expected 0x00000100)
        	s_instr <= "00000000000100000000" & "00001" & "1101111";
        	wait for 100 ns;

		-- Default case
        	s_instr <= (others => '0');
        	wait;

    end process;
end mixed;