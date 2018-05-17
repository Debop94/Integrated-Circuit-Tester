library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Define_Values_pkg.all;

entity ICTESTER_stmachine is 


	 port(Clock_ICT:in std_logic;--clock from clock divider
	      receive_results:in std_logic_vector(numresults-1 downto 0);--receives  results from the output of the DUT 
			Transmit_test:out std_logic_vector (numtest-1 downto 0);--sends tests to the DUT
			start:in std_logic;---start testing process
		   enable_LED: out std_logic;----this tells the LEDs that there is a result coming
			error_out:out std_logic;-- if there is an error or not light up LEDs appropriately
			FTP_out:in std_logic;--button shows errored patterns with each push
			ECOUNT:in std_logic;------button that shows error count
			error_values: out std_logic_vector(13 downto 0)---only one output for both error pattern and error count depending on button
          );
		
end ICTESTER_stmachine;


Architecture rtl of ICTESTER_stmachine is

  type ICT_modes is (IDLE, TRANSMIT, RECEIVE, CHECK,ZEROCHECKST, CHECK_ERROR_VALS, DONE);--the ICT state Finite State Machine
  signal ICT_STATE: ICT_modes:=IDLE;
  type button_modes is (WAITING,ERRORVALOUT,ERRORCOUNT) ;--state of button push
  signal button_state: button_modes:= WAITING;
  signal RP: results; --Results Pattern. we will retrieve this from the DUT
  signal Led_E: std_logic:='1';--enables LEDs when error is ready. connected to button push
  signal ERxorRP: results:=(others=>(others=>'0'));-- results of ER XOR RP
  type ErrorValuesBuffer is array(0 to TPnum-1) of std_logic_vector(13 downto 0);--each row has the binary for the pattern number that caused an error
  signal ErrorVals: ErrorValuesBuffer:=(others=>(others=>'0'));
  signal error_count: std_logic_vector(13 downto 0);-- we are only considering which test patterns caused erors
  signal error_count_int: integer:= 0;--integer value for error count
  constant zerocheck: std_logic_vector(numresults-1 downto 0):=(others=>'0'); --check if  ER xor RP returned "1"/an error.
  signal error: std_logic:='0';----signifies if there is any error

 
begin


LED_Enable_button: entity work.button_push---instantiated here because not connected externally)
              port map(push_clock=>clock_ICT,
				            button_in=>LED_E,
								button_out=>Enable_LED);

ICT: process(clock_ICT)

variable count: integer:= 0; ---counts which set of patterns we are on
variable count1: integer:=0;--counts which set of patterns we are on for error values
variable FTP: integer := 0;-----Failed TEST Pattern count
variable poll: integer:= 0;--polls the receive state for one clock cycle.
begin
   if rising_edge(clock_ICT) then
	
	  case ICT_STATE is 
		
		  when IDLE =>
		    LED_E <='1';--turns off LED enable
			if start ='1' then
			  RP <= (others=>(others=>'0'));
			  ERxorRP<=(others=>(others=>'0'));
			  ErrorVals<=(others=>(others=>'0'));
			  error_count <=(others=>'0');
			  error_count_int <= 0;
			  FTP:= 0;
			  poll:= 0;
			  ICT_STATE <= TRANSMIT;
			 else
		   	ICT_state <= IDLE;
			 end if;
		
	    
	     when TRANSMIT =>
		  
			 if count < TPnum then
				Transmit_test <= TP(count);--TRANSMITs tests one row at a time
				ICT_state<= Receive;
			 else 
			   count:= 0;----resets count
			   ICT_State<= Check;
			 end if;
		 
        when RECEIVE=>
		     if poll < 1 then -----waits for one clock cycle in case device operates on clock edge
			     poll:= poll + 1;
		     else
				  RP(count)<= receive_results;--receives results one row at a time
				  count:= count + 1;--counts which test pattern we are on 
				  ICT_state <=TRANSMIT;
			  poll:= 0;
			  end if;
			  
			  

        when Check=>
					
			  if RP = ER then--if expected and received results are equal
				 error<= '0';
				 error_count<=(others=>'0');--error_count set to zero for no errors
				 errorvals <=(others=>(others=>'0'));--all zeros displayed if no error values. user can guess there are no FTP if chip is working fine
				 error_count_int <= 1;---this is just to make sure the FTP_out works even when there is no error count
				 ICT_state<= Done;
					
			  else 
				 error<='1';             
				 ICT_state <=CHECK_ERROR_VALS;
				
			  end if;
				 
			when CHECK_ERROR_VALS=>
			
			    if count1<TPnum  then --checks if gone through each test pattern result
				    erxorRP(count1)<= RP(count1) XOR ER(count1);--xors RP and ER by row
				    ICT_state <= ZEROCHECKST;
				  
				 else
				    error_Count<= std_logic_vector(to_unsigned(error_count_int,14));----converts error count to binary
			       count1:= 0;
				    ICT_state<= DONE;
				
			    end if;
				  
				  
			when ZEROCHECKST=>
			      if ERXORRP(count1) = zerocheck then--if no error in the row
					   count1 := count1 + 1;
						ICT_STATE<= cheCK_ERROR_VALS;	
			        		
    		      else
				      error_count_int <= error_count_int + 1;
					   errorvals(0+FTP)<=std_logic_vector(to_unsigned(count1,14));
					   count1 := count1 +1;
					   FTP:=FTP +1;--increments Failed testpatten array 
					   ICT_STATE<= CHECK_ERROR_VALS;
					  
			   	end if;
				
				
		   when DONE=>
			
	          	error_out <=error;--show user if there is an error using LEDs
				   LED_E <='0';--this makes LEDs leave waiting and receive errorvalues
				   ICT_STATE <=IDLE;--go back to start
				
		  when others=>
		  
		         ICT_STATE<=IDLE;
			  
			  
		end case;
		
	 end if;
	 
 end process;
						
-----outputs errors when buttons pushed

output2display:process (clock_ICT) ---------this button will also activate the BCD and display 
variable count2: integer :=0;---button1- number of errors   FTP_out-the testpatterns that caused the error
   begin
   if rising_edge(clock_ICT) then
	   case button_state is
			  
		  when WAITING =>
		  
		      if start ='1'then
				  count2:= 0;
		      elsif FTP_out = '1' then
				   button_state<=ERRORVALOUT;
				elsif 
				   ECOUNT='1' then
					button_state<=ERRORCOUNT;
				else 
				   button_state<= WAITING;
					
			   end if;
				
		   when ERRORVALOUT=>
		   
		      if count2 < error_count_int then
				   error_values<= errorVals(count2);
					count2:= count2+1;
					button_state<= WAITING;
				else 
				   count2:= 0;
				   button_state<= WAITING;
				end if;
				
		   when ERRORCOUNT=>
			
		     count2:= 0;
		     error_values<=error_count;
			  button_state<=WAITING;
			  
		   when others=>
			
		     button_state<=WAITING;
			 
		end case;

	end if;
	
end process;
	
end rtl;


