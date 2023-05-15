----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Michael Rivers + Max Johnstone
-- 
-- Create Date: 04.05.2023 18:19:53
-- Design Name: Test Bench
-- Module Name: alu_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: A test bench for the ALU module
-- needs to be run for a time period of 2000ns rather than 1000ns
-- due to larger delays between exp operation testing
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



--tb norm
entity alu_tb is
--  Port ( );
end alu_tb;



architecture Behavioral of alu_tb is
   component SIMPLE_ALU_12_BIT is
       Port ( 
            --inputs
            A,B: in std_logic_vector (11 downto 0);
            opcode: in STD_LOGIC_VECTOR (3 downto 0);
            clk: in std_logic;
            --outputs
            res_out : out std_logic_vector (23 downto 0);--all signed numbers 24 bits or less can be written to the display
            overflow: out STD_LOGIC
            );
    end component;

    
--this part should wire back to the initial  
signal A,B:  std_logic_vector (11 downto 0); 
signal opcode:  STD_LOGIC_VECTOR (3 downto 0);
signal test_clk:  std_logic:= '0';
signal res_out :  std_logic_vector (23 downto 0);--all signed numbers 24 bits or less can be written to the display  
signal overflow: STD_LOGIC;
    
constant mult:  std_logic_vector(3 downto 0) := "1000" ;
constant add:  std_logic_vector(3 downto 0):="0000" ;
constant subtract:  std_logic_vector(3 downto 0):="0001" ;
constant divide:  std_logic_vector(3 downto 0):="1001" ;
constant exp:  std_logic_vector(3 downto 0):= "1010" ;
constant operand_size : integer := 12;
constant res_out_size : integer := 24;

begin

test_clk <= not test_clk after 1 ns; --simulated_clock
uut : SIMPLE_ALU_12_BIT 
port map(A=>A,B=>B,opcode=>opcode,clk=>test_clk,res_out=>res_out,overflow=>overflow);

