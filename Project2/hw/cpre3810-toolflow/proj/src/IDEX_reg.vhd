-- Pipeline Register: ID/EX Stage  
-- Stores decode stage outputs and control signals
library IEEE;
use IEEE.std_logic_1164.all;

entity IDEX_reg is
  port(
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_WE      : in  std_logic;  -- Write enable (for stalling)
    i_flush   : in  std_logic;  -- Flush signal
    
    -- Control signals
    i_RegWrite  : in  std_logic;
    i_MemToReg  : in  std_logic;
    i_MemWrite  : in  std_logic;
    i_MemRead   : in  std_logic;
    i_Branch    : in  std_logic;
    i_ALUSrc    : in  std_logic;
    i_ALUOp     : in  std_logic_vector(2 downto 0);
    
    -- Data signals
    i_PC        : in  std_logic_vector(31 downto 0);
    i_PCplus4   : in  std_logic_vector(31 downto 0);
    i_RS1Data   : in  std_logic_vector(31 downto 0);
    i_RS2Data   : in  std_logic_vector(31 downto 0);
    i_Immediate : in  std_logic_vector(31 downto 0);
    i_RS1Addr   : in  std_logic_vector(4 downto 0);
    i_RS2Addr   : in  std_logic_vector(4 downto 0);
    i_RDAddr    : in  std_logic_vector(4 downto 0);
    i_Instr     : in  std_logic_vector(31 downto 0);
    
    -- Outputs to EX stage
    o_RegWrite  : out std_logic;
    o_MemToReg  : out std_logic;
    o_MemWrite  : out std_logic;
    o_MemRead   : out std_logic;
    o_Branch    : out std_logic;
    o_ALUSrc    : out std_logic;
    o_ALUOp     : out std_logic_vector(2 downto 0);
    
    o_PC        : out std_logic_vector(31 downto 0);
    o_PCplus4   : out std_logic_vector(31 downto 0);
    o_RS1Data   : out std_logic_vector(31 downto 0);
    o_RS2Data   : out std_logic_vector(31 downto 0);
    o_Immediate : out std_logic_vector(31 downto 0);
    o_RS1Addr   : out std_logic_vector(4 downto 0);
    o_RS2Addr   : out std_logic_vector(4 downto 0);
    o_RDAddr    : out std_logic_vector(4 downto 0);
    o_Instr     : out std_logic_vector(31 downto 0)
  );
end IDEX_reg;

architecture behavioral of IDEX_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      -- Reset all control signals
      o_RegWrite  <= '0';
      o_MemToReg  <= '0';
      o_MemWrite  <= '0';
      o_MemRead   <= '0';
      o_Branch    <= '0';
      o_ALUSrc    <= '0';
      o_ALUOp     <= (others => '0');
      
      -- Reset all data signals
      o_PC        <= (others => '0');
      o_PCplus4   <= (others => '0');
      o_RS1Data   <= (others => '0');
      o_RS2Data   <= (others => '0');
      o_Immediate <= (others => '0');
      o_RS1Addr   <= (others => '0');
      o_RS2Addr   <= (others => '0');
      o_RDAddr    <= (others => '0');
      o_Instr     <= (others => '0');
      
    elsif rising_edge(i_CLK) then
      if i_flush = '1' then
        -- Flush - insert NOP (bubble)
        o_RegWrite  <= '0';
        o_MemToReg  <= '0';
        o_MemWrite  <= '0';
        o_MemRead   <= '0';
        o_Branch    <= '0';
        o_ALUSrc    <= '0';
        o_ALUOp     <= (others => '0');
        
        o_PC        <= (others => '0');
        o_PCplus4   <= (others => '0');
        o_RS1Data   <= (others => '0');
        o_RS2Data   <= (others => '0');
        o_Immediate <= (others => '0');
        o_RS1Addr   <= (others => '0');
        o_RS2Addr   <= (others => '0');
        o_RDAddr    <= (others => '0');
        o_Instr     <= (others => '0');
        
      elsif i_WE = '1' then
        -- Normal operation - pass through values
        o_RegWrite  <= i_RegWrite;
        o_MemToReg  <= i_MemToReg;
        o_MemWrite  <= i_MemWrite;
        o_MemRead   <= i_MemRead;
        o_Branch    <= i_Branch;
        o_ALUSrc    <= i_ALUSrc;
        o_ALUOp     <= i_ALUOp;
        
        o_PC        <= i_PC;
        o_PCplus4   <= i_PCplus4;
        o_RS1Data   <= i_RS1Data;
        o_RS2Data   <= i_RS2Data;
        o_Immediate <= i_Immediate;
        o_RS1Addr   <= i_RS1Addr;
        o_RS2Addr   <= i_RS2Addr;
        o_RDAddr    <= i_RDAddr;
        o_Instr     <= i_Instr;
      end if;
    end if;
  end process;
end behavioral;