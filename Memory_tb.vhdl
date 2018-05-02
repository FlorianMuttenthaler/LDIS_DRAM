-------------------------------------------------------------------------------
--
-- 7-segment display Testbench
-- NOTE: Testbench used to test the segment light diplay with a random number 
-- smaller than display size
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.memory_pkg.all;


--  A testbench has no ports.
entity memory_tb is
end memory_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of memory_tb is

	--  Specifies which entity is bound with the component.
	for memory_0: memory use entity work.memory;	

	constant clk_period : time := 1 ns;
	
	signal clk : std_logic := '0';


begin

	--  Component instantiation.
	memory_0: memory
		generic map(

		)
			
		port map (

		);

	clk_process : process
	
	begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;

	end process clk_process;	

	--  This process does the real job.
	stimuli : process

	begin

		wait for 20 ns;
		

		assert false report "end of test" severity failure;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
