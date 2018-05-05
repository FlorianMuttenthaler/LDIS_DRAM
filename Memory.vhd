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
		INTERNAL_COUNTER_MAX: integer := 3; --Default: 3
		-- Size of FIFO buffers
		FIFO_DEPTH_WRITE	: integer := 8; -- Default: 8
		FIFO_DEPTH_READ  	: integer := 8  -- Default: 8	
	);
		
	port (
    	clk_200MHz      	: in  std_logic; -- 200 MHz system clock => 5 ns period time
      	rst             	: in  std_logic; -- active high system reset
      	address 	     	: in  std_logic_vector(26 downto 0); -- address space
      	data_in          	: in  std_logic_vector((8 * (1 + ENABLE_16_BIT) - 1) downto 0); -- data byte input
		r_w			     	: in  std_logic; -- Read or Write flag: '1' ... write, '0' ... read
		mem_ready			: out std_logic; -- allocated memory ready or busy flag: '1' ... ready, '0' ... busy
      	data_out         	: out std_logic_vector((8 * (1 + ENABLE_16_BIT) - 1) downto 0) -- data byte output
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
	
	--Copies of address and data input
	signal address_cpy				: std_logic_vector(26 downto 0);
	signal data_cpy					: std_logic_vector((8 * (1 + ENABLE_16_BIT) - 1) downto 0);
	signal address_cpy_read				: std_logic_vector(26 downto 0);
	
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

	--Internal Counter
	signal counter					: integer := 0;
	signal clk_internal				: std_logic := '0';
	
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
-- Selection related to the size of the data bytes for handling the ram2ddrxadc module
--
	ram_ub <= '1' when ENABLE_16_BIT = 1 else '0';
		
-------------------------------------------------------------------------------
--
-- Process sync_proc_fifos: triggered by clk_200MHz, r_w, full_write_data, full_write_add, full_read_add, empty_read_data, 
--		address_cpy, address, data_cpy, data_in, address_cpy_read, dataOut_read_data
-- Main sync process for fifo management
--
	sync_proc_fifos: process (clk_200MHz, r_w, full_write_data, full_write_add, full_read_add, empty_read_data, 
							  address_cpy, address, data_cpy, data_in, address_cpy_read, dataOut_read_data)
	begin
		if rising_edge(clk_200MHz) then
			if r_w = '1' then
				if (full_write_data = '0' and full_write_add = '0' and (address_cpy /= address or data_cpy /= data_in)) then
					write_dataIn <= '1';
					dataIn_write_data <= data_in;
					dataIn_write_add <= address;
					--Copies
					address_cpy <= address;
					data_cpy <= data_in;
				else
					write_dataIn <= '0';
				end if;
			else
				if full_read_add = '0' and address_cpy_read /= address then
					write_dataOut <= '1';
					dataIn_read_add <= address;
					--Copies
					address_cpy_read <= address;
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
-- Process internal_clk_proc: triggered by clk_200MHz
-- implemtation for internal clock based on counter
--
	internal_clk_proc: process (clk_200MHz, counter)
	begin
		if rising_edge(clk_200MHz) then
			if counter = INTERNAL_COUNTER_MAX then
				counter <= 0;
				clk_internal <= not clk_internal; 
			else
				counter <= counter + 1;
			end if;
		end if;
	end process internal_clk_proc;
			
-------------------------------------------------------------------------------
--
-- Process sync_proc_ram: triggered by clk_internal, r_w, empty_write_data, empty_write_add, empty_read_add, full_read_data, 
--			dataOut_write_add, dataOut_write_data, dataOut_read_add, ram_dq_o
-- Main sync process for ram mangement
--
	sync_proc_ram: process (clk_internal, r_w, empty_write_data, empty_write_add, empty_read_add, full_read_data, 
							dataOut_write_add, dataOut_write_data, dataOut_read_add, ram_dq_o)
	begin
		if rising_edge(clk_internal) then
			if r_w = '1' then
				ram_wen <= '0';
				ram_oen <= '1';
				if empty_write_data = '0' and empty_write_add = '0' then
					read_dataIn <= '1';
					ram_a <= dataOut_write_add;
					if ENABLE_16_BIT = 1 then
						ram_dq_i <= dataOut_write_data;
					else
						ram_dq_i <= std_logic_vector(resize(unsigned(dataOut_write_data), ram_dq_i'length));
					end if;
				else
					read_dataIn <= '0';
				end if;
			else
				ram_wen <= '1';
				ram_oen <= '0';
				if empty_read_add = '0' then
					read_dataOut <= '1';
					ram_a <= dataOut_read_add;
				else
					read_dataOut <= '0';
				end if;
				if full_read_data = '0' then
					write_dataOut <= '1';
					if ENABLE_16_BIT = 1 then
						dataIn_read_data <= ram_dq_o;
					else
						dataIn_read_data <= std_logic_vector(resize(unsigned(ram_dq_o), dataIn_read_data'length));
					end if;
				else
					write_dataOut <= '0';
				end if;
			end if;
		end if;
	end process sync_proc_ram;
			
-------------------------------------------------------------------------------
--
-- Process mem_ready_proc: triggered by full_read_data, full_read_add, full_write_data, full_write_add
-- checks if buffers are full => if memory mangement is ready to work
--
	mem_ready_proc: process (full_read_data, full_read_add, full_write_data, full_write_add)
	begin
		if full_read_data = '1' or full_read_add = '1' or full_write_data = '1' or full_write_add = '1' then
			mem_ready <= '0';
		else
			mem_ready <= '1';
		end if;
	end process mem_ready_proc;
		
end beh;
--
-------------------------------------------------------------------------------