@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2.2 (64-bit)
REM
REM Filename    : elaborate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for elaborating the compiled design
REM
REM Generated by Vivado on Thu May 13 20:02:03 +0300 2021
REM SW Build 3118627 on Tue Feb  9 05:14:06 MST 2021
REM
REM Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
REM
REM usage: elaborate.bat
REM
REM ****************************************************************************
REM elaborate design
echo "xelab -wto 286bb56e7ee0411bac8d40f4b0351c41 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot SPI_8bit_Transmitter_behav xil_defaultlib.SPI_8bit_Transmitter -log elaborate.log"
call xelab  -wto 286bb56e7ee0411bac8d40f4b0351c41 --incr --debug typical --relax --mt 2 -L xil_defaultlib -L secureip --snapshot SPI_8bit_Transmitter_behav xil_defaultlib.SPI_8bit_Transmitter -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
