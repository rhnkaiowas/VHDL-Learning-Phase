--------------------------------------------------------------------------------
-- AUTHOR:			Erhan ERGÜN
-- CREATED:			15.05.2021
--
--------------------------------------------------------------------------------
-- DESCRIPTION:		
--This module implements master part of SPI communication interface and can be used to any SPI slave IC.

--You can configure bit count of MOSI and MISO data with mosi_data_length and miso_data_length integers. Up to 16 bits tested.

--You can configure system clock and desired SPI clock with system_clk_freq and SPI_clk_freq.

--SPI module enabled with SPI_en_i logic '1'.

--Inorder to send data from MOSI;
--first set data to mosi_data_i and  set SPI_cpol and SPI_cpha
--then set SPI_en_i to logic '1'.

--miso_data_ready_o output signal has the logic high value for one system_clk_freq clock cycle as read or/and write operation finished. 

--miso_data_o output signal has the data read from slave IC. 

--In order to finish read or/and write cycle, SPI_en_i signal should be kept high.

--When miso_data_ready_o output signal gets high this means transaction has finished. 
--This means You can get data from miso_data_o and after got data SPI_en_i input signal should be assigned to logic '0'.

--SPI_cpol and SPI_cpha parameters are clock polarity and clock phase.

--SPI Mode 	CPOL 	CPHA 	Clock Polarity in Idle State 			Clock Phase Used to Sample and/or Shift the Data
--	0 		 0 		 0 		  		Logic low 					Data sampled on rising edge and shifted out on the falling edge
--	1 		 0 		 1 		  		Logic low 					Data sampled on the falling edge and shifted out on the rising edge
--	2 	 	 1 		 0 		  		Logic high 					Data sampled on the falling edge and shifted out on the rising edge
--	3 		 1 		 1 		  		Logic high 					Data sampled on the rising edge and shifted out on the falling edge

--------------------------------------------------------------------------------
-- VHDL DIALECT: VHDL '93
--------------------------------------------------------------------------------
-- PROJECT 	: General purpose
-- BOARD 	: General purpose
-- ENTITY 	: SPI_Master_VHDL
--------------------------------------------------------------------
-- FILE 	: SPI_Master_VHDL.vhd
--------------------------------------------------------------------------------
-- REVISION HISTORY:
-- REVISION  DATE 		 AUTHOR        COMMENT
-- --------  ----------  ------------  -----------
-- 1.0	     15.05.2021	 Erhan Ergün   V1
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
 
entity SPI_Master_VHDL is
generic (
	system_clk_freq 	: integer := 100_000_000;
	SPI_clk_freq 		: integer := 1_000_000;
	
	SPI_cpol			: std_logic := '0';
	SPI_cpha			: std_logic := '0';
	
	mosi_data_length	: integer := 8;
	miso_data_length	: integer := 8
);
Port ( 	
	system_clk_i 		: in  STD_LOGIC;
	SPI_en_i 			: in  STD_LOGIC;
	
	mosi_data_i 		: in  STD_LOGIC_VECTOR (mosi_data_length-1 downto 0);
	miso_data_o 		: out STD_LOGIC_VECTOR (miso_data_length-1 downto 0);
	miso_data_ready_o 	: out STD_LOGIC;
	
	cs_o 				: out STD_LOGIC;
	SPI_clk_o 			: out STD_LOGIC;
	
	mosi_o 				: out STD_LOGIC;
	miso_i 				: in  STD_LOGIC
);
end SPI_Master_VHDL;
 architecture Behavioral of SPI_Master_VHDL is
 --------------------------------------------------------------------------------
-- CONSTANTS
constant c_system_clk_edgecntr_target	: integer := system_clk_freq/(SPI_clk_freq*2);
 --------------------------------------------------------------------------------
-- INTERNAL SIGNALS
signal mosi_buffer			: std_logic_vector (mosi_data_length-1 downto 0) 	:= (others => '0');	
signal miso_buffer			: std_logic_vector (miso_data_length-1 downto 0) 	:= (others => '0');
 
signal SPI_clk_en			: std_logic := '0';
signal SPI_clk				: std_logic := '0';
signal SPI_clk_prev			: std_logic := '0';
signal SPI_clk_rise			: std_logic := '0';
signal SPI_clk_fall			: std_logic := '0';
 
