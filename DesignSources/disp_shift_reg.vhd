----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 07.04.2023 14:21:45
-- Design Name:
-- Module Name: generic_reg - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A shift register that resets to a specified
-- start value when the output = a specified reset value.
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY disp_shift_reg IS
	GENERIC (
		--one byte by default
		reg_size : POSITIVE := 8
	);
	PORT (
		clk, SI   : IN std_logic;
		reset_val : IN std_logic_vector(reg_size - 1 DOWNTO 0);--value which reset should ocurr
		start_val : IN std_logic_vector(reg_size - 1 DOWNTO 0);--value to start on
		SO        : OUT std_logic;
		Q         : OUT std_logic_vector(reg_size - 1 DOWNTO 0)
	);
END disp_shift_reg;
ARCHITECTURE Behavioral OF disp_shift_reg IS
	SIGNAL shift_bits : std_logic_vector(reg_size - 1 DOWNTO 0);

BEGIN
	PROCESS (clk)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF (reset_val = shift_bits) THEN
				shift_bits <= start_val;--reset to start val
			ELSE
				shift_bits <= shift_bits(reg_size - 2 DOWNTO 0) & SI;
			END IF;
		END IF;
	END PROCESS;
	Q  <= shift_bits;
	SO <= shift_bits(reg_size - 1);
END Behavioral;