-------------------------------------------------------------------------------
--
-- Memory Interface
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ram2ddrxadc_pkg.all;
use work.fifo_buffer_pkg.all;
--
-------------------------------------------------------------------------------
--
entity memory is

	-- 'ENABLE_16_BIT', 'FIFO_DEPTH_WRITE' and 'FIFO_DEPTH_READ' is the generic value of the entity.
	-- 'clk_200MHz', 'rst', 'address', 'data_in' and 'r_w' are the inputs of entity.
	-- 'mem_ready' and 'data_out' are the outputs of the entity.

	generic(
		ENABLE_16_BIT		: integer range 0 to 1 := 0; -- Default: 0 = disabled, 1 = enabled
		
		-- Size of FIFO buffers
		FIFO_DEPTH_WRITE	: integer := 8; -- Default: 8
		FIFO_DEPTH_READ  	: integer := 8  -- Default: 8	
	);
		
	port (
    	clk_200MHz      	: in  std_logic; -- 200 MHz system clock
      	rst             	: in  std_logic; -- active high system reset
      	address 	     	: in  std_logic_vector(26 downto 0); -- address space
      	data_in          	: in  std_logic_vector(7 downto 0); -- data byte input
		r_w			     	: in  std_logic; -- Read or Write flag
		mem_ready			: out std_logic; -- allocated memory ready or busy flag
      	data_out         	: out std_logic_vector(7 downto 0) -- data byte output
	);

end memory;
--
--------------------------------------------------------------------------------
--
architecture beh of memory is
	--Signals of ram2ddrxadc
	signal device_temp_i 			: std_logic_vector(11 downto 0) := (others => '0');
    
	-- RAM interface
    signal ram_a 					: std_logic_vector(26 downto 0) := (others => '0');
    signal ram_dq_i					: std_logic_vector(15 downto 0) := (others => '0');
	signal ram_dq_o					: std_logic_vector(15 downto 0);
    signal ram_cen					: std_logic := '0';
	signal ram_oen					: std_logic := '0';
	signal ram_wen					: std_logic := '0';
	signal ram_ub 					: std_logic := '0';
	signal ram_lb 					: std_logic := '1';

	-- Read: cen, oen, lb, ub = 0 and wen =1
	-- Write: cen, wen, lb, ub = 0 and oen = 1
    
	-- DDR2 interface
    signal ddr2_addr 				: std_logic_vector(12 downto 0);
    signal ddr2_ba 	 				: std_logic_vector(2 downto 0);
    signal ddr2_ras_n				: std_logic;
	signal ddr2_cas_n				: std_logic;
	signal ddr2_we_n				: std_logic;
    signal ddr2_ck_p				: std_logic_vector(0 downto 0);
	signal ddr2_ck_n				: std_logic_vector(0 downto 0);
	signal ddr2_cke					: std_logic_vector(0 downto 0);
	signal ddr2_cs_n				: std_logic_vector(0 downto 0);
	signal ddr2_odt					: std_logic_vector(0 downto 0);
    signal ddr2_dm					: std_logic_vector(1 downto 0);
	signal ddr2_dqs_p				: std_logic_vector(1 downto 0);
	signal ddr2_dqs_n				: std_logic_vector(1 downto 0);
    signal ddr2_dq 					: std_logic_vector(15 downto 0);
	
	-- FIFOs
	constant DATA_BASE_WIDTH_DATA	: integer := 8 * (1 + ENABLE_16_BIT);  --storage unit length
	constant DATA_BASE_WIDTH_ADDR 	: integer := 27; --storage unit length
	constant DATA_IN_WIDTH			: integer := 1;	--number of units stored on write
	constant DATA_OUT_WIDTH			: integer := 1;	--number of units loaded on read

	-- dataIn signals
	signal dataIn_write_data 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_DATA -1) downto 0);
	signal dataIn_read_data 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_DATA -1) downto 0);
	signal dataIn_write_add 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_ADDR -1) downto 0);
	signal dataIn_read_add 			: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_ADDR -1) downto 0);
	
	-- write signals
	signal write_dataIn 			: std_logic := '0';
	signal write_dataOut 			: std_logic := '0';
	
	-- read signals
	signal read_dataIn 				: std_logic := '0';
	signal read_dataOut 			: std_logic := '0';
	
	-- empty flags
	signal empty_write_data			: std_logic;
	signal empty_write_add			: std_logic;
	signal empty_read_data			: std_logic;
	signal empty_read_add			: std_logic;
	
	-- full flags
	signal full_write_data			: std_logic;
	signal full_write_add			: std_logic;
	signal full_read_data			: std_logic;
	signal full_read_add			: std_logic;
	
	-- dataOut signals
	signal dataOut_write_data 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_DATA -1) downto 0);
	signal dataOut_read_data 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_DATA -1) downto 0);
	signal dataOut_write_add		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_ADDR -1) downto 0);
	signal dataOut_read_add 		: std_logic_vector ((DATA_IN_WIDTH * DATA_BASE_WIDTH_ADDR -1) downto 0);
	
