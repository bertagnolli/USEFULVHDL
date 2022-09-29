------------------------------------------------------------------------------------------------------
-- Title      : Any                                                                                 --
-- Project    : Any                                                                                 --
------------------------------------------------------------------------------------------------------
-- File       : TIMEOUT.vhd                                                                         --
-- Author     : Carlos Bertagnolli                                                                  --
-- Company    :                                                                                     --
-- Created    : 08.02.2021 18:13:20                                                                 --
-- Platform   :                                                                                     --
-- Standard   : VHDL'93/02                                                                          --
------------------------------------------------------------------------------------------------------
-- Description: This module will generate an active high timeout signal output whenever the internal--
-- counter reaches the comparator value uninterrupted (comparator value = TIMEOUT_PERIOD_g)         --
-- A RESET_i signal will restart the count and reset TIMEOUT output to zero (active high)           --
--  An example of how to calculate TIMEOUT_PERIOD_g:                                                --
--      clock speed 1MHz (1us), Timeout period required 1 second.                                   --
--         TIMEOUT_PERIOD_g = 1/1us = 1_000_000                                                     --
--                                                                                                  --
-- Revisions  :                                                                                     --
-- Date        Version  Author      Description                                                     --
-- 2021-02-08  1        S10067      Created                                                         --
------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TIMEOUT is
    GENERIC(
            -- Boolean type generic selects RESET logic level (FALSE = Active high)
            ACTIVE_LOW_g        : BOOLEAN := FALSE;
            -- Timeout period = n * Clock cycle (example 1 second timeout, n = 1 / clk_ns)
            TIMEOUT_PERIOD_g    : NATURAL := 1_000_000
            );
    PORT   ( 
            -- Reset signal or monitored signal, an active high signal will reset TIMEOUT_o and counter
            RESET_i             : IN STD_LOGIC;
            -- Clock
            CLK_i               : IN STD_LOGIC;
            
            -- End of scan - Active for 1 clock cycle
            TIMEOUT_o           : OUT STD_LOGIC := '0'
            );
end TIMEOUT;

architecture Behavioral of TIMEOUT is
-- Counter register is of the size of TIMEOUT period
signal counter_s    : INTEGER RANGE 0 to TIMEOUT_PERIOD_g-1 := 0;
-- Reset signal sets coutner back to zero and TIMEOUT_o signal back to zero
signal reset_s      : STD_LOGIC := '0';
begin

    TIMEOUT_p : process(CLK_i)
    begin
    
        if rising_edge(CLK_i) then
            -- Non synthesizable code, selects logic level of reset signal
            if (ACTIVE_LOW_g = FALSE) then
                reset_s <= RESET_i;
            else
                reset_s <= not RESET_i;
            end if; 
            
            -- Comparator - Set TIMOUT to 1 if counter has reached timeout count
            if (counter_s = TIMEOUT_PERIOD_g-1) then
                TIMEOUT_o <= '1';
            else 
                -- Increment counter
                counter_s   <= counter_s + 1;
            end if;
            
            -- Reset signal will set counter back to zero and set timeout output register back to zero
            if (reset_s = '1') then
                TIMEOUT_o <= '0';
                counter_s <= 0;
            end if;
            
        end if;
    
    end process TIMEOUT_p;

end Behavioral;
