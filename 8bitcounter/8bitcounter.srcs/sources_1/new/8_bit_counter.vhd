----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08.05.2021 17:30:05
-- Design Name: 
-- Module Name: 8_bit_counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity eightbitcounter is
    Port (  clk,reset : in STD_LOGIC;
            first_4bit_flag : out STD_LOGIC;
            second_4bit_flag : out STD_LOGIC);
end eightbitcounter;

architecture Behavioral of eightbitcounter is
signal first_4bit: std_logic_vector(3 downto 0);
signal second_4bit: std_logic_vector(3 downto 0);
signal first_4bit_progress: std_logic := '1';
signal second_4bit_progress: std_logic := '0';
begin
    process (clk)
    begin
        if (reset = '1') then 
        first_4bit  <= "0000";
        second_4bit <= "0000";
        first_4bit_progress <= '1';
        elsif (rising_edge(clk)) then
            if (first_4bit_progress = '1') then
                if (first_4bit = "1111") then
                    first_4bit <= "0000";
                    first_4bit_progress <= '0';
                else
                first_4bit <= first_4bit + '1';
                end if;
            else
            if (second_4bit = "1111") then
                    second_4bit <= "0000";
                    first_4bit_progress <= '1';
                else
                second_4bit <= second_4bit + '1';
                end if;
            end if;
        end if;
        end process;
end Behavioral;
