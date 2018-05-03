-------------------------------------------------------------------------------
--
-- Memory Interface package
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

	-- 'FIFO_DEPTH_WRITE' and 'FIFO_DEPTH_READ' is the generic value of the entity.
	-- 'clk_200MHz', 'rst', 'address', 'data_in' and 'r_w' are the inputs of entity.
	-- 'mem_ready' and 'data_out' are the outputs of the entity.

	generic(
		--Size of FIFO buffers
			FIFO_DEPTH_WRITE : integer := 8; -- Default: 8
			FIFO_DEPTH_READ  : integer := 8; -- Default: 8	
		);
		
	port (
    	clk_200MHz         	 : in  std_logic; -- 200 MHz system clock
      	rst                  : in  std_logic; -- active high system reset
      	address              : in  std_logic_vector(26 downto 0); -- address space
      	data_in              : in  std_logic_vector(7 downto 0); -- data byte input
		r_w				     : in  std_logic; -- Read or Write flag
		mem_ready		     : out std_logic; -- allocated memory ready or busy flag
      	data_out             : out std_logic_vector(7 downto 0) -- data byte output
	);
	
	end component memory;
	
end memory_pkg;

