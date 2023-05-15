----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 07.04.2023 21:58:42
-- Design Name:
-- Module Name: clk_div_100MHZ_to_xhz - Behavioral
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A clock divider that divides down 100mhz
-- to a clock speed specified by a generic map
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
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY clk_div_100MHZ_to_xhz IS
	GENERIC (
		hz_out : INTEGER := 1
	);
	PORT (
		m_clk   : IN STD_LOGIC;
		clk_out : OUT STD_LOGIC
	);
END clk_div_100MHZ_to_xhz;

ARCHITECTURE Behavioral OF clk_div_100MHZ_to_xhz IS
	CONSTANT m_clk_freq : INTEGER := 100000000;
	CONSTANT clk_limit  : INTEGER := (m_clk_freq /(hz_out * 2)) - 1;
	SIGNAL tmp_clk      : std_logic;

BEGIN
	clock            : PROCESS (m_clk) 
		VARIABLE clk_ctr : INTEGER RANGE 0 TO clk_limit := 0;
	BEGIN
		IF rising_edge(m_clk) THEN
			IF clk_ctr = clk_limit THEN
				tmp_clk <= NOT tmp_clk; --toggle clock
				clk_ctr := 0; --reset count
			ELSE
				clk_ctr := clk_ctr + 1;
			END IF;
		END IF;
	END PROCESS clock;
	clk_out <= tmp_clk;

END Behavioral;