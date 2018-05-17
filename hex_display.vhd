library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity hex_display is 

port ( input_BCD: in std_logic_vector(3 downto 0); --the 4 bit number from binary2BCD
       display: out std_logic_vector (6 downto 0);--output to the display once converted
		 start: in std_logic;--this is useless
		 clock:in std_logic
		 );
		  
end hex_display;

Architecture rtl of hex_display is

 begin
   COnversion: process (clock)
    begin
  if rising_edge(clock) then 
	   
		     
			CASE input_BCD is --LED is activated when held low therefore '0' means segment is on.
					when "0000" => 
						 display <= "1000000"; --0; 
						 
					when "0001"=>
						display <= "1111001"; --1;
					
					when "0010"=>
						 display <= "0100100"; --2;
						
					when "0011"=>
						 display <= "0110000"; --3;
					when "0100"=>
						  display <= "0011001"; --4;
						 
					when "0101"=>
						  display <= "0010010"; --5;
						 
					when "0110"=>
						  display <= "0000010"; --6;
						 
					when "0111"=>
						  display <= "1111000"; --7;
						 
					when "1000"=>
						  display <= "0000000"; --8;
						 
					when "1001"=>
						  display <= "0010000"; --9;
					when "1111"=>
							display <= "1111111"; --show nothing	
					when others =>
						  display<=  "1111111";--show nothing
						  
				  end case;
         end if;		
     end process;
	  
end architecture rtl;
	  
	      
		  
	      
         		
		
			
			    

 