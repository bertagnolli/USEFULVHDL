-------------------------------------------------------------------------------
-- Title      : Positive edge detector
-- Project    : any
-------------------------------------------------------------------------------
-- File       : POSEDGE_DETECTOR.vhd
-- Author     : Carlos Bertagnolli
-- Company    : 
-- Created    : 13:46:59 02/05/2014 
-- Last updates:    $Date: 21 May 2015 11:48:20$
--                      $Author: S10067$
--                      $Revision: 2$
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description:     Detects the positive edge of a signal and outputs a pulse
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity POSEDGE_DETECTOR is
        Port (
                CLK_i           : in  STD_LOGIC;
                SIGNAL_IN_i     : in  STD_LOGIC;
                OUTPUT_o        : out  STD_LOGIC);
end POSEDGE_DETECTOR;

architecture Behavioral of POSEDGE_DETECTOR is
    signal signal_d :STD_LOGIC;
begin

    process(CLK_i)
    begin
        if rising_edge(CLK_i) then
            signal_d <= signal_in_i;
        end if;
    end process;
        
    output_o <= (not signal_d) and signal_in_i; 
        
end Behavioral;