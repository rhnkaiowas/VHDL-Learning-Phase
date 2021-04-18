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
    --Kullan�lacak SPI Modu.
    --Mode 0: Haberle�me ba�lamadan �nce ve haberle�me yok iken saat sinyali "low" seviyededir. Data, saat darbesinin d��en kenar�nda "de�i�tirilir(yaz�l�r)" ve y�kselen kenar�nda "okunur".
    --Mode 1: Haberle�me ba�lamadan �nce ve haberle�me yok iken saat sinyali "low" seviyededir. Data, saat darbesinin y�kselen kenar�nda "de�i�tirilir(yaz�l�r)" ve d��en kenar�nda "okunur".
    --Mode 2: Haberle�me ba�lamadan �nce ve haberle�me yok iken saat sinyali "high" seviyededir. Data, saat darbesinin y�kselen kenar�nda "de�i�tirilir(yaz�l�r)" ve d��en kenar�nda "okunur".
    --Mode 3: Haberle�me ba�lamadan �nce ve haberle�me yok iken saat sinyali "high" seviyededir. Data, saat darbesinin d��en kenar�nda "de�i�tirilir(yaz�l�r)" ve y�kselen kenar�nda "okunur".
    
    i_CLK_Edge_Count   : integer := 50); 
    -- Sistem Clock'a g�re SPI Clok oran�. FPGA CLK / 2* (CLKS_PER_HALF_BIT)= SPI_CLK.
    
    Port (  
            -- Ana Kontrol Sinyalleri
            i_Rst_L     :in std_logic; -- FPGA Reset
            i_CLK       :in std_logic; -- FPGA Clock
            
            --TX (MOSI) Sinyalleri
            i_TX_Byte   : in std_logic_vector(7 downto 0); --Slave'e iletilecek BYTE.
            i_TX_DV     : in std_logic; -- Data yollamaya haz�r i�aret�isi.
            o_TX_Ready  : out std_logic; --Transmitter bir sonraki g�nderilecek BYTE i�in haz�r i�aret�isi.
            
            --RX (MISO Sinyalleri)
            o_RX_DV     : out std_logic; --Byte i�eri aktarmak i�in haz�r i�aret�isi. 
            o_RX_Byte   : out std_logic_vector(7 downto 0); --Slave'den al�nm�� BYTE.
            
            --SPI Aray�z�
            o_SPI_Clk     : out STD_LOGIC;
            i_SPI_MISO    : in STD_LOGIC;
            o_SPI_MOSI    : out STD_LOGIC);

end SPI_Master_VHDL;

architecture Behavioral of SPI_Master_VHDL is

begin
    SPI_CLK: process (i_CLK,i_Rst_L)
    begin
        if (rising_edge(i_Rst_L)) then
        --FPGA resetlendi�inde ne yap�laca�� set edilecek.
        o_SPI_Clk <= '0';
        end if;
        
        if (rising_edge(i_CLK)) then
       o_SPI_Clk <= '1';
       else
       o_SPI_Clk <= '0';
        end if;
    end process SPI_CLK;
end Behavioral;
