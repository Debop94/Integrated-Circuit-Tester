library ieee;
use ieee.std_logic_1164.all;
---------------8 red LEDS come on if there is an error
---------------all 8 green LEDS come on if no error.
--------------LEDS alternate when waiting for error signal.
--------------both lights come on if something is wrong
entity LEDS is 

	port (start: in std_logic;--when ICT is switched on
			error_LED: in std_logic;--error flag from ICTester
			LeD_enable:in std_logic;--tells LEDs that signal is incoming.
			clock_LED: in std_logic;--uses this to count blinking. straight from main clock source(which is 50 in our case)
			o_LEDG: out std_logic_vector(7 downto 0);--uses 8 green LEDs on board
			o_LEDR: out std_logic_vector(7 downto 0) --uses 8 red LEDs on board
			 );
END leds;


Architecture rtl of LEDS is 

	type LED_mode is (IDLE, WAITING, ERRORCHECK);
	signal LED_State: LED_mode:=IDLE;
	signal LEDG: std_logic_vector(7 downto 0):= (others=>'0');
	signal LEDR: std_logic_vector(7 downto 0):= (others=>'0');
	
begin
 LED_Control: process(clock_LED)
 variable count: integer:= 0;
   begin
if rising_edge(clock_LED) then
	   case LED_STATE is
		     when IDLE =>
			   if start ='1' then
				  LEDG <= (others=>'0');
				  LEDR<=(others=>'0');
				  count:= 0;
				  LED_STATE <= WAITING;
				else 
				  LED_STATE<=IDLE; 
				end if;
		    
			  when WAITING =>  ------I want the LEDs to blink on and off  once every 0.25 seconds alternating between G and R. therefore count until 2. 5*10^6
				 if LED_enable='1' then-- from button bush component which is connected to led enable from ICT
				    LED_State<= ERRORCHECK;
				 elsif count> 225000000 then --12. this for now so we can see it's behaviour
					 count:=0;
				 elsif count<12500000 then
					 LEDG<=(others=>'1');
					 LEDR<=(others=>'0');
					 count:= count+1;
              else 
					 LEDG<=(others=>'0');
					 LEDR<=(others=>'1');
					 count:= count+1;
				   end if;
				 
		      
		      WHEN ERRORCHECK =>
	
			     if error_LED = '0' then
				    LEDG <=(others=>'1');--if error 0 lights are green
				    LEDR<=(others=>'0');
				  elsif error_LED ='1' then--if error 1 lights are red
					 LEDR <=(others=>'1');
					 LEDG<=(others=>'0');
				  else 
					 LEDR <=(others=>'1');--both lights come on if there is something wrong.
					 LEDG<=(others=>'1');
			    end if;
				 LED_STATE <= IDLE;
				 
			 WHEN others =>
			 
				 LED_STATE<= IDLE;
				  
	    end case;
	  end if;
   end process;
	
	o_LEDG<=LEDG;
	o_LEDR<=LEDR;

	
	end rtl;
	   