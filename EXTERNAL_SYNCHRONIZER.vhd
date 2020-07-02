-------------------------------------------------------------------------------
-- Title      : Register Delay                                               --
-- Project    : any                                                          --
-------------------------------------------------------------------------------
-- File       : REG_DELAY.vhd                                                --
-- Author     : Carlos Bertagnolli                                           --
-- Company    :                                                              --
-- Created    : 12:28:49 20/04/2015                                         --
-- Last updates:    $Date: 20 April 2020 12:28:00$                           --
--                      $Author: S10067$                                     --
--                      $Revision: 0$                                        --
-- Platform   :                                                              --
-- Standard   : VHDL'93/02                                                   --
-------------------------------------------------------------------------------
-- Description: Synchronizes external signals to internal clock domain with  --
-- a dual stage Flip-flop synchronizer to avoid metastability.               --
--                                                                           --
--                          External     ____    ____      Synchronized      --
--                             input  --|    |--|    |-- input               --
--                                      | FF1|  | FF2|                       --
--                                      |_/\_|  |_/\_|                       --
--                                CLK_i __|_______|                          --
--                                                                           --
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity REG_DELAY is
    generic (
                DELAY   : natural;
                -- Signal number of bits
                N       : natural     
                ); 
    port    (
                -- Input synch signal
                SYNCH_i     : in    STD_LOGIC_VECTOR(N-1 downto 0);
                -- Internal running clock
                SYNCH_CLK_i : in    STD_LOGIC;
                -- Synchronized signal
                SYNCH_o     : out   STD_LOGIC_VECTOR(N-1 downto 0) := (others=>'0')
                );
end EXTERNAL_SYNCHRONIZER;

architecture Behavioral of EXTERNAL_SYNCHRONIZER is
signal int_s        :   STD_LOGIC_VECTOR(N-1 downto 0);

begin

    SYNCHRONIZE_p : process(SYNCH_CLK_i)
    begin
    
        if rising_edge(SYNCH_CLK_i) then
        
            int_s       <= SYNCH_i;
            SYNCH_o     <= int_s;
        
        end if;
    
    end process SYNCHRONIZE_p;

end Behavioral;