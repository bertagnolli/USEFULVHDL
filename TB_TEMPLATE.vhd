--------------------------------------------------------------------------------
-- TESTBENCH TEMPLATE FILE
-- FILL IN WITH YOUR OWN DESIGN AND STIMULI
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY TB_TEMPLATE IS
END TB_TEMPLATE;
 
ARCHITECTURE behavior OF TB_TEMPLATE IS 
 
    -- Component Declaration for the Unit Under Test (UUT)

    COMPONENT DUT
    GENERIC(
        GENERIC_g      : TYPE;
    );
    PORT   ( 
        INPUT  : TYPE;
        OUTPUT : TYPE
    );
    END COMPONENT;


    --Inputs
    signal CLOCK : STD_LOGIC := '0';
    signal INPUT : STD_LOGIC := '0';

    --Outputs
    signal OUTPUT : STD_LOGIC;

    constant CLOCK_period : time := 1 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: DUT 
        GENERIC MAP (
            GENERIC_g => 1
        )
        PORT MAP (
            CLOCK => CLOCK,
            INPUT => INPUT,
            OUTPUT => OUTPUT
        );

   -- Clock process definitions
   CLOCK_process :process
   begin
        CLOCK <= '0';
        wait for CLOCK_period/2;
        CLOCK <= '1';
        wait for CLOCK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin        
      -- hold reset state for 100 ns.
      wait for 100 ns;  

      wait for CLOCK_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;