signal SPI_pol_phase		: std_logic_vector (1 downto 0) := (others => '0');
signal mosi_en				: std_logic := '0';
signal miso_en				: std_logic := '0';
signal miso_got_first_bit   : std_logic := '0';
 
signal system_clk_edgecntr	: integer range 0 to c_system_clk_edgecntr_target := 0;
signal bit_counter 			: integer range 0 to 15 := 0;
 
--------------------------------------------------------------------------------
-- STATE DEFINITIONS
type states is (S_IDLE, S_TRANSFER);
signal state : states := S_IDLE;
 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
begin
 SPI_pol_phase <= SPI_cpol & SPI_cpha;
 --------------------------------------------------------------------------------
-- SAMPLE_EN process assigns mosi_en and miso_en internal signals to SPI_clk_fall or SPI_clk_rise in a combinational logic according to 
-- generic parameters of SPI_cpol and SPI_cpha via SPI_pol_phase signal.
P_SAMPLE_EN : process (SPI_pol_phase, SPI_clk_fall, SPI_clk_rise) begin
 	case SPI_pol_phase is
 		when "00" =>
 			mosi_en <= SPI_clk_fall;
			miso_en	<= SPI_clk_rise;
 		
		when "01" =>
 			mosi_en <= SPI_clk_rise;
			miso_en	<= SPI_clk_fall;		
 		
		when "10" =>
 			mosi_en <= SPI_clk_rise;
			miso_en	<= SPI_clk_fall;			
 		
		when "11" =>
 			mosi_en <= SPI_clk_fall;
			miso_en	<= SPI_clk_rise;	
 		when others =>
 	end case;
 end process P_SAMPLE_EN;
 
--------------------------------------------------------------------------------
--    RISEFALL_DETECT process assigns SPI_clk_rise and SPI_clk_fall signals in a combinational logic.
P_RISEFALL_DETECT : process (SPI_clk, SPI_clk_prev) begin
 	if (SPI_clk = '1' and SPI_clk_prev = '0') then
		SPI_clk_rise <= '1';
	else
		SPI_clk_rise <= '0';
	end if;
 
	if (SPI_clk = '0' and SPI_clk_prev = '1') then
		SPI_clk_fall <= '1';
	else
		SPI_clk_fall <= '0';
	end if;	
 end process P_RISEFALL_DETECT;
 --------------------------------------------------------------------------------
--In the MAIN process S_IDLE and S_TRANSFER states are implemented. 
--State changes from S_IDLE to S_TRANSFER when SPI_en_i input signal has the logic high value. 
--At S_TRANSFER cycle, mosi_buffer signal is assigned to mosi_data_i input signal. 

P_MAIN : process (system_clk_i) begin
if (rising_edge(system_clk_i)) then
 
    miso_data_ready_o <= '0';
	SPI_clk_prev	<= SPI_clk;
 
	case state is
 
