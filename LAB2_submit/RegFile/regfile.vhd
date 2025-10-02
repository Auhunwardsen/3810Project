library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port (
    i_CLK, i_RST   : in  std_logic;
    i_RegWrite     : in  std_logic;
    i_rs1, i_rs2   : in  std_logic_vector(4 downto 0);
    i_rd           : in  std_logic_vector(4 downto 0);
    i_WriteData    : in  std_logic_vector(31 downto 0);
    o_ReadData1    : out std_logic_vector(31 downto 0);
    o_ReadData2    : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of regfile is
  -- your decoder
  component decoder5t32 is
    port (
      i_A  : in  std_logic_vector(4 downto 0);
      i_EN : in  std_logic;
      o_Q  : out std_logic_vector(31 downto 0)   -- one-hot
    );
  end component;

  -- your N-bit register
  component register_n is
    generic ( N : integer := 32 );
    port (
      i_CLK : in  std_logic;
      i_RST : in  std_logic;
      i_WE  : in  std_logic;
      i_D   : in  std_logic_vector(N-1 downto 0);
      o_Q   : out std_logic_vector(N-1 downto 0)
    );
  end component;

  -- your mux
  component mux32_1 is
    port (
      data_in : in  std_logic_vector(32*32-1 downto 0);
      sel     : in  std_logic_vector(4 downto 0);
      y       : out std_logic_vector(31 downto 0)
    );
  end component;

  signal we_decode  : std_logic_vector(31 downto 0);
  signal regs_flat  : std_logic_vector(32*32-1 downto 0);
begin
  -- decode write address; gate with global write enable
  DEC: decoder5t32
    port map (
      i_A  => i_rd,
      i_EN => i_RegWrite,
      o_Q  => we_decode
    );

  -- x0 = constant zero (writes ignored)
  regs_flat(31 downto 0) <= (others => '0');

  -- x1..x31 registers
  gen_regs: for i in 1 to 31 generate
    signal qi : std_logic_vector(31 downto 0);
  begin
    RX: register_n
      generic map ( N => 32 )
      port map (
        i_CLK => i_CLK,
        i_RST => i_RST,
        i_WE  => we_decode(i),          -- already gated by i_RegWrite via decoder
        i_D   => i_WriteData,
        o_Q   => qi
      );
    regs_flat(i*32+31 downto i*32) <= qi;
  end generate;

  -- read ports
  MUXA: mux32_1 port map(data_in => regs_flat, sel => i_rs1, y => o_ReadData1);
  MUXB: mux32_1 port map(data_in => regs_flat, sel => i_rs2, y => o_ReadData2);
end architecture;
