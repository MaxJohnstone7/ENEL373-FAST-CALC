----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 07.04.2023 19:26:30
-- Design Name:
-- Module Name: generic_sync_counter - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: Generic syncronous counter which
-- resets at a given max_count
--
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.std_logic_signed.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.MATH_REAL.ALL;

ENTITY generic_sync_counter IS

	GENERIC (size : INTEGER := 1); --number of bits the counter is

	PORT (
		clk, reset, count_up : IN std_logic;
		max_count            : IN std_logic_vector(size - 1 DOWNTO 0); --number to count up to
		count                : OUT std_logic_vector(size - 1 DOWNTO 0)
	);
END generic_sync_counter;
ARCHITECTURE Behavioral OF generic_sync_counter IS
	SIGNAL internal_count : std_logic_vector(size - 1 DOWNTO 0);
BEGIN
	PROCESS (clk, reset, max_count, count_up)
	BEGIN
		IF (reset = '1') THEN
			--reset logic
			IF (count_up = '1') THEN
				internal_count <= (OTHERS => '0'); --sets count to zero
			ELSE
				internal_count <= max_count; --set count to max
			END IF;
			--count logic
		ELSIF (rising_edge(clk)) THEN
			IF (count_up = '1') THEN
				IF (internal_count = max_count) THEN
					internal_count <= (OTHERS => '0');--sets count to zero
				ELSE
					internal_count <= internal_count + 1;--increment count
				END IF;
			ELSE
				IF (internal_count = 0) THEN
					internal_count <= max_count; --set count to max d
				ELSE
					internal_count <= internal_count - 1;--decrement count
				END IF;
			END IF;
		END IF;
	END PROCESS;
	count <= internal_count;
END Behavioral;