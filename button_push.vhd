library ieee;
use ieee.std_logic_1164.all;

entity button_push is--when button is pushed, output active for one clock cycle

	port 
	(
		push_clock		: in std_logic;
		button_in  : in std_logic;
		button_out: 	out std_logic
	);

end entity;

architecture rtl of button_push is

	signal prev_button : std_logic:='1';--previous state of button
  --signal prev_button2 : std_logic:='1';--previous state of button
begin


	process (push_clock)
	begin
	if (rising_edge(push_clock)) then
       --replace previous state. button is low when pushed.
				prev_button <= button_in;
				--prev_button2 <= prev_button;


		end if;
	end process;

	-- checks if there is a change in button state. if so 1 & not 0 = 1 therefore output activated while there is a difference
	button_out <= not button_in and  prev_button;--not moved

end rtl;