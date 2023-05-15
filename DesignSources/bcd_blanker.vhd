--! @brief Blanks out leading zeros 
--! @details Combinatorial logic to replace leading zeros with "1111". 
--! See [DigiKey article](https://forum.digikey.com/t/7-segment-display-driver-for-multiple-digits-vhdl/12526) for more details.

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY bcd_blanker IS
	GENERIC (
		BCD_SIZE : INTEGER := 28; --! Size of BCD input
		NUM_SEGS : INTEGER := 8; --! Number of seven-segment displays
		SEG_SIZE : INTEGER := 4 --! Vector size for each segment
	);
	PORT (
		bcd_input : IN std_logic_vector(BCD_SIZE - 1 DOWNTO 0); --! Input BCD number
		bcd_blank : OUT std_logic_vector(BCD_SIZE - 1 DOWNTO 0) --! Blanked BCD number
	);
END bcd_blanker;

ARCHITECTURE behavioural OF bcd_blanker IS
	-- OR all bits in input vector
	FUNCTION or_reduce (input : std_logic_vector) RETURN std_logic IS
	VARIABLE result           : std_logic;
BEGIN
	result := '0';
	FOR i IN input'RANGE LOOP
		result := result OR input(i);
	END LOOP; RETURN result;
END FUNCTION;

--! Blanking vector
CONSTANT OFF : std_logic_vector(SEG_SIZE - 1 DOWNTO 0) := "1111";
 
--! Enable segments
SIGNAL enable : std_logic_vector(NUM_SEGS DOWNTO 0);
BEGIN
	-- Always display first digit
	bcd_blank(SEG_SIZE - 1 DOWNTO 0) <= bcd_input(SEG_SIZE - 1 DOWNTO 0);

	-- Blank out leading zeros
	enable(NUM_SEGS) <= '0';
	blanker : FOR i IN NUM_SEGS - 1 DOWNTO 1 GENERATE
		-- Check if segment is zero or already enabled
		enable(i) <= enable(i + 1) OR or_reduce(bcd_input(i * SEG_SIZE + 3 DOWNTO i * SEG_SIZE));

		-- Turn off segment if not enabled
		WITH enable(i) SELECT bcd_blank(i * SEG_SIZE + 3 DOWNTO i * SEG_SIZE) <= 
			bcd_input(i * SEG_SIZE + 3 DOWNTO i * SEG_SIZE) WHEN '1', 
			OFF WHEN OTHERS;
	END GENERATE;
END behavioural;