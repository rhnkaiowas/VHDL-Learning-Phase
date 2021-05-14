----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.05.2021 16:59:02
-- Design Name: 
-- Module Name: Clock_Generator - Behavioral
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
use ieee.numeric_std.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Clock_Generator is
generic(
    N                     : integer := 8;      -- number of clks generated
    System_Clock          : integer := 10_000_000;
    Target_SPI_Clock      : integer := 1_000_000 );  -- input clock divider to generate output serial clock; o_sclk frequency = i_clk/(2*CLK_DIV)
Port ( 
    clk : in STD_LOGIC := '0';
    en : in STD_LOGIC := '0';
    clk_generated : out STD_LOGIC);
end Clock_Generator;

architecture Behavioral of Clock_Generator is

constant SPI_Clock_Edge_Counter : integer := System_Clock/Target_SPI_Clock;

signal clk_EN               : std_logic := '0';
signal clk_counter          : integer range 0 to SPI_Clock_Edge_Counter;
signal gclk_state            : std_logic := '1';
begin
clock_generation :process (clk)
begin
if (rising_edge(clk)) then
    if (en = '1') then
        clk_counter <= clk_counter + 1;   
        if (clk_counter = SPI_Clock_Edge_Counter) then
        gclk_state <= not gclk_state;
        clk_counter <= 0;
        end if;
       
        if (gclk_state = '1') then
        clk_generated <= '1';
        else
        clk_generated <= '0';
        end if;
    end if;
end if;
end process;
end Behavioral;
