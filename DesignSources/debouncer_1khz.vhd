----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 09.04.2023 21:06:29
-- Design Name:
-- Module Name: debouncer - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A switch 
-- debouncer designed to be used with a 1khz clock input
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
ENTITY debouncer_1khz IS
	PORT (
		sw, clk : IN STD_LOGIC;
	Q       : OUT STD_LOGIC := '0');
END debouncer_1khz;

ARCHITECTURE Behavioral OF debouncer_1khz IS
	SIGNAL pushed         : std_logic := '0';
	SIGNAL count          : std_logic_vector(3 DOWNTO 0) := (OTHERS => '0');
	CONSTANT stable_count : std_logic_vector(3 DOWNTO 0) := "1100";
	--for 1khz clock corresponds to wait time of 20ms
	--until system is considered stable
BEGIN
	PROCESS (clk, sw)
	BEGIN
		IF (rising_edge(clk)) THEN
			IF count = stable_count THEN
				--only assert the output to the state
				--if the state has stayed the same for 20ms
				Q     <= pushed;
				count <= (OTHERS => '0');
				--checks sw state against last sw_state
			ELSIF sw /= pushed THEN
				count <= (OTHERS => '0'); --reset the count as output is unstable
			ELSE
				count <= count + 1; --increment the count as output is stable
			END IF;
		END IF;
		pushed <= sw;
	END PROCESS; 
END Behavioral;