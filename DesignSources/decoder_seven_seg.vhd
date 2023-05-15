LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Authors: Steve Weddell
-- Date: June 25, 2004
-- Purpose: VHDL Module for BCD to 7-segment Decoder
-- Usage: Laboratory 1; Example VHDL file for ENEL353
--Modified by Max Johnstone to have a case for representing the negative sign
-- for a bcd input of 10.
ENTITY decoder_seven_seg IS
	PORT (
		bcd_in   : IN std_logic_vector (3 DOWNTO 0); -- Input BCD vector
	leds_out : OUT std_logic_vector(6 DOWNTO 0)); -- Output 7-Seg vector
END decoder_seven_seg;

ARCHITECTURE Behavioral OF decoder_seven_seg IS
BEGIN
	my_seg_proc : PROCESS (bcd_in) -- Enter this process whenever BCD input changes state
	BEGIN
		CASE bcd_in IS -- abcdefg segments
			WHEN "0000" => leds_out  <= "0000001"; -- if BCD is "0000" write a zero to display
			WHEN "0001" => leds_out  <= "1001111"; -- etc...
			WHEN "0010" => leds_out  <= "0010010";
			WHEN "0011" => leds_out  <= "0000110";
			WHEN "0100" => leds_out  <= "1001100";
			WHEN "0101" => leds_out <= "0100100";
			WHEN "0110" => leds_out <= "1100000";
			WHEN "0111" => leds_out <= "0001111";
			WHEN "1000" => leds_out <= "0000000";
			WHEN "1001" => leds_out <= "0001100";
			WHEN "1010" => leds_out <= "1111110";--10 represents the negative sign
			WHEN OTHERS => leds_out     <= "1111111";
		END CASE;
	END PROCESS my_seg_proc;
END Behavioral;