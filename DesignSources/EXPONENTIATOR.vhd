----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 02.05.2023 09:35:15
-- Design Name:
-- Module Name: EXPONENTIATOR - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A exponentiation module to be utilised by the ALU,
-- It does not handle negative exponenets and instead assumes the values
-- to be positive
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
ENTITY EXPONENTIATOR IS
	PORT (
		clk      : IN STD_LOGIC;
		A        : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		B        : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
		res      : OUT STD_LOGIC_VECTOR (23 DOWNTO 0);
		overflow : OUT STD_LOGIC
	);
END EXPONENTIATOR;

ARCHITECTURE Behavioral OF EXPONENTIATOR IS
	CONSTANT res_size : INTEGER := 24;
	--if res is bigger than this it should be considered overflowed
	CONSTANT max_res_int : INTEGER := 8388607;
	CONSTANT min_res_int : INTEGER := - 8388608;

BEGIN
	exponentiation         : PROCESS (clk, A, B) IS
		VARIABLE temp_res      : INTEGER;
		VARIABLE a_int         : INTEGER;
		VARIABLE b_int         : INTEGER;
		VARIABLE mult_count    : INTEGER := 1;
		VARIABLE done          : std_logic := '0';
		VARIABLE temp_overflow : std_logic;
	BEGIN
		a_int := to_integer(signed(A));
		b_int := to_integer(signed(B));
		IF (rising_edge(clk)) THEN
			--ignores negative exponents just assumes they are positive');
			IF (b_int < 0) THEN
				b_int := - b_int;
			END IF;
			temp_overflow := '0';--overflow zero in most cases overwritten in case where it ocurrs
			--check special cases of exponentiation
			IF b_int = 0 OR a_int = 1 THEN 
				temp_res := 1;
				done     := '1';
			ELSIF a_int = 0 THEN
				temp_res := 0;
				done     := '1';
			ELSIF a_int = -1 THEN
			    done     := '1';
			    IF (b_int MOD 2 = 1) THEN
			        temp_res := -1;
			    ELSE
			        temp_res:= 1;
			    END IF;
			--for smallest growing input of 2 any power > res_length results in oveflow
			ELSIF (b_int > res_size - 1)  THEN
				done          := '1';
				temp_overflow := '1';
				temp_res      := 0;
			ELSE
				--we are at the start of the multiplication
				IF mult_count = 1 THEN
					temp_res := a_int;
				END IF;
				--section that performs repeated multiplication
				--check for overflow
				IF (temp_res > max_res_int OR temp_res < min_res_int) THEN
					temp_overflow := '1';
					temp_res      := 0;
					done          := '1';
					--check if we are done
				ELSIF mult_count = b_int THEN
					done := '1';
					--perform multiplication
				ELSE
					temp_res   := temp_res * a_int;
					mult_count := mult_count + 1;--increment the mult count
					done       := '0';
				END IF;
			END IF;
 
			IF (done = '1') THEN
				mult_count := 1; --reset the mult count
				--when we are done assert the output
				res      <= std_logic_vector(to_signed(temp_res, res_size));
				overflow <= temp_overflow;
			END IF;
		END IF;
	END PROCESS;

END Behavioral;