library IEEE;
use IEEE.std_logic_1164.all;

entity exmem_reg is
  port (
    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;
    i_WE        : in  std_logic;
    i_Flush     : in  std_logic;
    i_PCPlus4   : in  std_logic_vector(31 downto 0);
    i_ALUResult : in  std_logic_vector(31 downto 0);
    i_RS2Data   : in  std_logic_vector(31 downto 0);
    i_RD        : in  std_logic_vector(4 downto 0);
    i_Funct3    : in  std_logic_vector(2 downto 0);
    -- Control signals
    i_RegWrite  : in  std_logic;
    i_MemToReg  : in  std_logic;
    i_MemWrite  : in  std_logic;
    i_MemRead   : in  std_logic;
    i_IsJAL     : in  std_logic;
    i_IsJALR    : in  std_logic;
    -- Outputs
    o_PCPlus4   : out std_logic_vector(31 downto 0);
    o_ALUResult : out std_logic_vector(31 downto 0);
    o_RS2Data   : out std_logic_vector(31 downto 0);
    o_RD        : out std_logic_vector(4 downto 0);
    o_Funct3    : out std_logic_vector(2 downto 0);
    -- Control outputs
    o_RegWrite  : out std_logic;
    o_MemToReg  : out std_logic;
    o_MemWrite  : out std_logic;
    o_MemRead   : out std_logic;
    o_IsJAL     : out std_logic;
    o_IsJALR    : out std_logic
  );
end entity;

architecture behavioral of exmem_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      o_PCPlus4   <= (others => '0');
      o_ALUResult <= (others => '0');
      o_RS2Data   <= (others => '0');
      o_RD        <= (others => '0');
      o_Funct3    <= (others => '0');
      -- Control signals
      o_RegWrite  <= '0';
      o_MemToReg  <= '0';
      o_MemWrite  <= '0';
      o_MemRead   <= '0';
      o_IsJAL     <= '0';
      o_IsJALR    <= '0';
    elsif rising_edge(i_CLK) then
      if i_Flush = '1' then
        o_PCPlus4   <= (others => '0');
        o_ALUResult <= (others => '0');
        o_RS2Data   <= (others => '0');
        o_RD        <= (others => '0');
        o_Funct3    <= (others => '0');
        -- Control signals
        o_RegWrite  <= '0';
        o_MemToReg  <= '0';
        o_MemWrite  <= '0';
        o_MemRead   <= '0';
        o_IsJAL     <= '0';
        o_IsJALR    <= '0';
      elsif i_WE = '1' then
        o_PCPlus4   <= i_PCPlus4;
        o_ALUResult <= i_ALUResult;
        o_RS2Data   <= i_RS2Data;
        o_RD        <= i_RD;
        o_Funct3    <= i_Funct3;
        -- Control signals
        o_RegWrite  <= i_RegWrite;
        o_MemToReg  <= i_MemToReg;
        o_MemWrite  <= i_MemWrite;
        o_MemRead   <= i_MemRead;
        o_IsJAL     <= i_IsJAL;
        o_IsJALR    <= i_IsJALR;
      end if;
    end if;
  end process;
end architecture;