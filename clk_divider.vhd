library ieee;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.Define_Values_pkg.all;

--Maximum output freq is 50MHZ--- I"ve put this at maximum so the user doesn't have to change pin assingments
--To change this go to tools--MEGAWIZARD PLUGIN--EDIT EXISTING--EDIT ALT_ICT--CLICK OUTPUT CLOCK --CHANGE MULTIPLIER FACTOR so that 50MHZ*M = maximum frequency----finish----
------------------
entity clk_divider is
        
  port (clock_50:in std_logic;
--        clk_div_in: in  std_logic;
        clock: out std_logic); ---------will be connected to 100 MHZ clock from ALTPLL
end clk_divider;
		
architecture rtl of clk_divider is 

 -- signal clk_div_in:std_logic;
  signal clk_div_out: std_logic:='0';
  --signal clk_div_Count: integer;-- range 0 to freq :=0;

Begin 


clkDIV: process(clock_50)--,clk_div_reset)

variable clk_div_count: integer := 0;
     begin  
	   if rising_edge(clock_50) then
		   if clk_div_count < freq then 			
            clk_div_count := clk_div_count + 1;
			else 
				clk_div_out <= not(clk_div_out);
			   clk_div_count := 0; 
			end if;
		end if;
	end process;
		
	clock <= clk_div_out;
	
end rtl;
		    

