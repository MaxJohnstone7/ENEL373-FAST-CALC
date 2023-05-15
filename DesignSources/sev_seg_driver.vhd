----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 15.04.2023 00:18:31
-- Design Name:
-- Module Name: sev_seg_driver - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description:
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY sev_seg_driver IS
	PORT (
		leds_in  : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
		overflow : IN STD_LOGIC;
		reg_sel  : IN std_logic_vector(1 DOWNTO 0);
		cur_disp : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
		A        : OUT STD_LOGIC;
		B        : OUT STD_LOGIC;
		C        : OUT STD_LOGIC;
		D        : OUT STD_LOGIC;
		E        : OUT STD_LOGIC;
		F        : OUT STD_LOGIC;
		G        : OUT STD_LOGIC
	);
END sev_seg_driver;

ARCHITECTURE Behavioral OF sev_seg_driver IS
	SIGNAL leds_real : STD_LOGIC_VECTOR (6 DOWNTO 0);--The led values to actually be displayed
BEGIN
	PROCESS (overflow, leds_in, cur_disp, reg_sel)
	BEGIN
	    --only want INF to be displayed when overflow is true and we are displaying the result
		IF overflow = '1' AND reg_sel = "11" THEN
			CASE cur_disp IS
				WHEN "000" => 
					leds_real <= "0111000"; --F for inf
				WHEN "001" => 
					leds_real <= "0001001"; --n for inf
				WHEN "010" => 
					leds_real <= "1001111"; --i for inf
				WHEN OTHERS => 
					leds_real <= "1111111";
			END CASE;
		ELSE
			leds_real <= leds_in;
		END IF;
	END PROCESS;
	A <= leds_real(6);
	B <= leds_real(5);
	C <= leds_real(4);
	D <= leds_real(3);
	E <= leds_real(2);
	F <= leds_real(1);
	G <= leds_real(0); 
END Behavioral;