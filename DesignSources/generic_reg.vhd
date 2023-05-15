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
-- Description: A generic register. It's bit-length can be specified.
-- It has a an output and input enable aswell as
-- an asyncronous reset.
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY generic_reg IS
	GENERIC (
		--one byte by default
		reg_size : POSITIVE := 8
	);
	PORT (
		clk, in_en, rst, out_en : IN std_logic;
		D                       : IN std_logic_vector(reg_size - 1 DOWNTO 0);
		r_out                   : OUT std_logic_vector(reg_size - 1 DOWNTO 0)
	);
END generic_reg;

ARCHITECTURE Behavioral OF generic_reg IS
	SIGNAL Q : std_logic_vector(reg_size - 1 DOWNTO 0);
BEGIN
	PROCESS (clk, rst)
	BEGIN
		--async reset
		IF (rst = '1') THEN
			Q <= (OTHERS => '0');
		ELSIF (rising_edge(clk)) THEN
			IF in_en = '1' THEN
				Q <= D; 
			END IF;
		END IF;
	END PROCESS;
	--output enable
	r_out <= (OTHERS => 'Z') WHEN out_en = '0' ELSE Q;
END Behavioral;