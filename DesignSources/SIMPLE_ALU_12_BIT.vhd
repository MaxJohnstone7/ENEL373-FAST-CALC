----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 07.04.2023 16:51:41
-- Design Name:
-- Module Name: SIMPLE_ALU_12_BIT - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A 12-bit input ALU that implements addition,subtraction,
-- multiplication,division and exponentation.
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
ENTITY SIMPLE_ALU_12_BIT IS
	GENERIC (
		in_size     : INTEGER := 12;
		opcode_size : INTEGER := 4;
		res_size    : INTEGER := 24
	);
	PORT (
		--inputs
		A, B   : IN std_logic_vector (in_size - 1 DOWNTO 0);
		opcode : IN STD_LOGIC_VECTOR (opcode_size - 1 DOWNTO 0);
		clk    : IN std_logic; --only used for exponentiation
		--outputs
		res_out  : OUT std_logic_vector (res_size - 1 DOWNTO 0);--all signed numbers res_size-1 bits or less can be written to the display
		overflow : OUT STD_LOGIC
	);
END SIMPLE_ALU_12_BIT;
ARCHITECTURE Behav_Struct OF SIMPLE_ALU_12_BIT IS
	COMPONENT EXPONENTIATOR IS
		PORT (
			clk      : IN STD_LOGIC;
			A        : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			B        : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
			res      : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
			overflow : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL exp_out      : std_logic_vector (res_size - 1 DOWNTO 0);
	SIGNAL exp_overflow : std_logic := '0';
	SIGNAL res          : std_logic_vector (res_size - 1 DOWNTO 0);

BEGIN
	exp : exponentiator
	PORT MAP(clk => clk, A => A, B => B, overflow => exp_overflow, res => exp_out);

	PROCESS (opcode, A, B, exp_out, exp_overflow)
	BEGIN
		overflow <= '0'; --oveflow is zero for all ops currently except div by zero and exp
		CASE(opcode) IS
			WHEN "0000" => --additon
				res <= std_logic_vector(resize(signed(A),res_size) + resize(signed(B),res_size));
			WHEN "0001" => --subtraction
				res <= std_logic_vector(resize(signed(A),res_size) - resize(signed(B),res_size));
			WHEN "0010" => --bitwise AND
				res <= x"000" & (A AND B);
			WHEN "0011" => --bitwise OR
				res <= x"000" & (A OR B);
			WHEN "0100" => --bitwise XOR
				res <= x"000" & (A XOR B);
			WHEN "0101" => --Bit inversion
				res <= x"000" & (NOT A);
			WHEN "1000" => --multiplication
				res <= std_logic_vector(resize((signed(A) * signed(B)), res_size));
			WHEN "1001" => --division
				IF (signed(B) = 0) THEN
					res      <= (OTHERS => '0');
					overflow <= '1';
				ELSE
					res <= std_logic_vector(resize((signed(A)/signed(B)), res_size));
				END IF;
			WHEN "1010" => --exponentiation
				res      <= exp_out;
				overflow <= exp_overflow;
			WHEN OTHERS => --output undefined for other opcodes
				res <= (OTHERS => 'X');
		END CASE;
	END PROCESS;
	res_out <= res;
END Behav_struct;