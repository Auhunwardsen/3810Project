-- Forwarding Unit
-- Implements data forwarding to resolve RAW hazards
library IEEE;
use IEEE.std_logic_1164.all;

entity forwarding_unit is
  port(
    -- Source register addresses from ID/EX stage
    i_IDEX_RS1      : in std_logic_vector(4 downto 0);
    i_IDEX_RS2      : in std_logic_vector(4 downto 0);
    
    -- Destination register addresses from later stages
    i_EXMEM_RD      : in std_logic_vector(4 downto 0);
    i_MEMWB_RD      : in std_logic_vector(4 downto 0);
    
    -- Write enable signals from later stages
    i_EXMEM_RegWrite : in std_logic;
    i_MEMWB_RegWrite : in std_logic;
    
    -- Forwarding control outputs
    o_Forward_A     : out std_logic_vector(1 downto 0);  -- For ALU input A (RS1)
    o_Forward_B     : out std_logic_vector(1 downto 0)   -- For ALU input B (RS2)
  );
end forwarding_unit;

architecture behavioral of forwarding_unit is
begin
  
  -- Forwarding logic for ALU input A (RS1)
  process(i_IDEX_RS1, i_EXMEM_RD, i_MEMWB_RD, i_EXMEM_RegWrite, i_MEMWB_RegWrite)
  begin
    -- Priority: EX/MEM stage forwarding over MEM/WB stage forwarding
    if (i_EXMEM_RegWrite = '1' and i_EXMEM_RD /= "00000" and i_EXMEM_RD = i_IDEX_RS1) then
      o_Forward_A <= "10";  -- Forward from EX/MEM stage
    elsif (i_MEMWB_RegWrite = '1' and i_MEMWB_RD /= "00000" and i_MEMWB_RD = i_IDEX_RS1) then
      o_Forward_A <= "01";  -- Forward from MEM/WB stage
    else
      o_Forward_A <= "00";  -- No forwarding, use register file
    end if;
  end process;
  
  -- Forwarding logic for ALU input B (RS2)
  process(i_IDEX_RS2, i_EXMEM_RD, i_MEMWB_RD, i_EXMEM_RegWrite, i_MEMWB_RegWrite)
  begin
    -- Priority: EX/MEM stage forwarding over MEM/WB stage forwarding
    if (i_EXMEM_RegWrite = '1' and i_EXMEM_RD /= "00000" and i_EXMEM_RD = i_IDEX_RS2) then
      o_Forward_B <= "10";  -- Forward from EX/MEM stage
    elsif (i_MEMWB_RegWrite = '1' and i_MEMWB_RD /= "00000" and i_MEMWB_RD = i_IDEX_RS2) then
      o_Forward_B <= "01";  -- Forward from MEM/WB stage
    else
      o_Forward_B <= "00";  -- No forwarding, use register file
    end if;
  end process;
  
end behavioral;