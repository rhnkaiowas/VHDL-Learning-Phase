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
	system_clk_i 		: in  STD_LOGIC; --System clock.
	SPI_en_i 			: in  STD_LOGIC; --SPI module activate flag from system.
	
	mosi_data_i 		: in  STD_LOGIC_VECTOR (mosi_data_length-1 downto 0); -- Data to be sent to slave.
	miso_data_o 		: out STD_LOGIC_VECTOR (miso_data_length-1 downto 0); -- Buffered data from slave to the system.
	miso_data_ready_o 	: out STD_LOGIC; -- Flag: Data has buffered from slave.
	
	cs_o 				: out STD_LOGIC; -- Chip select pin. Low during communication between master and slave..
	SPI_clk_o 			: out STD_LOGIC; -- Generated SPI Clock.
	
	mosi_o 				: out STD_LOGIC; -- Master out Slave in bit.
	miso_i 				: in  STD_LOGIC  -- Master in Slave out bit.
);
end SPI_Master_VHDL;
 architecture Behavioral of SPI_Master_VHDL is
 --------------------------------------------------------------------------------
-- CONSTANTS
constant c_system_clk_edgecntr_target	: integer := system_clk_freq/(SPI_clk_freq*2); --If system Clock 100Mhz and desired SPI_Clock 1Mhz;
                                                                                       --SPI_Clock should be notted every 50 rising edge of System_Clock.
 --------------------------------------------------------------------------------
-- INTERNAL SIGNALS
signal mosi_buffer			: std_logic_vector (mosi_data_length-1 downto 0) 	:= (others => '0');	-- Buffer area for data to be sent.
signal miso_buffer			: std_logic_vector (miso_data_length-1 downto 0) 	:= (others => '0'); -- Buffer area for data from slave.
 
signal SPI_clk_en			: std_logic := '0'; --Connected to 
signal SPI_clk				: std_logic := '0'; --Generated SPI clock
signal SPI_clk_prev			: std_logic := '0'; --The state of Generated SPI clock from previous state.
signal SPI_clk_rise			: std_logic := '0'; --Generated SPI clock rising edge detected flag.
signal SPI_clk_fall			: std_logic := '0'; --Generated SPI clock falling edge detected flag.
 
signal mosi_en				: std_logic := '0'; --Defines whether Data shifted out from MOSI pin on the rising edge or falling edge.
signal miso_en				: std_logic := '0'; --Defines whether Data sampled at the MISO pin on the rising edge or falling edge.
signal miso_got_first_bit   : std_logic := '0'; --Logic '1' after receiving first bit from slave.
 
signal system_clk_edgecntr	: integer range 0 to c_system_clk_edgecntr_target := 0; --System Clock edge count in order to generate SPI Clock.
                                                                                    --If system Clock 100Mhz and desired SPI_Clock 1Mhz;
                                                                                    --SPI_Clock should be 'not'ted every 50 rising edge of System_Clock.
                                                                                    --this means system_clk_freq/(SPI_clk_freq*2)
signal bit_counter 			: integer range 0 to 15 := 0;
--------------------------------------------------------------------------------

-- STATE DEFINITIONS
type states is (S_IDLE, S_TRANSFER);
signal state : states := S_IDLE;
--------------------------------------------------------------------------------

begin
--According to generic parameters of SPI_cpol and SPI_cpha;
--SPI_Mode_Setup process assigns mosi_en and miso_en internal signals to SPI_clk_fall or SPI_clk_rise in a combinational logic via "SPI_pol_phase" signal

SPI_Mode_Setup : process (SPI_clk_fall, SPI_clk_rise) begin
    if (SPI_cpol = '0') then
        
        if (SPI_cpha = '0') then    --SPI Mode 0
            mosi_en <= SPI_clk_fall; --Data shifted out on the falling edge
			miso_en	<= SPI_clk_rise; --Data sampled on rising edge
        
        elsif (SPI_cpha = '1') then --SPI Mode 1
            mosi_en <= SPI_clk_rise; --Data shifted out on the rising edge
			miso_en	<= SPI_clk_fall; --Data sampled on the falling edge
        end if;
    
    elsif (SPI_cpol = '1') then
        
        if (SPI_cpha = '0') then    --SPI Mode 2
            mosi_en <= SPI_clk_rise; --Data shifted out on the rising edge
			miso_en	<= SPI_clk_fall; --Data sampled on the falling edge	
        
        elsif (SPI_cpha = '1') then --SPI Mode 3
            mosi_en <= SPI_clk_fall; --Data shifted out on the falling edge
			miso_en	<= SPI_clk_rise; --Data sampled on the rising edge
        end if;
    end if;
 end process SPI_Mode_Setup;
 
--------------------------------------------------------------------------------
RISEFALL_DETECT : process (SPI_clk, SPI_clk_prev) begin
 	if (SPI_clk = '1' and SPI_clk_prev = '0') then --If now logic '1' and previous logic '0', that means rising edge detected.
		SPI_clk_rise <= '1';
	else
		SPI_clk_rise <= '0'; -- else not a rising edge.
	end if;
 
	if (SPI_clk = '0' and SPI_clk_prev = '1') then --If now logic '0' and previous logic '1', that means falling edge detected.
		SPI_clk_fall <= '1';
	else
		SPI_clk_fall <= '0'; -- else not a falling edge.
	end if;	
 end process RISEFALL_DETECT;
 --------------------------------------------------------------------------------
--In the MAIN process S_IDLE and S_TRANSFER states are implemented. 
--State changes from S_IDLE to S_TRANSFER when SPI_en_i input signal has the logic high value. 
--At S_TRANSFER cycle, mosi_buffer signal is assigned to mosi_data_i input signal. 

MAIN : process (system_clk_i) begin
if (rising_edge(system_clk_i)) then
 
    miso_data_ready_o <= '0';
	SPI_clk_prev	<= SPI_clk;
 
	case state is
 
--------------------------------------------------------------------------------	
		when S_IDLE =>	
 			cs_o				<= '1';
			mosi_o				<= '0';
			miso_data_ready_o	<= '0';			
			SPI_clk_en			<= '0';
			bit_counter			<= 	0; 
 
			if (SPI_cpol = '0') then
				SPI_clk_o			<= '0';
			else
				SPI_clk_o			<= '1';
			end if;	
 
			if (SPI_en_i = '1') then
				state			<= S_TRANSFER;
				SPI_clk_en		<= '1';
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
				        miso_data_ready_o   <= '1';
				        miso_got_first_bit  <= '0';				       
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
end process MAIN;
 
--------------------------------------------------------------------------------
--    In the SPI_clk_GEN process, internal SPI_clk signal is generated if SPI_clk_en signal is '1'. 
SPI_clk_GEN : process (system_clk_i) begin
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
end process SPI_clk_GEN;
 
end Behavioral;