begin
	
	ram2ddrxadc: entity work.ram2ddrxadc
		port map (
			-- Common
      		clk_200MHz_i => clk_200MHz,
      		rst_i => rst,
      		device_temp_i => device_temp_i,
      
      		-- RAM interface
      		ram_a => ram_a,
      		ram_dq_i => ram_dq_i,
      		ram_dq_o => ram_dq_o,
      		ram_cen => ram_cen,
      		ram_oen => ram_oen,
      		ram_wen => ram_wen,
      		ram_ub => ram_ub,
      		ram_lb => ram_lb,
      
      		-- DDR2 interface
      		ddr2_addr => ddr2_addr,
      		ddr2_ba => ddr2_ba,
      		ddr2_ras_n => ddr2_ras_n,
      		ddr2_cas_n => ddr2_cas_n,
      		ddr2_we_n => ddr2_we_n,
      		ddr2_ck_p => ddr2_ck_p,
      		ddr2_ck_n => ddr2_ck_n,
      		ddr2_cke => ddr2_cke,
      		ddr2_cs_n => ddr2_cs_n,
      		ddr2_dm => ddr2_dm,
      		ddr2_odt => ddr2_odt,
      		ddr2_dq => ddr2_dq,
      		ddr2_dqs_p => ddr2_dqs_p,
      		ddr2_dqs_n => ddr2_dqs_n
			);
		
	-- FIFO for addresses, write operation
	fifo_buffer_addr_write: entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH => DATA_BASE_WIDTH_ADDR,
			DATA_IN_WIDTH => DATA_IN_WIDTH,
			DATA_OUT_WIDTH => DATA_OUT_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH_WRITE
		)
			
		port map(
			clk => clk_200MHz,
			rst => rst,
			write => write_dataIn,
			dataIn => dataIn_write_add,
			read => read_dataIn,
			dataOut => dataOut_write_add,
			empty => empty_write_add,
			full => full_write_add
		);
	
	-- FIFO for addresses, read operation
	fifo_buffer_addr_read: entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH => DATA_BASE_WIDTH_ADDR,
			DATA_IN_WIDTH => DATA_IN_WIDTH,
			DATA_OUT_WIDTH => DATA_OUT_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH_READ
		)
			
		port map(
			clk => clk_200MHz,
			rst => rst,
			write => write_dataOut,
			dataIn => dataIn_read_add,
			read => read_dataOut,
			dataOut => dataOut_read_add,
			empty => empty_read_add,
			full => full_read_add
		);
		
	-- FIFO for data, write operation
	fifo_buffer_data_write: entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH => DATA_BASE_WIDTH_DATA,
			DATA_IN_WIDTH => DATA_IN_WIDTH,
			DATA_OUT_WIDTH => DATA_OUT_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH_WRITE
		)
			
		port map(
			clk => clk_200MHz,
			rst => rst,
			write => write_dataIn,
			dataIn => dataIn_write_data,
			read => read_dataIn,
			dataOut => dataOut_write_data,
			empty => empty_write_data,
			full => full_write_data
		);
		
	-- FIFO for data, read operation
	fifo_buffer_data_read: entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH => DATA_BASE_WIDTH_DATA,
			DATA_IN_WIDTH => DATA_IN_WIDTH,
			DATA_OUT_WIDTH => DATA_OUT_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH_READ
		)
			
		port map(
			clk => clk_200MHz,
			rst => rst,
			write => write_dataOut,
			dataIn => dataIn_read_data,
			read => read_dataOut,
			dataOut => dataOut_read_data,
			empty => empty_read_data,
			full => full_read_data
		);
		
-------------------------------------------------------------------------------
--
-- Process sync_proc_fifos: triggered by clk_200MHz, r_w, full_write_data, full_write_add, full_read_add, empty_read_data
-- Main sync process for fifo management
--
	sync_proc_fifos: process (clk_200MHz, r_w, full_write_data, full_write_add, full_read_add, empty_read_data)
	begin
		if rising_edge(clk_200MHz) then
			if r_w = '1' then
				ram_wen <= '0';
				ram_oen <= '1';
				if full_write_data = '0' and full_write_add = '0' then
					write_dataIn <= '1';
					dataIn_write_data <= data_in;
					dataIn_write_add <= address;
				else
					write_dataIn <= '0';
				end if;
			else
				ram_wen <= '1';
				ram_oen <= '0';
				if full_read_add = '0' then
					write_dataOut <= '1';
					dataIn_read_add <= address;
				else
					write_dataOut <= '0';
				end if;
				if empty_read_data = '0' then
					read_dataOut <= '1';
					data_out <= dataOut_read_data;
				else
					read_dataOut <= '0';
				end if;
			end if;
		end if;		
	end process sync_proc_fifos;
	
-------------------------------------------------------------------------------
--
-- Process sync_fifo_write: triggered by clk_200MHz, data_in_valid, data_in
-- synconization of write to fifo buffer
--
--	sync_fifo_write: process (clk_200MHz, data_in_valid, data_in)
--	begin
--		if(rising_edge(clk_200MHz)) then
--			if data_in_valid = '1' then
--				if full = '0' then
--					write <= '1';
--					dataIn <= data_in;
--				else
--					write <= '0';
--				end if;
--			end if;
--		end if;
--	end process sync_proc_write;		
			
end beh;
--
-------------------------------------------------------------------------------