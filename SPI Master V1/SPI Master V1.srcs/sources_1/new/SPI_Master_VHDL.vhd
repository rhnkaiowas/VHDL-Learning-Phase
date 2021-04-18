----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.04.2021 12:38:58
-- Design Name: 
-- Module Name: SPI_Master_VHDL - Behavioral
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
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SPI_Master_VHDL is

    generic (
    SPI_MODE            : integer := 0; 
    --Kullanýlacak SPI Modu.
    --Mode 0: Haberleþme baþlamadan önce ve haberleþme yok iken saat sinyali "low" seviyededir. Data, saat darbesinin düþen kenarýnda "deðiþtirilir(yazýlýr)" ve yükselen kenarýnda "okunur".
    --Mode 1: Haberleþme baþlamadan önce ve haberleþme yok iken saat sinyali "low" seviyededir. Data, saat darbesinin yükselen kenarýnda "deðiþtirilir(yazýlýr)" ve düþen kenarýnda "okunur".
    --Mode 2: Haberleþme baþlamadan önce ve haberleþme yok iken saat sinyali "high" seviyededir. Data, saat darbesinin yükselen kenarýnda "deðiþtirilir(yazýlýr)" ve düþen kenarýnda "okunur".
    --Mode 3: Haberleþme baþlamadan önce ve haberleþme yok iken saat sinyali "high" seviyededir. Data, saat darbesinin düþen kenarýnda "deðiþtirilir(yazýlýr)" ve yükselen kenarýnda "okunur".
    
    i_CLK_Edge_Count   : integer := 50); 
    -- Sistem Clock'a göre SPI Clok oraný. FPGA CLK / 2* (CLKS_PER_HALF_BIT)= SPI_CLK.
    
    Port (  
            -- Ana Kontrol Sinyalleri
            i_Rst_L     :in std_logic; -- FPGA Reset
            i_CLK       :in std_logic; -- FPGA Clock
            
            --TX (MOSI) Sinyalleri
            i_TX_Byte   : in std_logic_vector(7 downto 0); --Slave'e iletilecek BYTE.
            i_TX_DV     : in std_logic; -- Data yollamaya hazýr iþaretçisi.
            o_TX_Ready  : out std_logic; --Transmitter bir sonraki gönderilecek BYTE için hazýr iþaretçisi.
            
            --RX (MISO Sinyalleri)
            o_RX_DV     : out std_logic; --Byte içeri aktarmak için hazýr iþaretçisi. 
            o_RX_Byte   : out std_logic_vector(7 downto 0); --Slave'den alýnmýþ BYTE.
            
            --SPI Arayüzü
            o_SPI_Clk     : out STD_LOGIC;
            i_SPI_MISO    : in STD_LOGIC;
            o_SPI_MOSI    : out STD_LOGIC);

end SPI_Master_VHDL;

architecture Behavioral of SPI_Master_VHDL is

begin
    SPI_CLK: process (i_CLK,i_Rst_L)
    begin
        if (rising_edge(i_Rst_L)) then
        --FPGA resetlendiðinde ne yapýlacaðý set edilecek.
        o_SPI_Clk <= '0';
        end if;
        
        if (rising_edge(i_CLK)) then
       o_SPI_Clk <= '1';
       else
       o_SPI_Clk <= '0';
        end if;
    end process SPI_CLK;
end Behavioral;
