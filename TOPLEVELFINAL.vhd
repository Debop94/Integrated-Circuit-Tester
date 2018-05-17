library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
-----------------------------------------------------------------------------------------------------------------------------------------------
---ENTER VALUES HERE
package Define_Values_pkg is 
--input frequency is 50MHZ
--To change output frequency go to=>--MEGAWIZARD PLUGIN=>EDIT EXISTING=>EDIT ALTPLL_ICT
--=>CLICK OUTPUT CLOCK=>CHANGE MULTIPLIER/DIVIION FACTOR so that (50MHZ*M)/D = output frequency=>finish
	 constant TPnum:integer:=5 ;---- number of test patterns
	 constant numresults: integer:= 1;------number of result pins
	 constant numtest: integer:=4 ;--------number of test pins
	  constant freq: integer:= 10;--F this number is (input freq/ desired freq)/ 2. this example (F=10) gives us a 2.5 MHZ clock.
 ----------------------------------------------
   type testpattern is array(0 to TPnum-1) of std_logic_vector(numtest-1 downto 0 );
    constant TP: testpattern:=(0=>"0000",1=>"0001",2=>"0011",3=>"0111",4=>"1111");--test applied to DUT
	 type results is array (0 to TPnum-1) of std_logic_vector(numresults-1 downto 0);
      constant ER: results:=(0=>"0",1=>"0",2=>"0",3=>"0",4=>"1");--expected results. 
---------------------------------------------------------------------------

 end package Define_Values_pkg;
-----------------------------------------------------------------------------------------------------------------------------------------------------
library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.Define_Values_pkg.all;

entity toplevelfinal is 

port ( KEY: in std_logic_Vector(2 downto 0);
       LEDR: out std_logic_vector(7 downto 0);
		 LEDG:out std_logic_vector(7 downto 0);
		 CLOCK_50: in std_logic;
		 HEX0,HEX1,HEX2,HEX3: OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		 GPIO_0: INOUT STD_LOGIC_VECTOR(35 DOWNTO 1);  --DATABUS TO THE DUT 
	    clock_out:out std_logic --clock to the DUT	GPIO_0(0) 
		 
);
end toplevelfinal; 

Architecture rtl of toplevelfinal is
-- signal PLL_clock:std_logic:='0';
 signal CLOCK: std_logic:='0';
 signal error:std_logic:='0';
 signal s_Start:std_logic:='0';
 signal s_FTP_out:std_logic:='0';
 signal s_ECOUNT: std_logic:='0';
signal s_EnableLed:std_logic:='0';
 signal s_error_values: std_logic_vector(13 downto 0);
 signal s_BCDOUT0: std_logic_vector(3 downto 0):=(others=>'1');
 signal s_BCDOUT1:std_logic_vector(3 downto 0):=(others=>'1');
 signal s_BCDOUT2:std_logic_vector(3 downto 0):=(others=>'1');
 signal s_BCDOUT3:std_logic_vector(3 downto 0):=(others=>'1');
 --signal s_clock_out:std_logic:='0';
begin
----------------------------------------------------------------
--ALTPLL_inst: entity work.altpll_ICT---can change to clock multiplier if necessary
--     port map (
--		inclk0=>clock_50,
--		c0=>	clock,	
--		locked =>open
--	   );
-----------------------------------------------------------------		

clock_div_inst:entity work.clk_divider--we want to divide our clock to 4 MHZ so we will use this 
              port map (clock_50=>clock_50,
                        clock=>clock
								); ---------will be connected to 100 MHZ clock from ALTPLL

clock_div_inst2:entity work.clk_divider--we want to divide our clock to 4 MHZ so we will use this 
              port map (clock_50=>clock_50,
                        clock=>clock_out  -----this is clock output to the DUT
								); ---------will be connected to 100 MHZ clock from ALTPLL
								
								
--------------------------------------------------------------------------------------------------------           
--		
LEDS_inst: entity work.LEDs
     port map (start=>s_start ,
	  LED_enable=>s_EnableLed,
	  error_LED=>error,
	  clock_LED=>CLOck_50,--CONNECTED TO MAIN CLOCK SO BLINKING DOES NOT CHANGE WITH CHANGE IN FREQ
	  o_LEDG=>LEDG(7 downto 0),
	  o_LEDR=>LEDR(7 downto 0)
	  );
--	  
STARTBUTTON_inst: entity work.button_push 
     port map(push_clock=> clock,
		button_in =>KEY(0),
		button_out=>s_start
	  ); 
--	  
ECOUNT_inst: entity work.button_push
  port map(push_clock=> clock,
		button_in =>KEY(1),
		button_out=>s_ECOUNT
	  ); 
	  
FTP_out_inst: entity work.button_push
       port map(push_clock=> clock,
		button_in =>KEY(2),
		button_out=>s_FTP_out
	  ); 
--	  
ICT_inst: entity work.ICTESTER_stmachine
    port map(Clock_ICT=>clock,
	      receive_results=>GPIO_0(35-numtest downto 35-numtest-numresults+1), --receives  results from the output of the DUT 
			Transmit_test=>GPIO_0(35 downto 35-numtest+1),--sends tests to the DUT
			start=>s_start,
		   enable_LED=>s_EnableLed,
			error_out=>error,
			FTP_out=>s_FTP_out,
			ECOUNT=>s_ECOUNT,
			error_values=>s_error_values
	   );
--		
--	
binary2BCD: entity work.BCD 
            port map(start=>s_start,
				         errornum_input=>s_error_values,
							Clock_BCD=>clock,
							FTP_out=>s_FTP_out,
							Ecount=>s_Ecount,
							BCD_output0=>s_BCDOUT0,
							BCD_output1=>s_BCDOUT1,
							BCD_output2=>s_BCDOUT2,
							BCD_output3=>s_BCDOUT3);
--							
HEXDISPLAY0: entity work.hex_display
            port map(input_BCD=>s_BCDOUT0,
				         display=>HEX0,
							start=>s_start,
							clock=>clock);
							
HEXDISPLAY1: entity work.hex_display
            port map(input_BCD=>s_BCDOUT1,
				         display=>HEX1,
							start=>s_start,
							clock=>clock);
							
HEXDISPLAY2: entity work.hex_display
            port map(input_BCD=>s_BCDOUT2,
				         display=>HEX2,
							start=>s_start,
							clock=>clock);
							
HEXDISPLAY3: entity work.hex_display
            port map(input_BCD=>s_BCDOUT3,
				         display=>HEX3,
							start=>s_start,
							clock=>clock);						
--							
--------------------------------------------
--DUT: entity work.andgate
--        port map(A=>GPIO_0(35),
--		         B=>GPIO_0(34),
--	            C=>GPIO_0(33),
--               d=>GPIO_0(32),
--					E=>GPIO_0(31),
--					clock=> clock);
					
					
---------------------------------------------
--dut: ENTITY WORK.MUX8_1
--     port(
--                s     =>GPIO_0(35 downto 33),
--                d     =>GPIO_0(32 downto 25),              					 
--                y    =>GPIO_0(24)
--        );
--
------------------------------------------------

--dut:Entity work.RisingEdge_DFlipFlop_AsyncResetHigh 
--   port map(
--      Clk => clock,  
--      async_reset=> GPIO_0(35), 
--		set=> GPIO_0(34),
--       D => GPIO_0(33),
--	    Q => GPIO_0(32),
--       Qbar=>GPIO_0(31)		 
--   );



-------------------------------------------------------		  
end rtl;
--		