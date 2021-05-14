@echo off
REM ****************************************************************************
REM Vivado (TM) v2020.2.2 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Thu May 13 20:02:05 +0300 2021
REM SW Build 3118627 on Tue Feb  9 05:14:06 MST 2021
REM
REM Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
REM simulate design
echo "xsim SPI_8bit_Transmitter_behav -key {Behavioral:sim_1:Functional:SPI_8bit_Transmitter} -tclbatch SPI_8bit_Transmitter.tcl -log simulate.log"
call xsim  SPI_8bit_Transmitter_behav -key {Behavioral:sim_1:Functional:SPI_8bit_Transmitter} -tclbatch SPI_8bit_Transmitter.tcl -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0