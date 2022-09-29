------------------------------------------------------------------------------------------------------
-- Title      : Any                                                                                 --
-- Project    : Any                                                                                 --
------------------------------------------------------------------------------------------------------
-- File       : MULTIPLIER.vhd                                                                         --
-- Author     : Carlos Bertagnolli                                                                  --
-- Company    :                                                                                     --
-- Created    : 14.09.2022 18:13:20                                                                 --
-- Platform   :                                                                                     --
-- Standard   : VHDL'93/02                                                                          --
------------------------------------------------------------------------------------------------------
-- Description: A simple A x B multiplier with selectable MSB and LSB output bits and pipeline      --
--              register stages for timing improvement                                              --
--                                                                                                  --
-- Revisions  :                                                                                     --
-- Date        Version  Author      Description                                                     --
-- 2022-09-14  1        S10067      Created                                                         --
------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MULTIPLIER is
    GENERIC(
            -- A operand input bitsize (default - 8 bits)
            A_SIZE          : NATURAL := 8;
            -- B operand input bitsize (default - 8 bits)
            B_SIZE          : NATURAL := 8;
            -- Multiplier output bit selection (default MSB:LSB is 15:0)
            MULT_OUTPUT_MSB : NATURAL := 15;
            MULT_OUTPUT_LSB : NATURAL := 0;
            -- CLEAR_i overrides Clock Enable (CLK_EN_i) if CLK_PRIORITY is set to TRUE (default is TRUE)
            CLR_PRIORITY    : BOOLEAN := TRUE;
            -- CLEAR_i signal will clear all registers synchronously if SYNC_CLR is set to TRUE (Default is TRUE)
            SYNC_CLR        : BOOLEAN := TRUE;
            -- Pipeline stages to improve timing. If set to 0, the multiplier output will be combinatorial and 
            -- expects input operands to be registered outside the module (default is 1 pipeline stage)
            PIPELINE_STAGES : NATURAL := 1;
            -- Register inputs if set to TRUE (default is FALSE)
            REGISTER_INPUT  : BOOLEAN := FALSE;
            -- Register outputs if set to TRUE (default is FALSE)
            REGISTER_OUTPUT : BOOLEAN := FALSE
            );
    PORT   ( 
            -- A and B operands used in multiplication
            A_OPERAND_i     : IN STD_LOGIC_VECTOR(A_SIZE-1 downto 0);
            B_OPERAND_i     : IN STD_LOGIC_VECTOR(B_SIZE-1 downto 0);
            
            -- Clear multiplier registers (Can be configured as async - Default is synchronous)
            CLEAR_i         : IN STD_LOGIC;            
            -- Clock Enable (Enabled if set to '1')
            CLK_EN_i        : IN STD_LOGIC; 
            
            -- Clock input
            CLK_i           : IN STD_LOGIC;            
            
            -- End of scan - Active for 1 clock cycle
            MULT_OUT        : OUT STD_LOGIC_VECTOR(MULT_OUTPUT_MSB downto MULT_OUTPUT_LSB) := (others => '0')
            );
end MULTIPLIER;

