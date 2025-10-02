-- Testbench for mux32_1
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_mux32_1 is end entity;

architecture tb of tb_mux32_1 is
    signal data_in : std_logic_vector(32*32-1 downto 0);
    signal sel     : std_logic_vector(4 downto 0);
    signal y       : std_logic_vector(31 downto 0);
begin
    uut: entity work.mux32_1 port map(data_in => data_in, sel => sel, y => y);

    stim_proc: process
    begin
        -- Initialize data_in with unique values for each word
        for i in 0 to 31 loop
            data_in((i+1)*32-1 downto i*32) <= std_logic_vector(to_unsigned(i,32));
        end loop;

        -- Step through select lines
        for i in 0 to 31 loop
            sel <= std_logic_vector(to_unsigned(i, 5));
            wait for 10 ns;
        end loop;
        wait;
    end process;
end architecture;