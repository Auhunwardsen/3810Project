library IEEE;
use IEEE.std_logic_1164.all;

entity idex_reg is
  port (
    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;
    i_WE        : in  std_logic;
    i_Flush     : in  std_logic;
    i_PC        : in  std_logic_vector(31 downto 0);
    i_PCPlus4   : in  std_logic_vector(31 downto 0);
    i_RS1Data   : in  std_logic_vector(31 downto 0);
    i_RS2Data   : in  std_logic_vector(31 downto 0);
    i_Imm       : in  std_logic_vector(31 downto 0);
    i_RS1       : in  std_logic_vector(4 downto 0);
    i_RS2       : in  std_logic_vector(4 downto 0);
    i_RD        : in  std_logic_vector(4 downto 0);
    i_Funct3    : in  std_logic_vector(2 downto 0);
    i_Funct7_5  : in  std_logic;
    -- Control signals
    i_RegWrite  : in  std_logic;
    i_MemToReg  : in  std_logic;
    i_MemWrite  : in  std_logic;
    i_MemRead   : in  std_logic;
    i_Branch    : in  std_logic;
    i_ALUSrc    : in  std_logic;
    i_ALUOp     : in  std_logic_vector(2 downto 0);
    i_IsJAL     : in  std_logic;
    i_IsJALR    : in  std_logic;
    i_IsAUIPC   : in  std_logic;
    -- Outputs
    o_PC        : out std_logic_vector(31 downto 0);
    o_PCPlus4   : out std_logic_vector(31 downto 0);
    o_RS1Data   : out std_logic_vector(31 downto 0);
    o_RS2Data   : out std_logic_vector(31 downto 0);
    o_Imm       : out std_logic_vector(31 downto 0);
    o_RS1       : out std_logic_vector(4 downto 0);
    o_RS2       : out std_logic_vector(4 downto 0);
    o_RD        : out std_logic_vector(4 downto 0);
    o_Funct3    : out std_logic_vector(2 downto 0);
    o_Funct7_5  : out std_logic;
    -- Control outputs
    o_RegWrite  : out std_logic;
    o_MemToReg  : out std_logic;
    o_MemWrite  : out std_logic;
    o_MemRead   : out std_logic;
    o_Branch    : out std_logic;
    o_ALUSrc    : out std_logic;
    o_ALUOp     : out std_logic_vector(2 downto 0);
    o_IsJAL     : out std_logic;
    o_IsJALR    : out std_logic;
    o_IsAUIPC   : out std_logic
  );
end entity;

architecture behavioral of idex_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      o_PC       <= (others => '0');
      o_PCPlus4  <= (others => '0');
      o_RS1Data  <= (others => '0');
      o_RS2Data  <= (others => '0');
      o_Imm      <= (others => '0');
      o_RS1      <= (others => '0');
      o_RS2      <= (others => '0');
      o_RD       <= (others => '0');
      o_Funct3   <= (others => '0');
      o_Funct7_5 <= '0';
      -- Control signals
      o_RegWrite <= '0';
      o_MemToReg <= '0';
      o_MemWrite <= '0';
      o_MemRead  <= '0';
      o_Branch   <= '0';
      o_ALUSrc   <= '0';
      o_ALUOp    <= (others => '0');
      o_IsJAL    <= '0';
      o_IsJALR   <= '0';
      o_IsAUIPC  <= '0';
    elsif rising_edge(i_CLK) then
      if i_Flush = '1' then
        o_PC       <= (others => '0');
        o_PCPlus4  <= (others => '0');
        o_RS1Data  <= (others => '0');
        o_RS2Data  <= (others => '0');
        o_Imm      <= (others => '0');
        o_RS1      <= (others => '0');
        o_RS2      <= (others => '0');
        o_RD       <= (others => '0');
        o_Funct3   <= (others => '0');
        o_Funct7_5 <= '0';
        -- Control signals
        o_RegWrite <= '0';
        o_MemToReg <= '0';
        o_MemWrite <= '0';
        o_MemRead  <= '0';
        o_Branch   <= '0';
        o_ALUSrc   <= '0';
        o_ALUOp    <= (others => '0');
        o_IsJAL    <= '0';
        o_IsJALR   <= '0';
        o_IsAUIPC  <= '0';
      elsif i_WE = '1' then
        o_PC       <= i_PC;
        o_PCPlus4  <= i_PCPlus4;
        o_RS1Data  <= i_RS1Data;
        o_RS2Data  <= i_RS2Data;
        o_Imm      <= i_Imm;
        o_RS1      <= i_RS1;
        o_RS2      <= i_RS2;
        o_RD       <= i_RD;
        o_Funct3   <= i_Funct3;
        o_Funct7_5 <= i_Funct7_5;
        -- Control signals
        o_RegWrite <= i_RegWrite;
        o_MemToReg <= i_MemToReg;
        o_MemWrite <= i_MemWrite;
        o_MemRead  <= i_MemRead;
        o_Branch   <= i_Branch;
        o_ALUSrc   <= i_ALUSrc;
        o_ALUOp    <= i_ALUOp;
        o_IsJAL    <= i_IsJAL;
        o_IsJALR   <= i_IsJALR;
        o_IsAUIPC  <= i_IsAUIPC;
      end if;
    end if;
  end process;
end architecture;