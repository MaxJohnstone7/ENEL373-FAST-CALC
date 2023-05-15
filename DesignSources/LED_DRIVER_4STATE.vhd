----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 13.04.2023 00:13:28
-- Design Name:
-- Module Name: LED_DRIVER - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
--
-- Dependencies: A driver for the ARTIX-7 boards internal LEDS.
-- What LEDS are on is specified by a vector , so this module takes in
-- a state_vector with 4 possible states and maps every possible state to an output that results
-- in exactly 1 LED being on.
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.log2;
USE ieee.math_real.ceil;
ENTITY LED_DRIVER_4STATE IS
	PORT (
		state_vec : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		LED_VEC   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
	);
END LED_DRIVER_4STATE;

ARCHITECTURE Behavioral OF LED_DRIVER_4state IS
BEGIN
	PROCESS (state_vec)
	VARIABLE state_as_int : INTEGER := TO_INTEGER(unsigned(state_vec));
	BEGIN
		LED_VEC               <= (OTHERS => '0');
		LED_VEC(state_as_int) <= '1';
	END PROCESS;

END Behavioral;