stimulus: process is
variable des_res_out : std_logic_vector(res_out_size-1 downto 0);
begin
    wait for 100ns;
    
    --Addition operation tests
    opcode <= add;
    
    --Regular operation testing
    -- 4 + 4 test
    A <= X"004";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(8,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 + 4 failed" severity error;
    
    -- 4 + -4 test
    A <= X"004";
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 + (-4) failed" severity ERROR;
    
    -- -4 + -4 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(-8,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) + (-4) failed" severity ERROR;
    
    --Large value testing
    -- 2047+2047 test
    A <= std_logic_vector(to_signed(2047,operand_size));
    B <= std_logic_vector(to_signed(2047,operand_size));
    des_res_out := std_logic_vector(to_signed(4094,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (2047) + (2047) failed" severity ERROR;
    
    -- (-2047) + (-2047) test
    A <= std_logic_vector(to_signed(-2047,operand_size));
    B <= std_logic_vector(to_signed(-2047,operand_size));
    des_res_out := std_logic_vector(to_signed(-4094,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-2047) + (-2047) failed" severity ERROR;
    
    --Subtraction operation tests
    opcode <= subtract;
    
    --Regular operation testing
    -- 4 - 4 test
    A <= X"004";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 - 4 failed" severity error;
    
    -- (-4) - 4 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(-8,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) - 4 failed" severity error;
    
    -- 4 - (-4) test
    A <= X"004";
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(8,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 - (-4) failed" severity error;
    
    -- (-4) - (-4) test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) - (-4) failed" severity error;
    
    
    --Large value testing
    -- 2047 - (-2047) test
    A <= std_logic_vector(to_signed(2047,operand_size));
    B <= std_logic_vector(to_signed(-2047,operand_size));
    des_res_out := std_logic_vector(to_signed(4094,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (2047) - (-2047) failed" severity ERROR;
    
    -- (-2047) - 2047 test
    A <= std_logic_vector(to_signed(-2047,operand_size));
    B <= std_logic_vector(to_signed(2047,operand_size));
    des_res_out := std_logic_vector(to_signed(-4094,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-2047) - (2047) failed" severity ERROR;
    
    --Multiplication operation tests
    opcode <= mult;
    
    --Regular operation testing
    -- 4 x 4 test
    A <= X"004";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(16,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 x 4 failed" severity error;
    
    -- (-4) x 4 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(-16,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) x 4 failed" severity error;
    
    -- 4 x (-4) test
    A <= X"004";
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(-16,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 x (-4) failed" severity error;
    
    -- (-4) x (-4) test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(16,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) x (-4) failed" severity error;
    
    -- 4 x 0 test
    A <= X"004";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (4) x (0) failed" severity error;
    
    -- (-4) x 0 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) x (0) failed" severity error;
    
    -- 0 x 0 test
    A <= X"000";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (0) x (0) failed" severity error;
    
    
    --Division operation tests
    opcode <= divide;
    
    --Regular operation testing
    -- 4 / 2 test
    A <= X"004";
    B <= X"002";
    des_res_out := std_logic_vector(to_signed(2,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 / 2 failed" severity error;
    
    -- (-4) / 2 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"002";
    des_res_out := std_logic_vector(to_signed(-2,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) / 2 failed" severity error;
    
    -- 4 / (-2) test
    A <= X"004";
    B <= std_logic_vector(to_signed(-2,operand_size));
    des_res_out := std_logic_vector(to_signed(-2,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 / (-2) failed" severity error;
    
    -- (-4) / (-2) test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-2,operand_size));
    des_res_out := std_logic_vector(to_signed(2,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation(-4) / (-2) failed" severity error;
    
    
    --Improper fraction testing
    -- 4 / 3 test
    A <= X"004";
    B <= X"003";
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 / 3 failed" severity error;
    
    -- (-4) / 3 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"003";
    des_res_out := std_logic_vector(to_signed(-1,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) / 3 failed" severity error;
    
    -- 4 / (-3) test
    A <= X"004";
    B <= std_logic_vector(to_signed(-3,operand_size));
    des_res_out := std_logic_vector(to_signed(-1,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 / (-3) failed" severity error;
    
    -- (-4) / (-3) test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-3,operand_size));
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation(-4) / (-3) failed" severity error;
    
    
    --Division by zero testing    
    -- 4 / 0 test
    A <= X"004";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation 4 / 0 failed" severity error;
    
    -- (-4) / 0 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation (-4) / 0 failed" severity error;
    
    -- 0 / 0 test
    A <= X"000";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation 0 / 0 failed" severity error;
    
    
    --Zero Division Testing
    -- 0 / 4 test
    A <= X"000";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 0 / 4 failed" severity error;
    
    -- 0 / (-4) test
    A <= X"000";
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 10ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 0 / (-4) failed" severity error;
    
    
    
    
    --Exponentiation operation tests
    opcode <= exp;
    
    --Regular operation testing
    -- 4 ^ 4 test
    A <= X"004";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(256,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 ^ 4 failed" severity error;
    
    -- 4 ^ (-4) test (negative exponents are treated as positive)
    A <= X"004";
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(256,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 ^ (-4) failed" severity error;
    
    -- (-4) ^ (-4) test (negative exponents are treated as positive)
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= std_logic_vector(to_signed(-4,operand_size));
    des_res_out := std_logic_vector(to_signed(256,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) ^ (-4) failed" severity error;
    
    -- (-4) ^ 4 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(256,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) ^ 4 failed" severity error;
    
    -- (-4) ^ 3 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"003";
    des_res_out := std_logic_vector(to_signed(-64,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) ^ 3 failed" severity error;
    
    
    --Overflow testing (Acceptable values: -8388608 => 8388607)
    -- 2 ^ 22 test
    A <= X"002";
    B <= X"016";
    des_res_out := std_logic_vector(to_signed(4194304,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 2 ^ 22 failed" severity error;
    
    -- 2 ^ 23 test
    A <= X"002";
    B <= X"017";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation 2 ^ 23 failed" severity error;
    
    -- (-2) ^ 23 test
    A <= std_logic_vector(to_signed(-2,operand_size));
    B <= X"017";
    des_res_out := std_logic_vector(to_signed(-8388608,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-2) ^ 23 failed" severity error;
    
    -- 2 ^ 25 test
    A <= X"002";
    B <= X"019";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation 2 ^ 25 failed" severity error;
    
    -- (-2) ^ 25 test
    A <= std_logic_vector(to_signed(-2,operand_size));
    B <= X"019";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '1')) report
    "Operation (-2) ^ 25 failed" severity error;
    
    -- 1 ^ 25 test
    A <= X"001";
    B <= X"019";
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 1 ^ 25 failed" severity error;
    
    -- (-1) ^ 25 test
    A <= std_logic_vector(to_signed(-1,operand_size));
    B <= X"019";
    des_res_out := std_logic_vector(to_signed(-1,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-1) ^ 25 failed" severity error;
    
    --Edge case testing
    -- 4 ^ 0 test
    A <= X"004";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 4 ^ 0 failed" severity error;
    
    -- (-4) ^ 0 test
    A <= std_logic_vector(to_signed(-4,operand_size));
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation (-4) ^ 0 failed" severity error;
    
    -- 0 ^ 0 test
    A <= X"000";
    B <= X"000";
    des_res_out := std_logic_vector(to_signed(1,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 0 ^ 0 failed" severity error;
    
    -- 0 ^ 4 test
    A <= X"000";
    B <= X"004";
    des_res_out := std_logic_vector(to_signed(0,res_out_size));
    wait for 100ns;
    assert ((res_out = des_res_out) and (overflow = '0')) report
    "Operation 0 ^ 4 failed" severity error;
    
    wait;
end process stimulus;

end Behavioral;
