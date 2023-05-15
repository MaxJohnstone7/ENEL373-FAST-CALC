----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Max Johnstone
-- 
-- Create Date: 11.04.2023 21:49:24
-- Design Name: 
-- Module Name: twos_comp_converter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: Module which converts an unsigned representation
-- of a number to a 2's complement representation using the neg flag.
-- An easy way of converting switch input values to 2's complement.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY twos_comp_converter IS
	GENERIC (input_size, output_size : INTEGER);
	PORT (
		neg       : IN std_logic;
		val       : IN std_logic_vector(input_size - 1 DOWNTO 0);
		val_2comp : OUT std_logic_vector(output_size - 1 DOWNTO 0)
	);
END twos_comp_converter;

ARCHITECTURE Behavioral OF twos_comp_converter IS
BEGIN
	PROCESS (val, neg)IS
	BEGIN
		IF neg = '1' THEN
			val_2comp <= std_logic_vector(signed(NOT('0' & val)) + 1);
		ELSE
			val_2comp <= std_logic_vector(RESIZE(unsigned(val), output_size));
		END IF;
	END PROCESS;
END Behavioral;
