-------------------------------------------------------------------------------
-- Title      : Register Delay                                               --
-- Project    : any                                                          --
-------------------------------------------------------------------------------
-- File       : REG_DELAY.vhd                                                --
-- Author     : Carlos Bertagnolli                                           --
-- Company    :                                                              --
-- Created    : 12:28:49 20/04/2020                                          --
-- Last updates:    $Date: 20 April 2020 12:28:00$                           --
--                      $Author: S10067$                                     --
--                      $Revision: 0$                                        --
-- Platform   :                                                              --
-- Standard   : VHDL'93/02                                                   --
-------------------------------------------------------------------------------
-- Description: Delays a signal by adding a number of Flip-flops stages in   --
--             desired signal.                                               --
--              DELAY_REG: Flip-flop stages between input and output (min 1) --
--              IN_SIZE:   Input vector size                                 --
--                                                                           --
--                                       ____       ____      delayed        --
--                             input  --|    |--...|    |-- output           --
--                                      | FF1|     | FFn|                    --
--                                      |_/\_|     |_/\_|                    --
--                                CLK_i __|_____...__|                       --
--                                                                           --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_DELAY is
    generic (
                -- Number of register stages (min value = 1)
                DELAY_REG   : natural;
                -- Signal size (in number of bits)
                IN_SIZE     : natural     
                ); 
    port    (
                -- Input signal
                DATA_i      : in    STD_LOGIC_VECTOR(IN_SIZE-1 downto 0);
                -- Internal running clock
                CLOCK_i     : in    STD_LOGIC;
                -- Delayed signal
                DATA_o      : out   STD_LOGIC_VECTOR(IN_SIZE-1 downto 0) := (others=>'0')
                );
end REG_DELAY;

architecture Behavioral of REG_DELAY is
type arr_int_t is array (DELAY_REG downto 0) of STD_LOGIC_VECTOR(IN_SIZE-1 downto 0);
signal int_s    : arr_int_t := (others=>(others=>'0'));
begin
    
    int_s(0)    <= DATA_i;
    DATA_o      <= int_s(DELAY_REG);

    REG_GEN : for k in 1 to DELAY_REG generate
        DELAY_p : process(CLOCK_i)
        begin    
            if rising_edge(CLOCK_i) then
                int_s(k) <= int_s(k-1);     
            end if;    
        end process DELAY_p;
    end generate REG_GEN;

end Behavioral;