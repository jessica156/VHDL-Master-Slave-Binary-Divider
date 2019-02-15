----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/12/2019 01:29:16 PM
-- Design Name: Binary Divider
-- Module Name: ms_bd_tb - tb_arch
-- Project Name: Binary Divider
-- Target Devices: 
-- Tool Versions: 
-- Description: Testbench for the binary divider with wires to connect the master and slave to each other
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ms_bd_tb is
    generic(
        W: integer := 8
    );
end ms_bd_tb;

architecture tb_arch of ms_bd_tb is
    signal clk, reset: std_logic;
    signal start, ready, done, correct: std_logic;
    signal dividend, divisor, dvsr, dvnd: std_logic_vector(W - 1 downto 0);
    signal quotient, remainder, quo, rmd: std_logic_vector(W - 1 downto 0);
begin

    clock: process
    begin
        clk <= '0';
        wait for 50ns;
        clk <= '1';
        wait for 50ns;
    end process clock;
    
    test_vector_gen: process
    begin
        reset <= '1';
        dividend <= "00001001";     -- 9
        divisor <= "00000011";      -- 3
        
        wait until falling_edge(clk);
        reset <= '0';
        
        wait on correct until correct = '1';
        
        dividend <= "00100110";     -- 38
        divisor <= "00000010";      -- 2
        
        wait on correct until correct = '1';
        
        dividend <= "11101011";     -- 235
        divisor <= "00010010";      -- 18
        
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until rising_edge(clk);
        wait until falling_edge(clk);
        reset <= '1';
        
        wait until falling_edge(clk);
        dividend <= "11101101";     -- 237
        divisor <= "01011010";      -- 90
        reset <= '0';
        
        wait on correct until correct = '1';
        
        dividend <= "01110111";     -- 119
        divisor <= "00011011";      -- 27
        
        wait on correct until correct = '1';
        
        wait on correct until correct = '0';
        
        wait until rising_edge(clk);
        
        assert false;
            report "Simulation Completed"
        severity failure;
    end process test_vector_gen;
    
    master: entity work.master_bd(arch)
        port map(
            clk => clk,
            reset => reset,
            ready => ready,
            done_tick => done,
            divisor => divisor,
            dividend => dividend,
            quo => quo,
            rmd => rmd,
            valid => start,
            correct => correct,
            dvsr => dvsr,
            dvnd => dvnd,
            quotient => quotient,
            remainder => remainder
        );

    slave: entity work.slave_bd(arch)
        port map(
            clk => clk,
            reset => reset,
            start => start,
            dvsr => dvsr,
            dvnd => dvnd,
            ready => ready,
            done_tick => done,
            quo => quo,
            rmd => rmd
        );
end tb_arch;
