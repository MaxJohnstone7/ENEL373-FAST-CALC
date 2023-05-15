--! @brief Binary to binary-coded decimal (BCD) converter  
--! @details Double dabble algorithm for converting binary to BCD.  
--! Implementation inspired by [this Wikipedia article](https://wikipedia.org/w/index.php?title=Double_dabble&oldid=997863872#VHDL_implementation).  
--! A combinatorial blanker is also used to remove leading zeros.


--Modified to take in signed inputs 
--It now outputs a logic vector sign_bcd which is the bcd_code
-- pertaining to the sign of the number

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bin_signed_to_bcd is
    generic (
        BCD_SIZE : integer := 28; --! Length of BCD signal
        NUM_SIZE : integer := 24; --! Length of binary input
        NUM_SEGS : integer := 7;  --! Number of segments
        SEG_SIZE : integer := 4   --! Vector size for each segment
    );
    port (
        reset : in std_logic;                                --! Asynchronous reset
        clock : in std_logic;                                --! System clock
        start : in std_logic;                                --! Assert to start conversion
        bin_signed   : in std_logic_vector(NUM_SIZE - 1 downto 0);  --! Binary input
        bcd   : out std_logic_vector(BCD_SIZE - 1 downto 0); --! Binary coded decimal output
        sign_bcd : out std_logic_vector(SEG_SIZE - 1 downto 0);
        ready : out std_logic                                --! Asserted once conversion is finished
    );
end bin_signed_to_bcd;

architecture behavioural of bin_signed_to_bcd is
    constant bits   : integer := NUM_SIZE; --! Number of input bits
    constant digits : integer := NUM_SEGS; --! Number decimal digits
    signal sign : std_logic := bin_signed(NUM_size -1);
    --sign converted version of bin, should be applied if sign is negative
    signal bin_conv : std_logic_vector(NUM_SIZE -1 downto 0) := std_logic_vector(unsigned(NOT(bin_signed)) +1);
    
    type state_t is (IDLE, CONVERT, DONE); --! Main state machine
    signal state : state_t := IDLE;        --! Current state
    
    --! BCD input buffer for blanker
    signal bcd_buf : std_logic_vector(BCD_SIZE - 1 downto 0);
begin
    -- Instantiate BCD blanker (removes leading zeros)
    blanker : entity work.bcd_blanker
        generic map (
            BCD_SIZE => BCD_SIZE,
            NUM_SEGS => NUM_SEGS,
            SEG_SIZE => SEG_SIZE)
        port map (
            bcd_input => bcd_buf,
            bcd_blank => bcd);
    
    
    process (clock, reset)
        variable bin_reg : std_logic_vector (bits - 1 downto 0);
        variable bcd_reg : unsigned (digits * SEG_SIZE - 1 downto 0);
        variable count   : integer;
    begin
        -- Asynchronous reset
        if reset = '1' then
            bin_reg := (others => '0');
            bcd_reg := (others => '0');
            count   := 0;
            
            bcd_buf <= (others => '1');
            ready   <= '0';
            state   <= IDLE;
        elsif rising_edge(clock) then
            -- Main state machine

            case state is
                -- Wait until start is asserted
                when IDLE =>
                    if start = '1' then
                        state   <= CONVERT;
                        ready   <= '0';

                        -- Initialise variables
                        --if statement is to deal with twos complement inputs
                        if sign = '1' then
                         bin_reg := bin_conv;
                        else
                         bin_reg := bin_signed;
                        end if;
                        bcd_reg := (others => '0');
                        count   := 0;
                    end if;
                
                -- Perform double dabble algorithm
                when CONVERT =>

                    if count < bits then
                        -- Loop through all BCD digits
                        for i in 0 to digits - 1 loop
                            -- Add 3 to a place values (digits) if they are greater than 4
                            if bcd_reg(i * 4 + 3 downto i * 4) > 4 then
                                bcd_reg(i * 4 + 3 downto i * 4) := bcd_reg(i * 4 + 3 downto i * 4) + 3;
                            end if;
                        end loop;

                        -- Shift registers right
                        bcd_reg := bcd_reg(digits * 4 - 2 downto 0) & bin_reg(bits - 1);
                        bin_reg := bin_reg(bits - 2 downto 0) & '0';

                        count := count + 1;
                    else
                        state <= DONE;
                    end if;
                
                -- Conversion complete
                when DONE =>
                    state <= IDLE;
                    ready <= '1';
                    
                    -- Assign BCD to buffer
                    bcd_buf <= std_logic_vector(bcd_reg);
            end case;
        end if;
    end process;
--"1010" reprents the negative sign to the 7 seg decoder while "1111" represents a blank screen
sign_bcd <= "1010" when sign = '1' else "1111";
end behavioural;
