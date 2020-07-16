-------------------------------------------------------------------------------
-- Title      : AXI4 Lite Testbench                                          --
-- Project    : any                                                          --
-------------------------------------------------------------------------------
-- File       : AXI4_LITE_TESTBENCH.vhd                                      --
-- Author     : Carlos Bertagnolli                                           --
-- Company    :                                                              --
-- Created    : 14:28:49 28/09/2019                                          --
-- Last updates: 	$Date: 16 July 2020 13:38:39$                            --
--						$Author: S10067$                                     --
--						$Revision: 2$                                        --
-- Platform   :                                                              --
-- Standard   : VHDL'93/02                                                   --
-------------------------------------------------------------------------------
-- Description: Controls an AXI4 Lite slave IP, simply connect the signals to-- 
--              a slave AXI4 Lite block and use the following:               --
--              - WR_DATA_i - Active high, starts the process of writing the --
--                     data to the interface. Clear signal after 1 ns.       --
--                            Example (add to testbench):                    --
--                                                                           --
--  TB_AXI_AWADDR <= std_logic_vector(TO_UNSIGNED(0,C_S_AXI_ADDR_WIDTH));    --
--  TB_AXI_WDATA  <= std_logic_vector(TO_UNSIGNED(0,C_S_AXI_DATA_WIDTH));    --
--  WR_AXI_DATA_i <= '1'; --Start AXI Write to Slave                         --
--  wait for 1 ns;                                                           --
--  WR_AXI_DATA_i <= '0'; --Clear request                                    --
--  wait until axi_bvalid = '1'; -- Output                                   --
--  wait until axi_bvalid = '0';  --AXI Write finished                       --
--                                                                           --
--          - RD_DATA_i - Active high, starts the process of reading the     --
--                 data from the interface. Clear signal after 1 ns.         --
--                        Example (add to testbench):                        --
--                                                                           --
--  TB_AXI_ARADDR <= std_logic_vector(TO_UNSIGNED(0,C_S_AXI_ADDR_WIDTH));    --
--  WR_AXI_DATA_i <= '1'; --Start AXI Read to Slave                          --
--  wait for 1 ns;                                                           --
--  WR_AXI_DATA_i <= '0'; --Clear request                                    --
--  wait until axi_rvalid = '1';                                             --
--  wait until axi_rvalid = '0';                                             --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity AXI4_LITE_TESTBENCH is
generic
(
    C_S_AXI_DATA_WIDTH             : integer              := 32;
    C_S_AXI_ADDR_WIDTH             : integer              := 7);
port (
    ---------------------------------------------------
    -- Testbench control signals
    -- Requests to write data to AXI4 Lite interface
    WRREQ_AXI_DATA_i    : IN STD_LOGIC; 
    -- Requests to read data from AXI4 Lite interface
    RDREQ_AXI_DATA_i    : IN STD_LOGIC; 
    -- Data to be written into AXI4 Lite interface
    TB_AXI_WDATA        : IN STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Address to write data into AXI4 Lite interface
    TB_AXI_AWADDR       : IN STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    -- Data read from AXI4 Lite interface
    TB_AXI_RDATA        : OUT STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    -- Address to read data from AXI4 Lite interface
    TB_AXI_ARADDR       : IN STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    
    ---------------------------------------------------
    -- AXI4 interface
    S_AXI_ACLK          : IN  STD_LOGIC;
    S_AXI_ARESETN       : OUT STD_LOGIC;
    
    S_AXI_WDATA         : OUT STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_AWADDR        : OUT STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    S_AXI_RDATA         : IN  STD_LOGIC_VECTOR(C_S_AXI_DATA_WIDTH-1 downto 0);
    S_AXI_ARADDR        : OUT STD_LOGIC_VECTOR(C_S_AXI_ADDR_WIDTH-1 downto 0);
    
    S_AXI_AWVALID       : OUT STD_LOGIC;
    S_AXI_WVALID        : OUT STD_LOGIC;
    S_AXI_BREADY        : OUT STD_LOGIC;
    S_AXI_WSTRB         : OUT STD_LOGIC_VECTOR((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
    S_AXI_AWREADY       : IN STD_LOGIC; 
    S_AXI_WREADY        : IN STD_LOGIC;
    S_AXI_BVALID        : IN STD_LOGIC;
    S_AXI_BRESP         : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
    S_AXI_ARVALID       : OUT STD_LOGIC;
    S_AXI_RREADY        : OUT STD_LOGIC;
    S_AXI_RVALID        : IN STD_LOGIC;
    S_AXI_ARREADY       : IN STD_LOGIC;
    S_AXI_RRESP         : IN STD_LOGIC_VECTOR(1 DOWNTO 0)
);

end AXI4_LITE_TESTBENCH;

architecture Behavioral of AXI4_LITE_TESTBENCH is

begin
    
    S_AXI_WDATA  <= TB_AXI_WDATA;
    S_AXI_AWADDR <= TB_AXI_AWADDR;
    S_AXI_ARADDR <= TB_AXI_ARADDR;

 -- Initiate process which simulates a master wanting to write.
 -- When WRREQ_AXI_DATA_i goes to 1, the process exits the wait state and
 -- execute a write operation.
 axisend_p : PROCESS
 BEGIN
    S_AXI_AWVALID<='0';
    S_AXI_WVALID<='0';
    S_AXI_BREADY<='0';
    loop
        wait until WRREQ_AXI_DATA_i = '1';
        S_AXI_WSTRB <= (others=>'1');
        wait until S_AXI_ACLK= '0';
            S_AXI_AWVALID<='1';
            S_AXI_WVALID<='1';
        wait until (S_AXI_AWREADY and S_AXI_WREADY) = '1';  --Client ready to read address/data        
            S_AXI_BREADY<='1';
        wait until S_AXI_BVALID = '1';  -- Write result valid
            assert S_AXI_BRESP = "00" report "AXI data not written" severity failure;
            S_AXI_AWVALID<='0';
            S_AXI_WVALID<='0';
            S_AXI_BREADY<='1';
        wait until S_AXI_BVALID = '0';  -- All finished
            S_AXI_BREADY<='0';
            S_AXI_WSTRB <= (others=>'0');
    end loop;
 END PROCESS axisend_p;

  -- Initiate process which simulates a master wanting to read.
  -- This process is blocked on a "Read Flag" (readIt).
  -- When the flag goes to 1, the process exits the wait state and
  -- execute a read transaction.
  axiread_p : PROCESS
  BEGIN
    S_AXI_ARVALID<='0';
    S_AXI_RREADY<='0';
     loop
         wait until RDREQ_AXI_DATA_i = '1';
         wait until S_AXI_ACLK= '0';
            S_AXI_ARVALID<='1';
            S_AXI_RREADY<='1';
         wait until (S_AXI_RVALID and S_AXI_ARREADY) = '1';  --Client provided data
            assert S_AXI_RRESP = "00" report "AXI data read" severity failure;
            S_AXI_ARVALID<='0';
            S_AXI_RREADY<='0';
            
     end loop;
  END PROCESS axiread_p;
  
  TB_AXI_RDATA <= S_AXI_RDATA;

axireset_p : PROCESS
 BEGIN
        S_AXI_ARESETN<='0';
    wait for 15 ns;
        S_AXI_ARESETN<='1';
        
     wait;
 END PROCESS axireset_p;

end Behavioral;