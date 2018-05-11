-------------------------------------------------------------------------------
--
-- Top entity for testing the functionality of the memory module on hardware
-- by a simple read and write option
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.Memory_pkg.all;
--
-------------------------------------------------------------------------------
--
entity top is

	-- 'clk_200MHz' are the inputs of entity.
	-- 'led' are the outputs of the entity.

	port (
    	clk_200MHz      				: in  std_logic; -- 200 MHz system clock => 5 ns period time
		rst								: in std_logic;
		led								: out std_logic;
	);

end top;
--
--------------------------------------------------------------------------------
--
architecture beh of top is
	constant ENABLE_16_BIT: integer := 1;
	constant FIFO_DEPTH_WRITE: integer := 8;
	constant FIFO_DEPTH_READ: integer := 8;
	
	signal rst: std_logic := '0';
	signal address: std_logic_vector(26 downto 0) := "000000000000000000000000001";
	signal data_in: std_logic_vector(15 downto 0) := "0101010101010101";
	signal mem_ready: std_logic;
	signal data_out: std_logic_vector(15 downto 0);
	
	constant COUNTER_MAX_WRITE		: integer := 52; -- for 260ns cycle
	signal counter					: integer := 0;
	
	
begin
	memory: entity memory
		generic map(
			ENABLE_16_BIT		=> ENABLE_16_BIT,
			FIFO_DEPTH_WRITE 	=> FIFO_DEPTH_WRITE,
			FIFO_DEPTH_READ 	=> FIFO_DEPTH_READ
		)
			
		port map(
			clk_200MHz 		=> clk_200MHz,
			rst 			=> rst,
			address 		=> address,
			data_in 		=> data_in,
			r_w 			=> r_w,
			mem_ready 		=> mem_ready,
			data_out 		=> data_out
		);

		
-------------------------------------------------------------------------------
--
-- Process main_proc: triggered by clk_200MHz, counter, rst, data_out, data_in
-- Main process for led control based on counter for read/write synchronization
--
	main_proc: process (clk_200MHz, counter, rst, data_out, data_in)
	begin
		if rising_edge(clk_200MHz) then
			if rst = '1' then
				led <= '0';
				counter <= 0;
			else
				if counter = COUNTER_MAX_WRITE then
					r_w <= '1';
				else
					counter <= counter + 1;	
				end if;
				if data_out = data_in then
					led <= '1';
				else
					led <= '0';
				end if;
			end if;
		end if;
	end process main_proc;
		
end beh;
--
-------------------------------------------------------------------------------