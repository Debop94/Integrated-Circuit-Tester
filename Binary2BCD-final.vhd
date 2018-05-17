library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use work.Define_Values_pkg.all;

-----these take the binary values from ICT and converts them to a BinaryCodedDecimal(BCD).

entity BCD is

 port (start:in std_logic;--clears display when start is pressed
       errornum_input: in std_logic_vector(13 downto 0);--highest possible of errors is 9999 which is 14 bits
       BCD_output0: out std_logic_Vector(3 downto 0);  
		 BCD_output1: out std_logic_Vector(3 downto 0); 
		 BCD_output2: out std_logic_Vector(3 downto 0); --we could combine button 2 and button 3?
	    BCD_output3: out std_logic_Vector(3 downto 0);
		 clock_BCD: in std_logic;
		 FTP_out: in std_logic;--wants to output the error values
		 ECOUNT: in std_logic--wants to output the number of errors
		 );
end BCD;

Architecture rtl of BCD is
   type BCD_Modes is (NOTHING, POLL, SHIFT,INDEXCHECK, ADD3, BCD_COUNT, DONE, REMOVEXTRA0s);
   signal BCD_STATE : BCD_modes:= NOTHING;
	signal errornum_index: integer:= 0; --what number we've shifted's count
   signal BCD_sig: std_logic_Vector(15 downto 0):=(others=>'0');--register for BCD. BCD has 16 bits
	signal errornum_sig: std_logic_Vector(13 downto 0):=(others=> '0');--maximum binary is 7 because max pins is 72
	type integerbuffer is array(0 to 3) of integer range 0 to 9999;--stores integer value of each section for add3
	signal integer_BCD: integerbuffer;
	
 begin
 	 
	 
 SHIFTADD3: process (clock_BCD)
   variable j: integer:=0;
	variable i:integer:=0;
	variable countP:integer:=0;
   begin
  if rising_edge(clock_BCD) then 

			 CASE BCD_STATE is 
			 
				 when NOTHING =>
				 
						 if start= '1' then--if start pressed display is cleared
							 BCD_output0 <= "1111";
							 BCD_output1 <= "1111";
							 BCD_output2 <= "1111";
							 BCD_OUTPUT3 <= "1111";
						   
					   elsif FTP_out= '1' or ECOUNT ='1' then --if either button 2 or 3 is pressed
							 errornum_index<= 0;
							 errornum_sig<=(others=> '0');
							 j:= 0;
							 i:=0;
							 integer_BCD<=(others=> 0);
							 BCD_sig <= (others => '0');--resets BCD sig on button press. this doesn't propagate to the output as that is only done in done state
							 BCD_State <=POLL;
						
					   else
						    BCD_state <= NOTHING;
					   end if ;
					 
				  when POLL=> --waits to ensure for needed signal to reaches input. waits for one clock cycle.
				    if countp< 2 then
					   BCD_STATE<=poll;
						countp:=countp+1;
						else
						countp:=0;
						---------------------------------------
				       errornum_sig <= errornum_input;
						 BCD_STATE <= SHIFT;
						 -----------------------------------
					end if;
						 
					 
				 when SHIFT =>
				 	
					   BCD_sig<= BCD_sig(BcD_sig'left-1 downto 0) & errornum_sig(errornum_sig'left);--shift left errornum bit to BCD
						errornum_sig <= errornum_sig(errornum_sig'left-1 downto 0)&'0'; --shift errornum to the left
					   errornum_index<= errornum_index + 1;-- incremented immediately after the shift. tells us how many numbers we've shifted
					   BCD_state <= INDEXCHECK;
				
					
			  	when INDEXCHECK =>
				 
				    if errornum_index > 13 then --when index =14 we want it to stop as it's shifted through all 14 possible binary bits
						errornum_index <= 0;
						BCD_state <= REMOVEXTRA0s;
					
					 else  
					  integer_BCD(3)<= to_integer(unsigned(BCD_sig(15 downto 12)));--integer values of the four BCD sections
					  integer_BCD(2)<= to_integer(unsigned(BCD_sig(11 downto 8)));
					  integer_BCD(1)<= to_integer(unsigned(BCD_sig(7 downto 4)));
					  integer_BCD(0)<= to_integer(unsigned(BCD_sig(3 downto 0))); 
					  BCD_state<= ADD3;
					  
					 end if;
					
				when ADD3 =>
					 
			       if i> 3 then --gone through all the 4 bit blocks for the BCd
						j := 0;
						i:=0;
						BCD_STATE <= SHIFT;
					 
					elsif integer_BCD(i) > 4 then
						integer_BCD(i)<= integer_BCD(i)+ 3;--if section greater than 4, add 3.
						BCD_State<= BCD_COUNT;

						else 					
						BCD_state <=BCD_COUNT;-- if not greater than 4 nothing is done
				    end if;
					
				When BCD_count=>
						
						bcd_sig(3+j downto 0+j) <= std_logic_Vector(to_unsigned(integer_BCD(i),4));--replace BCD signal with new value
						j:= j + 4;--we move by four to the next segment
						i:=i+1;--move to the next BCD section
					  BCD_state<=Add3;

				when REMOVEXTRA0s => ---this is to remove any zeros that do not need to be displayed 
				
						if BCD_sig(15 downto 12) =("0000")then--if 1st number is zero, replace it with the code for nothing    
							BCD_sig(15 downto 12)<=("1111");         
							if BCD_sig(11 downto 8)=("0000")then       
								 BCD_sig(11 downto 8)<=("1111");      
								 if BCD_sig(7 downto 4)=("0000")then  
									 BCD_sig(7 downto 4)<=("1111");  
									 else BCD_state<=done;
								 end if;
							  else BCD_state<=done;
							 end if;
						  else BCD_state<=done;
					  end if;

				When DONE =>
								   
					  BCD_output0 <= Bcd_sig(3 downto 0);
		           BCD_output1 <= Bcd_sig (7 downto 4);
		           BCD_output2 <= BCD_sig (11 downto 8);  
		           BCD_OUTPUT3 <= BCD_sig (15 downto 12); 
					  BCD_state <= NOTHING;
					  
				when others =>--to avoid latches
					Bcd_state <= NOTHING;
					
			 end case;
			 
     end if;
	  
end process SHIFTADD3;
 
end architecture rtl;