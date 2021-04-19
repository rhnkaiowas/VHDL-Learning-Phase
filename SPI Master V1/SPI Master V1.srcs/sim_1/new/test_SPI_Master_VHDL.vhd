----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.04.2021 17:27:15
-- Design Name: 
-- Module Name: test_SPI_Master_VHDL - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_SPI_Master_VHDL is
    Port ( i_CLK       :in std_logic; -- FPGA Clock
           o_SPI_Clk     : out STD_LOGIC);
end test_SPI_Master_VHDL;

architecture Behavioral of test_SPI_Master_VHDL is

begin

i_CLK <= '1';

wait 10ns;



end Behavioral;
