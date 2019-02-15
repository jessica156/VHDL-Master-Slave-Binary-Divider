----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Jessica Nguyen
-- 
-- Create Date: 02/12/2019 01:09:45 PM
-- Design Name: Binary Division
-- Module Name: master_bd - arch
-- Project Name: Binary Division
-- Target Devices: 
-- Tool Versions: 
-- Description: This master module acts as a test generation component that generates two numbers and send it to the slave for
-- division. Once the slave is done dividing, the results return to the master. The master check the correctness of the results
-- and output them while producing new pair of numbers for the slave to divide.
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity master_bd is
    generic(
        W: integer := 8
    );
    port(
        clk: in std_logic;
        reset: in std_logic;
        ready: in std_logic;        -- Ready signal from slave
        done_tick: in std_logic;    -- Done signal from slave
        divisor, dividend: in std_logic_vector(W - 1 downto 0);     -- Divisor and dividend input from testbench
        quo, rmd: in std_logic_vector(W - 1 downto 0);          -- Quotient and remainder from slave
        valid: out std_logic;       -- Start signal for slave to begin division
        correct: out std_logic;     -- Correct signal to signify that the slave's division is correct
        dvsr, dvnd: out std_logic_vector(W - 1 downto 0);       -- Divisor and dividend output to slave
        quotient, remainder: out std_logic_vector(W - 1 downto 0) -- Final quotient and remainder outputs from master after check 
    );
end master_bd;

architecture arch of master_bd is
    type state_type is (first, idle, done);
    signal state: state_type;
    signal quo_clear, rmd_clear: std_logic_vector(W - 1 downto 0) := (others => '0');
begin
    process(clk)
    begin
        -- Resetting the master
        if reset = '1' then
            valid <= '0';
            correct <= '0';
            quotient <= quo_clear;
            remainder <= rmd_clear;
            state <= first;
        elsif rising_edge(clk) then
            case state is
                when first =>
                    correct <= '0';
                    quotient <= quo_clear;
                    remainder <= rmd_clear;
                    -- Send the divisor and dividend values to the slave if it is ready and tell it to start division
                    if  ready = '1' then
                        dvsr <= divisor;
                        dvnd <= dividend;
                        valid <= '1';
                        state <= idle;
                    end if;
                when idle =>
                    valid <= '0';
                    -- Waiting for the slave to be done with division
                    if done_tick = '1' then
                        state <= done;
                    end if;
                when done =>
                    -- Check to make sure the slave calculated the correct results
                    if (quo = std_logic_vector(unsigned(dividend) / unsigned(divisor))) 
                    and (rmd = std_logic_vector(unsigned(dividend) rem unsigned(divisor))) then
                        correct <= '1';
                        quotient <= quo;
                        remainder <= rmd;
                        state <= first;
                    end if;
            end case;
        end if;        
    end process;
end arch;
