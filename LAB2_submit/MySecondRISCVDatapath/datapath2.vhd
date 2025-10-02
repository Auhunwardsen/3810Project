library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity datapath2 is
  port (
    i_clk, i_rst   : in  std_logic;

    -- Control
    i_RegWrite    : in  std_logic;  -- write-back enable
    i_nAdd_Sub    : in  std_logic;  -- 0:add, 1:sub
    i_ALUSrc      : in  std_logic;  -- 0:rs2, 1:imm12
    i_MemWrite    : in  std_logic;  -- mem write enable (we)
    i_MemToReg    : in  std_logic;  -- 0:ALU result -> rd , 1:Mem q -> rd

    -- Register indices
    i_rs1, i_rs2, i_rd : in std_logic_vector(4 downto 0);

    -- Immediate (12-bit, sign-extended for address/ALU when ALUSrc='1')
    i_imm12       : in  std_logic_vector(11 downto 0);

    -- Observability (handy for waveforms)
    o_r1          : out std_logic_vector(31 downto 0);
    o_r2          : out std_logic_vector(31 downto 0);
    o_aluY        : out std_logic_vector(31 downto 0);
    o_dmem_q      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of datapath2 is
  -- Components (match YOUR names/ports)
  component regfile is
    port (
      i_CLK, i_RST  : in  std_logic;
      i_RegWrite    : in  std_logic;
      i_rs1, i_rs2  : in  std_logic_vector(4 downto 0);
      i_rd          : in  std_logic_vector(4 downto 0);
      i_WriteData   : in  std_logic_vector(31 downto 0);
      o_ReadData1   : out std_logic_vector(31 downto 0);
      o_ReadData2   : out std_logic_vector(31 downto 0)
    );
  end component;

  component addsub is
    port (
      a, b     : in  std_logic_vector(31 downto 0);
      nAddSub  : in  std_logic;  -- 0 add, 1 sub
      result   : out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2t1 is
    port (
      a, b : in  std_logic_vector(31 downto 0);
      sel  : in  std_logic;
      y    : out std_logic_vector(31 downto 0)
    );
  end component;

  component sign_extender is
    port (
      din  : in  std_logic_vector(11 downto 0);
      dout : out std_logic_vector(31 downto 0)
    );
  end component;

  component mem is
    generic (
      DATA_WIDTH : natural := 32;
      ADDR_WIDTH : natural := 10      -- yields address vector (ADDR_WIDTH downto 0) = 11 bits
    );
    port (
      clk  : in  std_logic;
      addr : in  std_logic_vector((ADDR_WIDTH-1) downto 0);
      data : in  std_logic_vector((DATA_WIDTH-1) downto 0);
      we   : in  std_logic;
      q    : out std_logic_vector((DATA_WIDTH-1) downto 0)
    );
  end component;

  -- Internal nets
  signal r1, r2, write_data : std_logic_vector(31 downto 0);
  signal imm32              : std_logic_vector(31 downto 0);
  signal alu_b              : std_logic_vector(31 downto 0);
  signal alu_y              : std_logic_vector(31 downto 0);
  signal mem_q              : std_logic_vector(31 downto 0);

begin
  -- Register file
  RF: regfile
    port map (
      i_CLK       => i_clk,
      i_RST       => i_rst,
      i_RegWrite  => i_RegWrite,
      i_rs1       => i_rs1,
      i_rs2       => i_rs2,
      i_rd        => i_rd,
      i_WriteData => write_data,
      o_ReadData1 => r1,
      o_ReadData2 => r2
    );

  -- Sign extend immediate
  SX: sign_extender
    port map (
      din  => i_imm12,
      dout => imm32
    );

  -- Select ALU B input: rs2 or imm32
  M_ALUSrc: mux2t1
    port map (
      a   => r2,
      b   => imm32,
      sel => i_ALUSrc,
      y   => alu_b
    );

  -- ALU add/sub
  ALU: addsub
    port map (
      a       => r1,
      b       => alu_b,
      nAddSub => i_nAdd_Sub,
      result  => alu_y
    );

  -- Data memory (word-addressed): use low 10 bits of ALU result as address
  DMEM: mem
    generic map (DATA_WIDTH => 32, ADDR_WIDTH => 10)
    port map (
      clk  => i_clk,
      addr => alu_y(9 downto 0),  -- 10-bit address
      data => r2,                  -- store rs2
      we   => i_MemWrite,
      q    => mem_q
    );

  -- Writeback: 0=ALU result, 1=Memory q
  M_WB: mux2t1
    port map (
      a   => alu_y,
      b   => mem_q,
      sel => i_MemToReg,
      y   => write_data
    );

  -- Probes
  o_r1     <= r1;
  o_r2     <= r2;
  o_aluY   <= alu_y;
  o_dmem_q <= mem_q;
end architecture;