architecture Behavioral of MULTIPLIER is
-- Create array for registered pipeline
constant PIPELINE_BITSIZE_c     : natural := (A_SIZE+B_SIZE);
type PIPELINE_t is array (0 to PIPELINE_STAGES) of STD_LOGIC_VECTOR((PIPELINE_BITSIZE_c)-1 downto 0);
signal sync_pipeline_s          : PIPELINE_t := (others=>(others=>'0'));
-- Unregistered combinatorial multiplier
signal multiplier_s             : STD_LOGIC_VECTOR((PIPELINE_BITSIZE_c)-1 downto 0) := (others =>'0');
-- Last register in the pipeline
signal last_pipeline_register_s : STD_LOGIC_VECTOR(MULT_OUTPUT_MSB downto MULT_OUTPUT_LSB) := (others => '0');
-- Registered multiplier output register
signal reg_sync_pipeline_s      : STD_LOGIC_VECTOR(MULT_OUTPUT_MSB downto MULT_OUTPUT_LSB) := (others => '0');
-- Synchronised clear signal 
signal sync_clear_s             : STD_LOGIC := '0';
-- Input operand registers in case REGISTER_INPUT = TRUE
signal sync_a_operand_i         : STD_LOGIC_VECTOR(A_OPERAND_i'RANGE);
signal sync_b_operand_i         : STD_LOGIC_VECTOR(B_OPERAND_i'RANGE);

begin

    process(CLK_i)
    begin
    
        -- In case SYNC_CLR is set to FALSE, then registers are cleared asynchronously (not recommended)
        if (SYNC_CLR = FALSE and CLEAR_i = '1') then
            -- If CLR_PRIORITY is set to TRUE, CLK_EN_i is overridden
            if (CLR_PRIORITY = TRUE) then
                for i in 0 to PIPELINE_STAGES loop
                    for ii in 0 to PIPELINE_BITSIZE_c-1 loop
                        sync_pipeline_s(i)(ii) <= '0';
                    end loop;       
                end loop; 
            else    -- If CLR_PRIORITY is set to FALSE, pipeline registers will only get cleared if CLK_EN_i is active
                    -- Async clear is NOT recommended, this will also cost more resources
                if (CLK_EN_i = '1') then
                    for i in 0 to PIPELINE_STAGES loop
                        for ii in 0 to PIPELINE_BITSIZE_c-1 loop
                            sync_pipeline_s(i)(ii) <= '0';
                        end loop;       
                    end loop; 
                end if;
            end if;
            
        elsif rising_edge(CLK_i) then
            
            -- Registered operand inputs 
            sync_a_operand_i <= A_OPERAND_i;
            sync_b_operand_i <= B_OPERAND_i;
            
            -- Registered output - Last pipeline register is registered again
            reg_sync_pipeline_s <= last_pipeline_register_s;

            if (CLK_EN_i = '1') then
            
                -- Update pipeline registers
                sync_pipeline_s(0)  <= multiplier_s;
                for i in 1 to PIPELINE_STAGES loop
                    sync_pipeline_s(i) <= sync_pipeline_s(i-1);    
                end loop;
                
                -- Clear all pipeline registers synchronously if SYNC_CLR is set to TRUE
                for i in 0 to PIPELINE_STAGES loop
                    if (SYNC_CLR = TRUE and CLEAR_i = '1') then 
                        for ii in 0 to PIPELINE_BITSIZE_c-1 loop
                            sync_pipeline_s(i)(ii) <= '0';
                        end loop;                    
                    end if;       
                end loop;            
            end if;
            
            -- Clear all pipeline registers if SYNC_CLR is set to TRUE and CLR_PRIORITY has 
            -- priority over Clock enable signal
            for i in 0 to PIPELINE_STAGES loop
                if (SYNC_CLR = TRUE and CLEAR_i = '1' and CLR_PRIORITY = TRUE) then 
                    for ii in 0 to PIPELINE_BITSIZE_c-1 loop
                        sync_pipeline_s(i)(ii) <= '0';
                    end loop;                    
                end if;       
            end loop;
            
        end if;
    
    end process;

    -- Module input operands are registered if REGISTER_INPUT is set to TRUE
    REGISTERED_INPUTS_g : if REGISTER_INPUT = TRUE generate
        multiplier_s    <= STD_LOGIC_VECTOR(UNSIGNED(sync_a_operand_i) * UNSIGNED(sync_b_operand_i));
    end generate REGISTERED_INPUTS_g;

    -- Module input operands are not registered if REGISTER_INPUT is set to FALSE
    UNREGISTERED_INPUTS_g : if REGISTER_INPUT = FALSE generate
        multiplier_s    <= STD_LOGIC_VECTOR(UNSIGNED(A_OPERAND_i) * UNSIGNED(B_OPERAND_i));
    end generate UNREGISTERED_INPUTS_g;
    
    -- PIPELINE_STAGES = 0 means the multiplier is combinatorial. It expects input data to be already registered
    COMB_MULT_g : if PIPELINE_STAGES = 0 generate
        -- There is no pipeline and output is the combinatorial multiplier logic output itself
        last_pipeline_register_s    <= multiplier_s(MULT_OUTPUT_MSB downto MULT_OUTPUT_LSB);
    end generate COMB_MULT_g;
    
    -- PIPELINE_STAGES > 0 means the multiplier is pipelined
    SEQ_MULT_g : if PIPELINE_STAGES > 0 generate
        -- Last register in pipeline is the n-1 register
        last_pipeline_register_s    <= sync_pipeline_s((PIPELINE_STAGES)-1)(MULT_OUTPUT_MSB downto MULT_OUTPUT_LSB);
    end generate SEQ_MULT_g;
    
    -- Module output is registered if REGISTER_INPUT is set to TRUE
    REGISTERED_OUTPUT_g : if REGISTER_OUTPUT = TRUE generate
        MULT_OUT        <= reg_sync_pipeline_s;
    end generate REGISTERED_OUTPUT_g;

    -- Module output is not registered if REGISTER_INPUT is set to FALSE
    UNREGISTERED_OUTPUT_g : if REGISTER_OUTPUT = FALSE generate
        MULT_OUT        <= last_pipeline_register_s;
    end generate UNREGISTERED_OUTPUT_g;

end Behavioral;