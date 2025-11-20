-- Pipeline Register: EX/MEM Stage
-- Stores execute stage outputs
library IEEE;
use IEEE.std_logic_1164.all;

entity EXMEM_reg is
  port(
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_WE      : in  std_logic;  -- Write enable (for stalling)
    i_flush   : in  std_logic;  -- Flush signal
    
    -- Control signals
    i_RegWrite    : in  std_logic;
    i_MemToReg    : in  std_logic;
    i_MemWrite    : in  std_logic;
    i_MemRead     : in  std_logic;
    i_Branch      : in  std_logic;
    
    -- Data signals
    i_BranchAddr  : in  std_logic_vector(31 downto 0);
    i_BranchTaken : in  std_logic;
    i_ALUResult   : in  std_logic_vector(31 downto 0);
    i_WriteData   : in  std_logic_vector(31 downto 0);
    i_RS2Data     : in  std_logic_vector(31 downto 0);
    i_RDAddr      : in  std_logic_vector(4 downto 0);
    i_PCplus4     : in  std_logic_vector(31 downto 0);
    i_Instr   : in  std_logic_vector(31 downto 0);
    
    -- Outputs to MEM stage
    o_RegWrite    : out std_logic;
    o_MemToReg    : out std_logic;
    o_MemWrite    : out std_logic;
    o_MemRead     : out std_logic;
    o_Branch      : out std_logic;
    
    o_BranchAddr  : out std_logic_vector(31 downto 0);
    o_BranchTaken : out std_logic;
    o_ALUResult   : out std_logic_vector(31 downto 0);
    o_WriteData   : out std_logic_vector(31 downto 0);
    o_RS2Data     : out std_logic_vector(31 downto 0);
    o_RDAddr      : out std_logic_vector(4 downto 0);
    o_PCplus4     : out std_logic_vector(31 downto 0);
    o_Instr       : out std_logic_vector(31 downto 0)
  );
end EXMEM_reg;

architecture behavioral of EXMEM_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      -- Reset all control signals
      o_RegWrite    <= '0';
      o_MemToReg    <= '0';
      o_MemWrite    <= '0';
      o_MemRead     <= '0';
      o_Branch      <= '0';
      
      -- Reset all data signals
      o_BranchAddr  <= (others => '0');
      o_BranchTaken <= '0';
      o_ALUResult   <= (others => '0');
      o_WriteData   <= (others => '0');
      o_RS2Data     <= (others => '0');
      o_RDAddr      <= (others => '0');
      o_PCplus4     <= (others => '0');
      
    elsif rising_edge(i_CLK) then
      if i_flush = '1' then
        -- Flush - insert NOP
        o_RegWrite    <= '0';
        o_MemToReg    <= '0';
        o_MemWrite    <= '0';
        o_MemRead     <= '0';
        o_Branch      <= '0';
        
        o_BranchAddr  <= (others => '0');
        o_BranchTaken <= '0';
        o_ALUResult   <= (others => '0');
        o_WriteData   <= (others => '0');
        o_RS2Data     <= (others => '0');
        o_RDAddr      <= (others => '0');
        o_PCplus4     <= (others => '0');
        
      elsif i_WE = '1' then
        -- Normal operation
        o_RegWrite    <= i_RegWrite;
        o_MemToReg    <= i_MemToReg;
        o_MemWrite    <= i_MemWrite;
        o_MemRead     <= i_MemRead;
        o_Branch      <= i_Branch;
        o_Instr       <= i_Instr;
        
        o_BranchAddr  <= i_BranchAddr;
        o_BranchTaken <= i_BranchTaken;
        o_ALUResult   <= i_ALUResult;
        o_WriteData   <= i_WriteData;
        o_RS2Data     <= i_RS2Data;
        o_RDAddr      <= i_RDAddr;
        o_PCplus4     <= i_PCplus4;
      end if;
    end if;
  end process;
end behavioral;