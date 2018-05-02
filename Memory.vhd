-------------------------------------------------------------------------------
--
-- KDF
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

	-- is the generic value of the entity.
	-- 'clk_200MHz_i', 'rst_i', 'address', 'data_in', 'r_w' are the inputs of entity.
	-- 'mem_ready', 'data_out' are the outputs of the entity.

	generic(
		--Size of FIFO buffers
			FIFO_DEPTH_WRITE : integer := 8; -- Default 8
			FIFO_DEPTH_READ : integer := 8; -- Default 8	
		);
		
	port (
    	clk_200MHz         : in    std_logic; -- 200 MHz system clock
      	rst                : in    std_logic; -- active high system reset
      	address            : in    std_logic_vector(26 downto 0); -- address space
      	data_in            : in    std_logic_vector(7 downto 0); -- data byte input
		r_w				   : in 	 std_logic; -- Read or Write flag
		mem_ready		   : out   std_logic; -- allocated memory ready or busy flag
      	data_out           : out   std_logic_vector(7 downto 0) -- data byte output
	);

end memory;
--
-----------------------------------------------------------l--------------------
--
architecture beh of memory is
	--Signals of ram2ddrxadc
	signal device_temp_i : std_logic_vector(11 downto 0) := (others => '0');
      
    signal ram_a : std_logic_vector(26 downto 0);
    signal ram_dq_i, ram_dq_o : std_logic_vector(15 downto 0);
    signal ram_cen, ram_oen, ram_wen : std_logic;
	signal ram_ub : std_logic := '0';
	signal ram_lb : std_logic := '1';
      
    signal ddr2_addr : std_logic_vector(12 downto 0);
    signal ddr2_ba : std_logic_vector(2 downto 0);
    signal ddr2_ras_n, ddr2_cas_n, ddr2_we_n : std_logic;
    signal ddr2_ck_p, ddr2_ck_n, ddr2_cke, ddr2_cs_n, ddr2_odt : std_logic_vector(0 downto 0);
    signal ddr2_dm, ddr2_dqs_p, ddr2_dqs_n : std_logic_vector(1 downto 0);
    signal ddr2_dq : std_logic_vector(15 downto 0);
	
	--FIFOs
	constant DATA_BASE_WIDTH_DATA: integer := 8;	--storage unit length
	constant DATA_BASE_WIDTH_ADDR: integer := 27;	--storage unit length
	constant DATA_IN_WIDTH	: integer := 1;	--number of units stored on write
	constant DATA_OUT_WIDTH	: integer := 1;	--number of units loaded on read

	signal dataIn : std_logic_vector ((DATA_IN_WIDTH *DATA_BASE_WIDTH -1) downto 0);
	signal write_dataIn : std_logic := '0';
	signal write_dataOut : std_logic := '0';
	signal read_dataIn : std_logic := '0';
	signal read_dataOut : std_logic := '0';
	signal empty, full	: std_logic;
	signal dataOut : std_logic_vector ((DATA_OUT_WIDTH*DATA_BASE_WIDTH -1) downto 0);
	
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
			dataIn => dataIn,
			read => read_dataIn,
			dataOut => dataOut,
			empty => empty,
			full => full
		);
		
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
			dataIn => dataIn,
			read => read_dataOut,
			dataOut => dataOut,
			empty => empty,
			full => full
		);
		
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
			dataIn => dataIn,
			read => read_dataIn,
			dataOut => dataOut,
			empty => empty,
			full => full
		);
		
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
			dataIn => dataIn,
			read => read_dataOut,
			dataOut => dataOut,
			empty => empty,
			full => full
		);
		
-------------------------------------------------------------------------------
--
-- Process sync_proc: triggered by clk_200MHz
-- Main sync process
--
	sync_proc: process (clk_200MHz)
	begin
		
	end process sync_proc;
			

	
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