----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Max Johnstone
-- 
-- Create Date: 09.04.2023 18:53:46
-- Design Name: 
-- Module Name: calc_fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: A moore State machine for the calculator
-- Output depends on the current state, state transitions are 
-- triggered by rising_edges on the sw input.
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY calc_fsm IS
	PORT (
		sw, clk, reset : IN std_logic;
		--what reg should be displayed
		reg_sel : OUT std_logic_vector (1 DOWNTO 0)
	);
END calc_fsm;

ARCHITECTURE Behavioral OF calc_fsm IS

	--s0: Waiting for binary number input A
	--s1: Waiting for opcode input
	--s2: Waiting for binary number input B
	--s3: Calculation done, display result.
	TYPE state_type IS (s0, s1, s2, s3);
	SIGNAL current_s, next_s : state_type := s0;
	SIGNAL sw_last, sw_event : std_logic := '0';
BEGIN
	--clock process
	PROCESS (clk, reset)
	BEGIN
		IF (reset = '1') THEN
			current_s <= s0; --enter waiting for input state
		ELSIF (rising_edge(clk)) THEN
			current_s <= next_s;
			sw_last   <= sw; --loads in the state of the button
		END IF;
	END PROCESS;

	sw_event <= sw AND NOT sw_last; --defines a sw_event as a rising edge on the sw signal
	--state machine process
	PROCESS (current_s, sw_event)
	--can reset to zero each time as we only need to assert start for one clock cycle
		BEGIN
			--goes through the states

			CASE current_s IS
				WHEN s0 => 
					reg_sel <= "00";
					IF (sw_event = '1') THEN
						--switch reg being displayed to OP_A
						next_s <= s1;
					ELSE
						next_s <= current_s;
					END IF;
 
				WHEN s1 => 
					reg_sel <= "01";
					IF (sw_event = '1') THEN
						--switch reg being displayed to opcode reg
						next_s <= s2;
					ELSE
						next_s <= current_s;
					END IF;
 
				WHEN s2 => 
					reg_sel <= "10";
					IF (sw_event = '1') THEN
						--switch reg being displayed to OP_B
						next_s <= s3;
					ELSE
						next_s <= current_s;
					END IF;
 
				WHEN s3 => 
					reg_sel <= "11";
					IF (sw_event = '1') THEN
						--switch reg being displayed to result_reg
						next_s <= s0;
					ELSE
						next_s <= current_s;
					END IF;
 
			END CASE;
		END PROCESS;

END Behavioral;