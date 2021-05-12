----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2021 11:36:55
-- Design Name: 
-- Module Name: Main_4Bit - Behavioral
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

entity Main_4Bit is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC := '0');
end Main_4Bit;

architecture Behavioral of Main_4Bit is
signal four_bit_counter: std_logic_vector(3 downto 0) := (others => '0');
signal count_of_4bit: std_logic_vector(3 downto 0) := (others => '0');

begin
   process (clk)
    begin
        if (rst = '1') then 
        four_bit_counter  <= "0000";
        count_of_4bit <= "0000";
        
        elsif (rising_edge(clk)) then
                four_bit_counter <= four_bit_counter + '1';
                if (four_bit_counter = "1111") then
                    count_of_4bit <= count_of_4bit + '1';
                end if;
        end if;
        end process;

end Behavioral;
