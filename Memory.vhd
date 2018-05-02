-------------------------------------------------------------------------------
--
-- KDF
--
-------------------------------------------------------------------------------
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ram2ddrxadc.all;
use work.fifo_buffer_pkg.all;
--
-------------------------------------------------------------------------------
--
entity memory is

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

end memory;
--
-------------------------------------------------------------------------------
--
architecture beh of memory is
	--Signals of ram2ddrxadc
	signal device_temp_i : std_logic_vector(11 downto 0);
      
    signal ram_a : std_logic_vector(26 downto 0);
    signal ram_dq_i, ram_dq_o : std_logic_vector(15 downto 0);
    signal ram_cen, ram_oen, ram_wen, ram_ub, ram_lb : std_logic;
      
    signal ddr2_addr : std_logic_vector(12 downto 0);
    signal ddr2_ba : std_logic_vector(2 downto 0);
    signal ddr2_ras_n, ddr2_cas_n, ddr2_we_n : std_logic;
    signal ddr2_ck_p, ddr2_ck_n, ddr2_cke, ddr2_cs_n, ddr2_odt : std_logic_vector(0 downto 0);
    signal ddr2_dm, ddr2_dqs_p, ddr2_dqs_n : std_logic_vector(1 downto 0);
    signal ddr2_dq : std_logic_vector(15 downto 0);
	
	--FIFO
	constant DATA_BASE_WIDTH: integer;	--storage unit length
	constant DATA_IN_WIDTH	: integer;	--number of units stored on write
	constant DATA_OUT_WIDTH	: integer;	--number of units loaded on read
	constant FIFO_DEPTH		: integer;	--number of available units

	signal dataIn : std_logic_vector ((DATA_IN_WIDTH *DATA_BASE_WIDTH -1) downto 0);
	signal write, read, empty, full	: std_logic;
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
		
	fifo_buffer: entity work.fifo_buffer
		generic map(
			DATA_BASE_WIDTH => DATA_BASE_WIDTH,
			DATA_IN_WIDTH => DATA_IN_WIDTH,
			DATA_OUT_WIDTH => DATA_OUT_WIDTH,
			FIFO_DEPTH => FIFO_DEPTH
		)
			
		port map(
			clk => clk_200MHz_i,
			rst => rst_i,
			write => write,
			dataIn => dataIn,
			read => read,
			dataOut => dataOut,
			empty => empty,
			full => full
		);
	
end beh;
--
-------------------------------------------------------------------------------