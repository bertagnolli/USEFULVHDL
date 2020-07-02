-------------------------------------------------------------------------------
-- Author     : Carlos Bertagnolli
-- Company    : Buhler UK Ltd
-- Platform   : 
-- Standard   : VHDL'93/02
--
--        #################################################
--     ####################################################
--   #######        ____  _   _ _   _ _     _____ ____  
--  ######         | __ )| ||| | | | | |   | ____|  _ \ 
--   #######       |  _ \| | | | |_| | |   |  _| | |_) |
--     #######     | |_) | |_| |  _  | |___| |___|  _ < 
--        ######   |____/ \___/|_| |_|_____|_____|_| \_\
--                               
-- Buhler UK Limited
-- 20 Atlantis Avenue
-- London, E16 2BF
-- Tel: +44 (0)20 7055 7777
-- Fax: +44 (0)20 7055 7701 
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TESTBENCH_CLOCK is
    generic (
        -- Clock period (type time)
        CLOCK_PERIOD            : TIME:= 1 ns;
        -- Clock duty cycle HIGH value (type time)
        DUTY_CYCLE_HIGH         : TIME := 500 ps        
        ); 
    port    (
        -- Enable output
        ENABLE_IN               : IN   STD_LOGIC;
        -- Clock output to be used in simulation
        CLOCK_OUT               : OUT  STD_LOGIC := '0'
        );
end TESTBENCH_CLOCK;

architecture Behavioral of TESTBENCH_CLOCK is
begin

   -- Clock process definitions
   CLOCK_process :process
   begin
        CLOCK_OUT <= '0';
        wait for (CLOCK_PERIOD-DUTY_CYCLE_HIGH);
        CLOCK_OUT <= '1';
        wait for DUTY_CYCLE_HIGH;
   end process;
   
end Behavioral;