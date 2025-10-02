library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath is
  port (
    i_clk      : in  std_logic;
    i_rst      : in  std_logic;
    -- control
    i_RegWrite : in  std_logic;
    i_nAdd_Sub : in  std_logic;   -- 0:add  1:sub
    i_ALUSrc   : in  std_logic;   -- 0:use rs2  1:use imm12
    -- register addresses & immediate
    i_rs1      : in  std_logic_vector(4 downto 0);
    i_rs2      : in  std_logic_vector(4 downto 0);
    i_rd       : in  std_logic_vector(4 downto 0);
    i_imm12    : in  std_logic_vector(11 downto 0);

    -- handy ?observe? outputs (not strictly required, but nice for the TB)
    o_rdata1   : out std_logic_vector(31 downto 0);
    o_rdata2   : out std_logic_vector(31 downto 0);
    o_aluY     : out std_logic_vector(31 downto 0)
  );
end entity;

architecture structural of datapath is
  -- internal signals
  signal rdata1   : std_logic_vector(31 downto 0);
  signal rdata2   : std_logic_vector(31 downto 0);
  signal imm_ext  : std_logic_vector(31 downto 0);
  signal alu_b    : std_logic_vector(31 downto 0);
  signal alu_y    : std_logic_vector(31 downto 0);
begin
  -- 12->32 sign extension (RV32 immediates are 12-bit signed)
  imm_ext <= std_logic_vector(resize(signed(i_imm12), 32));

  -- Register file
  U_RF : entity work.regfile
    port map (
      i_CLK       => i_clk,
      i_RST       => i_rst,
      i_RegWrite  => i_RegWrite,
      i_rs1       => i_rs1,
      i_rs2       => i_rs2,
      i_rd        => i_rd,
      i_WriteData => alu_y,       -- write back ALU result
      o_ReadData1 => rdata1,
      o_ReadData2 => rdata2
    );

  -- ALU second operand mux (rs2 vs. imm)
  U_SRCB : entity work.mux2t1
    port map (
      a   => rdata2,    -- when ALUSrc=0
      b   => imm_ext,   -- when ALUSrc=1
      sel => i_ALUSrc,
      y   => alu_b
    );

  -- Add/Sub
  U_ALU : entity work.addsub
    port map (
      a       => rdata1,
      b       => alu_b,
      nAddSub => i_nAdd_Sub,
      result  => alu_y
    );

  -- expose for waveform viewing
  o_rdata1 <= rdata1;
  o_rdata2 <= rdata2;
  o_aluY   <= alu_y;
end architecture;

