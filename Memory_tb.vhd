-------------------------------------------------------------------------------
--
-- Memory Interface Testbench
-- NOTE: Testbench used to test the memory interface
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

	constant CLK_PERIOD : time := 5 ns;
	
	--Size of FIFO buffers
	constant FIFO_DEPTH_WRITE : integer := 8;
	constant FIFO_DEPTH_READ  : integer := 8;
	
	signal clk_200MHz : std_logic := '0';

	signal rst : std_logic; -- active high system reset
    signal address : std_logic_vector(26 downto 0); -- address space
    signal data_in : std_logic_vector(7 downto 0); -- data byte input
	signal r_w	: std_logic; -- Read or Write flag
	signal mem_ready : std_logic; -- allocated memory ready or busy flag
    signal data_out : std_logic_vector(7 downto 0); -- data byte output

begin

	--  Component instantiation.
	memory_0: memory
		generic map(
			FIFO_DEPTH_WRITE : integer := 8; -- Default: 8
			FIFO_DEPTH_READ  : integer := 8; -- Default: 8	
		)
			
		port map (
			clk_200MHz => clk_200MHz,
      		rst => rst,
			address => address,
			data_in => data_in,
			r_w	=> r_w,
			mem_ready => mem_ready,
			data_out => data_out
		);
--
--------------------------------------------------------------------------------
--
	clk_process : process
	
	begin
		clk_200MHz <= '0';
		wait for CLK_PERIOD/2;
		clk_200MHz <= '1';
		wait for CLK_PERIOD/2;

	end process clk_process;	
--
--------------------------------------------------------------------------------
--  This process does the real job.
--
	stimuli : process

	begin

		wait for 100 ns;
		

		assert false report "end of test" severity failure;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
