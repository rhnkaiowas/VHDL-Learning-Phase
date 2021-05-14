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
    Port ( clk : in STD_LOGIC := '0';
           rst : in STD_LOGIC := '0';
           en  : in STD_LOGIC := '0';
           count_limit: in std_logic_vector(7 downto 0) := "00101101");
end Main_4Bit;

architecture Behavioral of Main_4Bit is
signal four_bit_counter: std_logic_vector(3 downto 0) := (others => '0');
signal count_of_4bits: std_logic_vector(3 downto 0) := (others => '0');
signal count_limit_LS_four: std_logic_vector(3 downto 0) := (others => '0');
signal count_limit_MS_four: std_logic_vector(3 downto 0) := (others => '0');
begin
count_limit_LS_four <= count_limit(3 downto 0);
count_limit_MS_four <= count_limit(7 downto 4);
   process (clk)
    begin
        if (rst = '1') then 
        four_bit_counter  <= "0000";
        count_of_4bits <= "0000";
        
        elsif (rising_edge(clk)) then
            if (en= '1') then
                four_bit_counter <= four_bit_counter + '1';
                if (four_bit_counter = "1111") then
                    count_of_4bits <= count_of_4bits + '1';
                elsif (count_of_4bits = count_limit_MS_four and four_bit_counter = count_limit_LS_four) then
                four_bit_counter  <= "0000";
                count_of_4bits <= "0000";
                end if;
            end if;   
        end if;
        end process;

end Behavioral;
