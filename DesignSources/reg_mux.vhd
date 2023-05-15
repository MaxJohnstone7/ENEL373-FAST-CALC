----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 10.04.2023 14:58:08
-- Design Name:
-- Module Name: reg_mux - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: multiplexer that selects a register
-- out of (Operand A, Operand B, Opcode and result) to output.
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
USE IEEE.NUMERIC_STD.ALL;
ENTITY reg_mux IS
	PORT (
		A, B   : IN std_logic_vector (11 DOWNTO 0);
		OPCODE : IN std_logic_vector(3 DOWNTO 0);
		RES    : IN std_logic_vector (23 DOWNTO 0);
		sel    : IN std_logic_vector(1 DOWNTO 0);--index of display to select
		O      : OUT std_logic_vector (23 DOWNTO 0)
	);
END reg_mux;

ARCHITECTURE Behavioral OF reg_mux IS

BEGIN
	PROCESS (sel, A, B, OPCODE, RES) IS
	BEGIN
		CASE sel IS
			WHEN "00" => 
				O <= std_logic_vector(resize(signed(A), 24));
			WHEN "01" => 
				O <= std_logic_vector(resize(unsigned(OPCODE), 24));
			WHEN "10" => 
				O <= std_logic_vector(resize(signed(B), 24));
			WHEN "11" => 
				O <= RES;
		END CASE;
	END PROCESS;
END Behavioral;