----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 08.03.2023 11:18:13
-- Design Name:
-- Module Name: DISP_MUX - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: An 8-1 multiplexer for selecting between the 8 values
-- for each seven seg display.
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY display_mux IS
	PORT (
		D1, D2, D3, D4, D5, D6, D7, D8 : IN std_logic_vector (3 DOWNTO 0);--7seg display values
		sel                            : IN std_logic_vector(2 DOWNTO 0);--index of display to select
		O                              : OUT std_logic_vector (3 DOWNTO 0)
	);
END display_mux;

ARCHITECTURE DATAFLOW OF display_mux IS
	TYPE disp_val_arr IS ARRAY (7 DOWNTO 0) OF std_logic_vector(3 DOWNTO 0);
	SIGNAL inputs : disp_val_arr;
BEGIN
	inputs <= (d8, d7, d6, d5, d4, d3, d2, d1);
	O      <= inputs(to_integer(unsigned(sel)));
END Dataflow;