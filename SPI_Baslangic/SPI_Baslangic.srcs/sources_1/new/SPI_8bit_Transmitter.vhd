----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 13.05.2021 18:06:13
-- Design Name: 
-- Module Name: SPI_8bit_Transmitter - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.std_logic_signed.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_8bit_Transmitter is
    Port ( clk : in STD_LOGIC := '0';
           reset : in STD_LOGIC := '0';
           data_to_SDO : in STD_LOGIC_VECTOR (7 downto 0) := "10101100";
           data_from_SDI : in STD_LOGIC_VECTOR (7 downto 0) := "00000000";
           write_data_uploaded : in std_logic := '1';
           
           ready_for_new_data : out std_logic := '1';
           SDI : in STD_LOGIC;
           CS : out STD_LOGIC;
           SDO : out STD_LOGIC);
end SPI_8bit_Transmitter;

architecture Behavioral of SPI_8bit_Transmitter is
signal data_to_SDO_buffer : std_logic_vector (7 downto 0) := (others => '0');
signal transmitted_bit_count : std_logic_vector (3 downto 0) := (others => '0');
signal ready_to_send : std_logic := '0'; 
begin
    process (clk)
    begin
        if (reset = '1') then
        transmitted_bit_count <= "0000";
        ready_to_send <= '0';
        
        elsif (write_data_uploaded = '1') then
        data_to_SDO_buffer <= data_to_SDO;
        ready_to_send <= '1';
        ready_for_new_data <= '0';
        
        elsif (rising_edge(clk)) then
            if (ready_to_send = '1') then
            SDO <= data_to_SDO_buffer(0);
            data_to_SDO_buffer(6 downto 0) <= data_to_SDO_buffer(7 downto 1);
            transmitted_bit_count <= transmitted_bit_count+1;
                if (transmitted_bit_count = "1000") then
                    transmitted_bit_count <= "0000";
                    data_to_SDO_buffer <= "00000000";
                    ready_to_send <= '0';
                    ready_for_new_data <= '1';
    
                end if;
            end if;
        end if;     
    end process;
end Behavioral;
