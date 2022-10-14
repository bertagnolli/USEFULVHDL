-------------------------------------------------------------------------------
--
-- Title        :  Clock Domain Crossing Module
-- Author       :  Carlos Bertagnolli
--
-------------------------------------------------------------------------------
--
-- File         :  CLK_DOMAIN_CROSSER.vhd
--
-------------------------------------------------------------------------------
-- Description: This module will infer a clock domain crossing logic depending
--              on the speeds at which the input signals are clocked at, in an
--              attempt to mitigate metastability when crossing clock domains.
--
--              Generic attributes description:
--
--              - CLKA_freq_g is the clock in the domain at which the original  
--              signal is at. 
--              ROUND THE CLOCK FREQUENCY UP (e.g. 30.5MHZ becomes 31)
--
--              - CLKB_freq_g is the clock in the domain at which you want the 
--              signal to be passed to (clock domain crossed to other side).
--              ROUND THE CLOCK FREQUENCY UP (e.g. 30.5MHZ becomes 31)
--          
--              - N is the number of bits of the input signal
--
-------------------------------------------------------------------------------
--              OUTPUT LOGIC 1:
--              Slower clock domain to faster clock domain
--              (CLKA_freq_g < CLKB_freq_g) will simply infer "n"  number of 
--              Flip-flops between the two clock domains, where "n" is at least
--              two and will increase by 1 every 100MHz above 200MHz as an
--              industry accepted rule of thumb to avoid metastability. 
--              Inferred logic as below:            
--                                                                           
--      input(CLKA) ____    input(CLKB) ____    ____    Clock crossed signal              
--               --|    |--------------|    |--|    |-- out to CLKB domain                     
--                 | FF0|              | FF1|  |FF2 |                              
--                 |_/\_|              |_/\_|  |_/\_|                              
--            CLKA __|            CLKB __|_______|                                 
--
-------------------------------------------------------------------------------                            
--              OUTPUT LOGIC 2 - Faster clock domain to slower clock domain:
--              (CLKA_freq_g > CLKB_freq_g) 
--              In this case this module will infer logic that will stretch the 
--              original signal by "n" number of CLKA cycles, where: 
--
--                          n = ((CLKA_freq_g/CLKB_freq_g)*2) + 1
--          
--              again an industry accepted rule of thumb to avoid metastable 
--              signals when crossing from a fast to slow clock domain
--  
--                                             __
--                                            \  \
--                           __________________\  \
--                          |                   |  \____ Clock crossed 
--                          |                 __/  /     stretched out  
--                          |                | /__/      signal output 
--                          |                |           to CLKB domain
--        input(CLKA) ____  |          ____  |  
--       ------------|    |_|_ ... ___|    |_|   
--                   | FF1|           |FFn |                 
--                   |_/\_|           |_/\_|                 
--             CLK_A __|______ ... ______|        
--
--                      
-- History : 
-- Version 00 - CEB - Created
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity CLK_DOMAIN_CROSSER is
    generic (
                -- CLKA_freq_g is the clock in the domain at which the original  
                -- signal is at. 
                -- ROUND THE CLOCK FREQUENCY UP (e.g. 30.5MHZ becomes 31) 
                CLKA_freq_g : natural;
                -- CLKB_freq_g is the clock in the domain at which you want the 
                -- signal to be passed to (clock domain crossed to other side).
                -- ROUND THE CLOCK FREQUENCY UP (e.g. 30.5MHZ becomes 31)
                CLKB_freq_g : natural;
                -- N is the number of bits of the input signal (min 1)
                N           : natural := 1 
                ); 
    port    (
                -- Input signal (in CLKA clock domain)
                INPUT_i     : in    STD_LOGIC_VECTOR(N-1 downto 0);
                -- CLKA input signal clock domain
                CLKA_i      : in    STD_LOGIC;
                -- CLKB output signal clock domain
                CLKB_i      : in    STD_LOGIC;
                -- Cross clock output signal
                OUT_o       : out   STD_LOGIC_VECTOR(N-1 downto 0) := (others=>'0')
                );
end CLK_DOMAIN_CROSSER;

architecture Behavioral of CLK_DOMAIN_CROSSER is
-- 20 Flip-flop stages will allow for a max clock speed of 2GHz
signal ff_stages_s      :   INTEGER RANGE 0 to 19 := 2; 
-- Clock crossing actual flip-flops
type t_input is array (0 to 19) of STD_LOGIC_VECTOR(N-1 downto 0);
signal clock_crossing_s : t_input := (others=>(others=>'0'));
signal unary_OR_s       : t_input := (others=>(others=>'0'));

begin

-- Crossing from slow to fast clock domain (CLKA_freq_g < CLKB_freq_g)
g_SLOW2FAST : if (CLKA_freq_g < CLKB_freq_g) generate
    -- Calculate number of required flip-flop stages. Minimum of 2, and 1 additional
    -- flip-flop stage every 100MHz for signals with frequencies above 200MHz
    ff_stages_s <= (3 + ((CLKB_freq_g - 200) / 100)) when (CLKB_freq_g > 200) else 2;
    
    SLOW2FAST_p : process(CLKB_i, INPUT_i)
    begin
        -- First stage in the pipeline receives input (combinatorially) 
        clock_crossing_s(ff_stages_s) <= INPUT_i;
        
        if rising_edge(CLKB_i) then
            -- "n" flipflops clock crossing flip-flops
            for i in 0 to (ff_stages_s-1) loop 
                clock_crossing_s(i) <= clock_crossing_s(i+1);
            end loop;        
        end if;
    
    end process SLOW2FAST_p;
    
    -- Output is last flip-flop in the chain
    OUT_o <= clock_crossing_s(0); 
    
end generate g_SLOW2FAST;

-- Crossing from fast to slow clock domain (CLKA_freq_g > CLKB_freq_g)
g_FAST2SLOW : if (CLKA_freq_g > CLKB_freq_g) generate
    -- Calculate number of required clock cycles to stretch signal. Multiples of 2x 
    -- the input/output clock frequency ratio (plus 1)
    ff_stages_s <= (((CLKA_freq_g/CLKB_freq_g)*2)+1) when ((CLKA_freq_g/CLKB_freq_g) > 1) else 2;
    
    FAST2SLOW_p : process(CLKA_i, unary_OR_s, clock_crossing_s, INPUT_i)
    begin
        -- Last stage in the pipeline receives input (combinatorially) 
        clock_crossing_s(ff_stages_s) <= INPUT_i;
        
        -- OR'ing all inputs together
        unary_OR_s(0) <= clock_crossing_s(0);
        for i in 1 to ff_stages_s loop
            unary_OR_s(i) <= unary_OR_s(i-1) or clock_crossing_s(i);
        end loop; 
        
        -- Output is all stages OR'ed together (stretched signal)
        OUT_o <= unary_OR_s(ff_stages_s);
    
        -- Stretch input signal by "n" number of CLKA cycles
        if rising_edge(CLKA_i) then
            -- "n" clock cycles input stretching
            for i in 0 to (ff_stages_s-1) loop 
                clock_crossing_s(i) <= clock_crossing_s(i+1);
            end loop;        
        end if;
    
    end process FAST2SLOW_p;
    
end generate g_FAST2SLOW;

end Behavioral;