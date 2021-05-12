----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12.05.2021 17:01:34
-- Design Name: 
-- Module Name: Training_TB - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Training_TB is
--  Port ( );
end Training_TB;

architecture bench of Training_TB is
    component Main_4Bit
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           en  : in STD_LOGIC;
           count_limit: in std_logic_vector(7 downto 0));
    end component;
    
signal  clk : STD_LOGIC := '0';
signal  rst : STD_LOGIC := '0';
signal  en  : STD_LOGIC := '0';
signal count_limit: std_logic_vector(7 downto 0) := (others => '0');
begin
    uut: Main_4Bit port map (clk=>clk, rst=>rst, en=>en, count_limit=>count_limit);
    stimulus : process
    begin
        wait for 100 ns;
                      





end bench;
