-----------------------------------------------------------------------------
-- Entity: tb_5t32decoder.vhd  
-- Name: Austin Hunwardsen
-- Description: tb for decoder5t32.vhd
-- Date: 9/18/25
-----------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_decoder5t32 is
end entity tb_decoder5t32;

architecture sim of tb_decoder5t32 is
    signal t_A   : std_logic_vector(4 downto 0);
    signal t_EN  : std_logic;
    signal t_Q   : std_logic_vector(31 downto 0);

    component decoder5t32
        port (
            i_A  : in  std_logic_vector(4 downto 0);
            i_EN : in  std_logic;
            o_Q  : out std_logic_vector(31 downto 0)
        );
    end component;

begin
    uut: decoder5t32
        port map (
            i_A  => t_A,
            i_EN => t_EN,
            o_Q  => t_Q
        );

    stimulus: process
    begin
        -- Test case 1: Enable off
        t_EN <= '0';
        t_A <= "00000";
        wait for 10 ns;

        -- Test case 2: Enable on, input 0
        t_EN <= '1';
        t_A <= "00000";
        wait for 10 ns;

        -- Test case 3: Enable on, input 1
        t_A <= "00001";
        wait for 10 ns;

        -- Test case 4: Enable on, input 31
        t_A <= "11111";
        wait for 10 ns;

        wait;
    end process;
end architecture sim;