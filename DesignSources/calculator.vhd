----------------------------------------------------------------------------------
-- Company:
-- Engineer: Max Johnstone
--
-- Create Date: 09.04.2023 18:44:05
-- Design Name:
-- Module Name: calculator - Structural
-- Project Name:
-- Target Devices:
-- Tool Versions:
-- Description: A TOP-LEVEL structural Calculator which takes 12bit signed binary
-- numbers as an input via switches and applies math ops based on given opcode
-- Dependencies:
--
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY calculator IS
	PORT (
		CLK100MHZ, BTNC            : IN STD_LOGIC;
		SW                         : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		CA, CB, CC, CD, CE, CF, CG : OUT std_logic;
		LED                        : OUT std_logic_vector(3 DOWNTO 0);
		AN                         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) := X"FE"
	);
END calculator;

ARCHITECTURE Structural OF calculator IS

--=============================================Component declarations===========================================
	COMPONENT SIMPLE_ALU_12_BIT IS
		PORT (
			--inputs
			A, B   : IN std_logic_vector (11 DOWNTO 0);
			opcode : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
			clk    : IN std_logic;
			--outputs
			res_out  : OUT std_logic_vector (23 DOWNTO 0);--all signed numbers 24 bits or less can be written to the display
			overflow : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT calc_fsm IS
		PORT (
			sw, clk, reset : IN std_logic;
			--what reg should be displayed
			reg_sel : OUT std_logic_vector (1 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT disp_shift_reg IS
		GENERIC (
			--one byte by default
			reg_size : POSITIVE := 8
		);
		PORT (
			clk, SI   : IN std_logic;
			reset_val : IN std_logic_vector(reg_size - 1 DOWNTO 0);--value which reset should ocurr
			start_val : IN std_logic_vector(reg_size - 1 DOWNTO 0);--value to start on
			SO        : OUT std_logic;
			Q         : OUT std_logic_vector(reg_size - 1 DOWNTO 0)
		);
	END COMPONENT;

	--generic clock div
	COMPONENT clk_div_100MHZ_to_xhz IS
		GENERIC (
			hz_out : INTEGER := 1
		);
		PORT (
			m_clk   : IN STD_LOGIC;
			clk_out : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT display_mux IS
		PORT (
			D1, D2, D3, D4, D5, D6, D7, D8 : IN std_logic_vector (3 DOWNTO 0);--7seg display values
			sel                            : IN std_logic_vector(2 DOWNTO 0);--index of display to select
			O                              : OUT std_logic_vector (3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT reg_mux IS
		PORT (
			A, B   : IN std_logic_vector (11 DOWNTO 0);
			OPCODE : IN std_logic_vector(3 DOWNTO 0);
			RES    : IN std_logic_vector (23 DOWNTO 0);
			sel    : IN std_logic_vector(1 DOWNTO 0);--index of REG to select
			O      : OUT std_logic_vector (23 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT debouncer_1khz IS
		PORT (
			sw, clk : IN STD_LOGIC;
		Q       : OUT STD_LOGIC := '0');
	END COMPONENT;
	COMPONENT generic_reg IS
		GENERIC (
			--one byte by default
			reg_size : POSITIVE := 8
		);
		PORT (
			clk, in_en, rst, out_en : IN std_logic;
			D                       : IN std_logic_vector(reg_size - 1 DOWNTO 0);
			r_out                   : OUT std_logic_vector(reg_size - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT generic_sync_counter IS
		GENERIC (size : INTEGER := 1); --number of bits the counter is
		PORT (
			clk, reset, count_up : IN std_logic;
			max_count            : IN std_logic_vector(size - 1 DOWNTO 0); --number to count up to
			count                : OUT std_logic_vector(size - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT decoder_seven_seg IS
		PORT (
			bcd_in   : IN std_logic_vector (3 DOWNTO 0); -- Input BCD vector
		leds_out : OUT std_logic_vector(6 DOWNTO 0)); -- Output 7-Seg vector
	END COMPONENT;

	COMPONENT bin_signed_to_bcd IS
		GENERIC (
			BCD_SIZE : INTEGER := 28; --! Length of BCD signal
			NUM_SIZE : INTEGER := 24; --! Length of binary input
			NUM_SEGS : INTEGER := 7; --! Number of segments
			SEG_SIZE : INTEGER := 4 --! Vector size for each segment
		);
		PORT (
			reset      : IN std_logic; --! Asynchronous reset
			clock      : IN std_logic; --! System clock
			start      : IN std_logic; --! Assert to start conversion
			bin_signed : IN std_logic_vector(NUM_SIZE - 1 DOWNTO 0); --! Binary input
			bcd        : OUT std_logic_vector(BCD_SIZE - 1 DOWNTO 0); --! Binary coded decimal output
			sign_bcd   : OUT std_logic_vector(SEG_SIZE - 1 DOWNTO 0);
			ready      : OUT std_logic --! Asserted once conversion is finished
		);
	END COMPONENT;

	COMPONENT twos_comp_converter IS
		GENERIC (input_size, output_size : INTEGER);
		PORT (
			neg       : IN std_logic;
			val       : IN std_logic_vector(input_size - 1 DOWNTO 0);
			val_2comp : OUT std_logic_vector(output_size - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT sev_seg_driver IS
		PORT (
			leds_in  : IN STD_LOGIC_VECTOR (6 DOWNTO 0);
			overflow : IN STD_LOGIC;
			cur_disp : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			reg_sel  : IN std_logic_vector(1 DOWNTO 0);
			A        : OUT STD_LOGIC;
			B        : OUT STD_LOGIC;
			C        : OUT STD_LOGIC;
			D        : OUT STD_LOGIC;
			E        : OUT STD_LOGIC;
			F        : OUT STD_LOGIC;
			G        : OUT STD_LOGIC
		);
	END COMPONENT;
--=================================Constants for generics================================
	CONSTANT operand_size : INTEGER := 12;

--====================================Signals============================================
	SIGNAL sys_reset : std_logic := '0';
	--outputs from debouncers
	SIGNAL db_switches   : std_logic_vector(15 DOWNTO 0);
	SIGNAL db_pushbutton : std_logic;
	--num input switches converted to twos complement
	SIGNAL switches_2s_comp : std_logic_vector(11 DOWNTO 0);

	--other clock signals
	SIGNAL clk_1mhz : std_logic;
	SIGNAL clk_1khz : std_logic;

	--Reg outputs
	SIGNAL A_out   : std_logic_vector(11 DOWNTO 0);
	SIGNAL B_out   : std_logic_vector(11 DOWNTO 0);
	SIGNAL opcode  : std_logic_vector(3 DOWNTO 0);
	SIGNAL res_out : std_logic_vector(23 DOWNTO 0);

	--REG MUX
	SIGNAL reg_mux_out : std_logic_vector(23 DOWNTO 0);

	--FSM
	SIGNAL reg_select : std_logic_vector(1 DOWNTO 0) := "00";

	--enbles for input registers determined by reg_select
	SIGNAL OP_A_EN    : std_logic := (NOT reg_select(0) AND NOT reg_select(1));
	SIGNAL OPCODE_EN  : std_logic := (reg_select(0) AND NOT reg_select(1));
	SIGNAL OP_B_EN    : std_logic := (NOT reg_select(0) AND reg_select(1));
	SIGNAL RES_ENABLE : std_logic := (reg_select(0) AND reg_select(1)); --currently ALU is purely combo so no need for this
	--ALU
	SIGNAL alu_out  : std_logic_vector(23 DOWNTO 0);
	SIGNAL overflow : std_logic;

	--SIGNED TO BCD CONVERTER
	SIGNAL bcd_digits : std_logic_vector(27 DOWNTO 0);
	SIGNAL sign_bcd   : std_logic_vector(3 DOWNTO 0);
	SIGNAL conv_done  : std_logic;

	--seven seg decoder
	SIGNAL leds_out : std_logic_vector(6 DOWNTO 0);

	--Counter_to_7 for display
	SIGNAL disp_select : std_logic_vector(2 DOWNTO 0);

	--Display mux
	SIGNAL selected_disp : std_logic_vector(3 DOWNTO 0);
	--Display shift reg signals
	SIGNAL dr_reset_val : std_logic_vector(7 DOWNTO 0) := "01111111";
	SIGNAL dr_start_val : std_logic_vector(7 DOWNTO 0) := "11111110";

	COMPONENT LED_DRIVER_4STATE IS
		--confusing expression ensure state_vec is the right length for the state_count given
		--cant do it the otehr way round as LED_vec may not be the same size as the total
		--number of states representable in the state vec
		PORT (
			state_vec : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			LED_VEC   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
		);
	END COMPONENT;

--==========================================Port maps=========================================
BEGIN
--===========================Twos comp converter for number input data========================
    twos_comp_conv : twos_comp_converter
        GENERIC MAP(input_size => 11, output_size => 12)
    PORT MAP(neg => db_switches(11), val => db_switches(10 DOWNTO 0), val_2comp => switches_2s_comp);
--====================================Register declerations===================================
    A_REG : generic_reg
    generic map ( reg_size=> 12)
    port map(clk => CLK_1MHZ, in_en=> OP_A_EN,rst=>'0',out_en=>'1',
            D=>switches_2s_comp,r_out => A_out );

    B_REG : generic_reg
    generic map ( reg_size=> 12)
    port map(clk => CLK_1MHZ, in_en=> OP_B_EN,rst=>'0',out_en=>'1',
            D=>switches_2s_comp,r_out => B_out );
            
    OP_REG : generic_reg
    generic map ( reg_size=> 4)
    port map(clk => CLK_1MHZ, in_en=> OPCODE_EN,rst=>'0',out_en=>'1',
            D=>db_switches(15 downto 12),r_out => opcode );
            
    RESULT_REG : generic_reg
    generic map ( reg_size=> 24)
    port map(clk => CLK100MHZ, in_en=> RES_ENABLE,rst=>'0',out_en=>'1',
            D=>alu_out,r_out => res_out );
            
    DISP_REG : disp_shift_reg
    generic map(reg_size => 8)
    port map(clk=>clk_1khz, si=>'1',Q=>AN,reset_val=>dr_reset_val,
            start_val => dr_start_val);
--==============================Clock dividers======================================================
    CLK_100MHZ_to_1KHZ : clk_div_100MHZ_to_xhz
    generic map (hz_out => 1000)
    Port map( m_clk=>CLK100MHZ, clk_out=>clk_1khz);

    CLK_100MHZ_to_1MHZ : clk_div_100MHZ_to_xhz
    generic map (hz_out => 1000000)
    Port map( m_clk=>CLK100MHZ, clk_out=>clk_1mhz); 
--======================================ALU=========================================================
    ALU : SIMPLE_ALU_12_BIT
    port map(A=>A_out,clk=>CLK100MHZ,B=>B_out,opcode=>opcode,overflow=>overflow,res_out=>alu_out);
--======================================DEMUXS======================================================
    REGISTER_MUX : reg_mux
    port map(A=>A_out,B=>B_Out,OPCODE=>OPCODE,RES=>res_out,
    sel=>reg_select, O=>reg_mux_out);

    DISP_MUX : display_mux
    port map(D8=> sign_bcd, D7=>bcd_digits(27 downto 24),D6=>bcd_digits(23 downto 20),
    D5=>bcd_digits(19 downto 16),D4=>bcd_digits(15 downto 12),D3=>bcd_digits(11 downto 8),
    D2=>bcd_digits(7 downto 4),D1=>bcd_digits(3 downto 0), sel=>disp_select,O=>selected_disp);

    --=====================================Counter to 7 for displays====================================
    COUNTER_TO_7 : generic_sync_counter
    generic map(size =>3)
    port map(clk=>clk_1khz, reset => '0',count_up=>'1',max_count=>"111",count=>disp_select);
    --===================================BCD_TO_7_SEG===============================
    BCD_DECODER : decoder_seven_seg
    port map(bcd_in =>selected_disp,leds_out=>leds_out);
    --=====================================SIGNED_TO_BCD=======================================
    signed_to_bcd_conv : bin_signed_to_bcd
    port map(reset=>'0',clock=>CLK100MHZ,start=>'1'
    ,bin_signed=>reg_mux_out,bcd=>bcd_digits,sign_bcd=>sign_bcd,ready=>conv_done);
    --==================================FSM=============================================================== 
    fsm : calc_fsm
    port map(clk=>CLK_1khz,sw=>db_pushbutton,reset=>sys_reset,reg_sel=>reg_select);
    --================================Debouncers===============================
    push_db : debouncer_1khz
    port map(sw=>BTNC,clk=>clk_1khz,Q=>db_pushbutton);

    --debouncers for toggle switches
    sw_db_gen : for i in 0 to 15 generate
    sw_db : debouncer_1khz
    port map(sw=>SW(i),clk=>clk_1khz,Q=>db_switches(i));
    end generate;
    --===========================================LED DRIVERS for on-board LEDS===========================
    drive : led_driver_4state
    port map(state_vec=>reg_select,LED_VEC=>LED(3 downto 0));

    seg_driver : sev_seg_driver
    port map(leds_in=>leds_out,overflow=>overflow,cur_disp=>disp_select,
    reg_sel=>reg_select,A=>CA,B=>CB,C=>CC,D=>CD,E=>CE,F=>CF,G=>CG);
end Structural;