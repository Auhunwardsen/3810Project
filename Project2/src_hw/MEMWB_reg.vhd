-- Pipeline Register: MEM/WB Stage
-- Stores memory stage outputs
library IEEE;
use IEEE.std_logic_1164.all;

entity MEMWB_reg is
  port(
    i_CLK     : in  std_logic;
    i_RST     : in  std_logic;
    i_WE      : in  std_logic;  -- Write enable (for stalling)
    i_flush   : in  std_logic;  -- Flush signal
    
    -- Control signals
    i_RegWrite  : in  std_logic;
    i_MemToReg  : in  std_logic;
    
    -- Data signals
    i_MemData   : in  std_logic_vector(31 downto 0);
    i_ALUResult : in  std_logic_vector(31 downto 0);
    i_RDAddr    : in  std_logic_vector(4 downto 0);
    
    -- Outputs to WB stage
    o_RegWrite  : out std_logic;
    o_MemToReg  : out std_logic;
    
    o_MemData   : out std_logic_vector(31 downto 0);
    o_ALUResult : out std_logic_vector(31 downto 0);
    o_RDAddr    : out std_logic_vector(4 downto 0)
  );
end MEMWB_reg;

architecture behavioral of MEMWB_reg is
begin
  process(i_CLK, i_RST)
  begin
    if i_RST = '1' then
      -- Reset all signals
      o_RegWrite  <= '0';
      o_MemToReg  <= '0';
      o_MemData   <= (others => '0');
      o_ALUResult <= (others => '0');
      o_RDAddr    <= (others => '0');
      
    elsif rising_edge(i_CLK) then
      if i_flush = '1' then
        -- Flush - insert NOP
        o_RegWrite  <= '0';
        o_MemToReg  <= '0';
        o_MemData   <= (others => '0');
        o_ALUResult <= (others => '0');
        o_RDAddr    <= (others => '0');
        
      elsif i_WE = '1' then
        -- Normal operation
        o_RegWrite  <= i_RegWrite;
        o_MemToReg  <= i_MemToReg;
        o_MemData   <= i_MemData;
        o_ALUResult <= i_ALUResult;
        o_RDAddr    <= i_RDAddr;
      end if;
    end if;
  end process;
end behavioral;