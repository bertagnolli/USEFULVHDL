-------------------------------------------------------------------------------
-- Title      : Negative edge detector
-- Project    : any
-------------------------------------------------------------------------------
-- File       : NEGEDGE_DETECTOR.vhd
-- Author     : Carlos Bertagnolli
-- Company    : 
-- Created    : 13:46:59 02/05/2014 
-- Last updates:    $Date: 21 May 2015 11:48:20$
--                      $Author: S10067$
--                      $Revision: 2$
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:     Detects the negative edge of a signal and outputs a pulse
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity NEGEDGE_DETECTOR is
       Port (               
                CLK_i           : in  STD_LOGIC;
                SIGNAL_IN_i     : in  STD_LOGIC;
                OUTPUT_o        : out  STD_LOGIC);
end NEGEDGE_DETECTOR;

architecture Behavioral of NEGEDGE_DETECTOR is
    signal signal_d:STD_LOGIC;
begin

    process(CLK_i)
    begin
        if rising_edge(CLK_i) then
            signal_d <= SIGNAL_IN_i;
        end if;
    end process;

    OUTPUT_o <= (not SIGNAL_IN_i) and signal_d; 

end Behavioral;