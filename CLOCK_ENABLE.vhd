-------------------------------------------------------------------------------
-- Title      : Clock Enable generator                                         
-- Project    : any                                                            
-------------------------------------------------------------------------------
-- File       : CLOCK_ENABLE.vhd                                               
-- Author     : Carlos Bertagnolli                                             
-- Company    :                                                                
-- Created    : 13:46:59 02/05/2013 
-- Last updates:    $Date: 21 May 2013 11:48:20$                               
--                      $Author: S10067$                                       
--                      $Revision: 0$                                          
-- Platform   :                                                                
-- Standard   : VHDL'93/02                                                     
-------------------------------------------------------------------------------
-- Description:     Divides SYSTEM_CLK frequency by desired integer (DIVIDE_g) 
--                  and generates a 1 clock cycle pulse ENABLE signal to be
--                  used as a clock enable in processes. This will improve
--                  timing and simplify timing analysis.
--                                                                             
--                  To synchronise clock enables across the design, set SLAVE_g
--                  to 'TRUE' and connect the "master enable" to SYNC_i.
--                  The very first MASTER_EN_s is used to synchronise slave
--                  enable signals.
--                                                     ___________ 
--              ___________                           | SLAVE_EN1 |
--             | MASTER_EN |                          |           |
--             |           |              SYSTEM_CLK--|CLK_i      | SLAVE_EN1_s
-- SYSTEM_CLK--|CLK_i      | MASTER_EN_s              |       EN_o|------------
--             |       EN_o|--------------------------|SYNC_i     |
--           --|SYNC_i     |          |               |___________|
--             |___________|          |
--                                    |                ___________ 
--                                    |               | SLAVE_EN2 |
--                                    |               |           |
--                                    |   SYSTEM_CLK--|CLK_i      | SLAVE_EN2_s
--                                    |               |       EN_o|------------
--                                     ---------------|SYNC_i     |
--                                                    |___________|
--
--
-- SYSTEM_CLK (e.g. 20MHz)
--  _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _   _
-- | |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_| |_
--
-- MASTER_EN_s (e.g. DIVIDE_g = 2, 10MHz period)
--          __      __      __      __      __      __      __      __      __ 
-- ________|  |____|  |____|  |____|  |____|  |____|  |____|  |____|  |____|  |
--
-- SLAVE_EN_s (e.g. DIVIDE_g = 4, 5MHz period)
--          __              __              __              __              __             
-- ________|  |____________|  |____________|  |____________|  |____________|  |
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

ENTITY CLOCK_ENABLE IS
  GENERIC(
    -- If SLAVE_g is set to TRUE, module will wait for SYNC_i signal to go high
    -- until its own EN_o is set 
    SLAVE_g     : BOOLEAN   := FALSE;
    -- Divides SYSTEM_CLK frequency by DIVIDE_g integer to achieve desired frequency
    DIVIDE_g    : INTEGER   := 2); 
  PORT(
    CLK_i       : IN  STD_LOGIC;        -- System clock input
    SYNC_i      : IN  STD_LOGIC;        -- Alligns EN_o to "Master Enable" (when SLAVE_g = TRUE)
    EN_o        : OUT STD_LOGIC := '0');-- Enable clock output at desired frequency (CLK_i / DIVIDE_g)
END CLOCK_ENABLE;

ARCHITECTURE BEHAVIOURAL OF CLOCK_ENABLE IS
    SIGNAL first_en_s   : BOOLEAN   := TRUE;
    SIGNAL enable_s     : STD_LOGIC := '0';
    SIGNAL divcnt_s     : INTEGER RANGE 0 to (DIVIDE_g-1) := 0;
BEGIN

    -- If SLAVE_g is set to TRUE, this module will require a SYNC_i "Master Enable" signal to 
    -- start generating enables on EN_o
    slave_out_gen : if SLAVE_g = TRUE generate
        
        -- For the first enable only, output will be SYNC_i
        EN_o    <= SYNC_i when first_en_s else enable_s;
        
        PROCESS(CLK_i)
        BEGIN
            IF rising_edge(CLK_i) THEN
                -- If SYNC_i signal is active and it's first enable ever
                IF (first_en_s = TRUE) and (SYNC_i = '1') then
                    -- Set first_en_s to FALSE as the next enable will not be first anymore 
                    first_en_s      <= FALSE;
                    -- Set divide counter (divcnt_s) to 1 instead of zero in first cycle, because 
                    -- it was waiting for sync to arrive and that takes up a clock cycle
                    divcnt_s        <= 1;
                ELSE
                    -- Increment divider counter until it reaches desired frequency
                    IF divcnt_s = (DIVIDE_g - 1) THEN
                        enable_s    <= '1';
                        divcnt_s    <= 0;
                    ELSE
                        enable_s    <= '0';
                        divcnt_s    <= divcnt_s + 1;
                    END IF;
                    
                END IF;
            END IF;
        END PROCESS;
            
    end generate slave_out_gen;
    
  
    -- If SLAVE_g is set to FALSE, the EN_o output will free run
    master_out_gen : if SLAVE_g = FALSE generate
        
        PROCESS(CLK_i)
        BEGIN
            IF rising_edge(CLK_i) THEN
                -- Increment divider counter until it reaches desired frequency
                IF divcnt_s = (DIVIDE_g - 1) THEN
                    EN_o        <= '1';
                    divcnt_s    <= 0;
                ELSE
                    EN_o        <= '0';
                    divcnt_s    <= divcnt_s + 1;
                END IF;
            END IF;
        END PROCESS;
            
    end generate master_out_gen;
  
END BEHAVIOURAL;