--------------------------------------------------------------------------------	
		when S_IDLE =>	
 			cs_o				<= '1';
			mosi_o				<= '0';
			miso_data_ready_o	<= '0';			
			SPI_clk_en				<= '0';
			bit_counter			<= 	0; 
 
			if (SPI_cpol = '0') then
				SPI_clk_o			<= '0';
			else
				SPI_clk_o			<= '1';
			end if;	
 
			if (SPI_en_i = '1') then
				state			<= S_TRANSFER;
				SPI_clk_en			<= '1';
				mosi_buffer		<= mosi_data_i;
				mosi_o			<= mosi_data_i(mosi_data_length-1);
				miso_buffer		<= x"00";
			end if;
 --------------------------------------------------------------------------------			
		when S_TRANSFER =>		
 			cs_o	<= '0';
			mosi_o	<= mosi_buffer(mosi_data_length-1);
  
			if (SPI_cpha = '1') then	
 
				if (bit_counter = 0) then
					SPI_clk_o	<= SPI_clk;
					if (miso_en = '1') then
						miso_buffer(0)		<= miso_i;
						miso_buffer(miso_data_length-1 downto 1) 	<= miso_buffer(miso_data_length-2 downto 0);
						bit_counter			<= bit_counter + 1;
						miso_got_first_bit   	<= '1';
					end if;				
				
				elsif (bit_counter = miso_data_length) then
				    if (miso_got_first_bit = '1') then
				        miso_data_ready_o	<= '1';
				        miso_got_first_bit   	<= '0';				       
				    end if;					
					miso_data_o		<= miso_buffer;
					if (mosi_en = '1') then
						if (SPI_en_i = '1') then
							mosi_buffer		<= mosi_data_i;
							mosi_o			<= mosi_data_i(7);	
							SPI_clk_o			<= SPI_clk;							
							bit_counter		<= 0;
						else
							state			<= S_IDLE;
							cs_o			<= '1';								
						end if;	
					end if;
				
				elsif (bit_counter = miso_data_length+1) then
					if (miso_en = '1') then
						state				<= S_IDLE;
						cs_o				<= '1';
					end if;						
				
				else
					SPI_clk_o	<= SPI_clk;
					if (miso_en = '1') then
						miso_buffer(0)		<= miso_i;
						miso_buffer(miso_data_length-1 downto 1) 	<= miso_buffer(miso_data_length-2 downto 0);
						bit_counter			<= bit_counter + 1;
					end if;
					if (mosi_en = '1') then
						mosi_o				<= mosi_buffer(mosi_data_length-1);
						mosi_buffer(mosi_data_length-1 downto 1) 	<= mosi_buffer(mosi_data_length-2 downto 0);
					end if;
				end if;
 
			else	-- SPI_cpha = '0'
 				if (bit_counter = 0) then
					SPI_clk_o	<= SPI_clk;					
					if (miso_en = '1') then
						miso_buffer(0)		<= miso_i;
						miso_buffer(miso_data_length-1 downto 1) 	<= miso_buffer(miso_data_length-2 downto 0);
						bit_counter			<= bit_counter + 1;
						miso_got_first_bit       <= '1';
					end if;
				
				elsif (bit_counter = miso_data_length) then				
                    if (miso_got_first_bit = '1') then
                        miso_data_ready_o   <= '1';
                        miso_got_first_bit   	<= '0';                       
                    end if;
					miso_data_o				<= miso_buffer;
					SPI_clk_o					<= SPI_clk;
					if (mosi_en = '1') then
						if (SPI_en_i = '1') then
							mosi_buffer		<= mosi_data_i;
							mosi_o			<= mosi_data_i(mosi_data_length-1);		
							bit_counter		<= 0;
						else
							bit_counter 	<= bit_counter + 1;
						end if;	
						if (miso_en = '1') then
							state 			<= S_IDLE;
							cs_o 			<= '1';							
						end if;
					end if;		
				
				elsif (bit_counter = miso_data_length+1) then
					if (miso_en = '1') then
						state				<= S_IDLE;
						cs_o				<= '1';
					end if;
				
				else
					SPI_clk_o 					<= SPI_clk;
					if (miso_en = '1') then
						miso_buffer(0) 		<= miso_i;
						miso_buffer(miso_data_length-1 downto 1) 	<= miso_buffer(miso_data_length-2 downto 0);
						bit_counter 		<= bit_counter + 1;
					end if;
					if (mosi_en = '1') then
						mosi_buffer(mosi_data_length-1 downto 1) 	<= mosi_buffer(mosi_data_length-2 downto 0);
					end if;
				end if;			
 			end if;
 	end case;
 end if;
end process P_MAIN;
 
--------------------------------------------------------------------------------
--    In the SPI_clk_GEN process, internal SPI_clk signal is generated if SPI_clk_en signal is '1'. 
P_SPI_clk_GEN : process (system_clk_i) begin
if (rising_edge(system_clk_i)) then
 
	if (SPI_clk_en = '1') then
		if system_clk_edgecntr = c_system_clk_edgecntr_target-1 then
			SPI_clk 		<= not SPI_clk;
			system_clk_edgecntr	<= 0;
		else
			system_clk_edgecntr	<= system_clk_edgecntr + 1;
		end if;	
	
	else
		system_clk_edgecntr		<= 0;
		if (SPI_cpol = '1') then
			SPI_clk		<= '1';
		else
			SPI_clk		<= '0';
		end if;
	end if;
 end if;
end process P_SPI_clk_GEN;
 
end Behavioral;