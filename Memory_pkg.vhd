-------------------------------------------------------------------------------
--
-- 7-segment display package
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--
-------------------------------------------------------------------------------
--
package memory_pkg is

	component memory is

	-- is the generic value of the entity.
	-- 'clk_200MHz_i', 'rst_i', 'address', 'data_in', 'r_w' are the inputs of entity.
	-- 'mem_ready', 'data_out' are the outputs of the entity.

	generic(

	);
		
	port (	
		clk_200MHz         : in    std_logic; -- 200 MHz system clock
      	rst                : in    std_logic; -- active high system reset
      	address              : in    std_logic_vector(26 downto 0); -- address space
      	data_in              : in    std_logic_vector(7 downto 0); -- data byte input
		r_w					 : in 	 std_logic; -- Read or Write flag
		mem_ready			 : out   std_logic; -- allocated memory ready or busy flag
      	data_out             : out   std_logic_vector(7 downto 0); -- data byte output
	);
	
	end component memory;
	
end memory_pkg;

