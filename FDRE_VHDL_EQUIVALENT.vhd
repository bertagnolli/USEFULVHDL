-------------------------------------------------------------------------------
--
-- Title        :  FDRE VHDL Equivalent
-- Author       :  Carlos Bertagnolli
-- Company      :  Buhler Sortex Ltd
--
-------------------------------------------------------------------------------
--
-- File         :  FDRE_VHDL_EQUIVALENT.vhd
--
-------------------------------------------------------------------------------
--
-- Description  :  VHDL behavioral model of a Xilinx FDRE primitive
--  
-- FDRE:    Single Data Rate D Flip-Flop with Synchronous Reset and
--          Clock Enable (posedge clk).  
--          Based on: Spartan-6 VHDL Clocking Primitives
--
-- History : 
-- Version 00 - CEB - Created
-------------------------------------------------------------------------------
library IEEE ;
use IEEE.STD_LOGIC_1164.all ;
use ieee.numeric_std.ALL;

entity FDRE_VHDL_EQUIVALENT is
 
    generic (
        INIT        : STD_LOGIC := '0'          -- Initial value of register ('0' or '1')  
    );
    port (
        Q           : OUT STD_LOGIC := INIT;    -- Data output
        C           : IN  STD_LOGIC;            -- Clock input
        CE          : IN  STD_LOGIC;            -- Clock enable input
        R           : IN  STD_LOGIC;            -- Synchronous reset input
        D           : IN  STD_LOGIC             -- Data input
    );  
end FDRE_VHDL_EQUIVALENT;

architecture FDRE_VHDL_EQUIVALENT of FDRE_VHDL_EQUIVALENT is  
begin
-- Modified FDRE to a VHDL equivalent process
process (C)
begin	
  if rising_edge(C) then
     -- FDRE Equivalent
     if (R = '1') then
        Q <= '0';
     else
        if (CE = '1') then
            Q <= D;
        end if;
     end if;
  end if;
end process;

end FDRE_VHDL_EQUIVALENT ;  