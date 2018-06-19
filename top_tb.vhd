-------------------------------------------------------------------------------
--
-- top Interface Testbench
-- NOTE: Testbench used to test the top interface
--
-------------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.top_pkg.all;

--  A testbench has no ports.
entity top_tb is
end top_tb;
--
-------------------------------------------------------------------------------
--
architecture beh of top_tb is

	-- Specifies which entity is bound with the component.
	for top_0: top use entity work.top;	

	constant CLK_PERIOD			: time := 5 ns;
	
	signal clk_200MHz 			: std_logic := '0';

	signal rst 					: std_logic; -- active high system reset
    signal address 				: std_logic_vector(26 downto 0)  := "000000000000000000000000001"; -- address space
    signal data_in 				: std_logic_vector(7 downto 0); -- data byte input
	signal btn_read				: std_logic := '0';
	signal btn_write			: std_logic := '0';
    signal led_out 			: std_logic_vector(7 downto 0); -- data byte output

	signal ddr2_addr            : std_logic_vector(12 downto 0);
	signal ddr2_ba              : std_logic_vector(2 downto 0);
	signal ddr2_ras_n           : std_logic;
	signal ddr2_cas_n           : std_logic;
	signal ddr2_we_n            : std_logic;
	signal ddr2_ck_p            : std_logic_vector(0 downto 0);
	signal ddr2_ck_n            : std_logic_vector(0 downto 0);
	signal ddr2_cke             : std_logic_vector(0 downto 0);
	signal ddr2_cs_n            : std_logic_vector(0 downto 0);
	signal ddr2_dm              : std_logic_vector(1 downto 0);
	signal ddr2_odt             : std_logic_vector(0 downto 0);
	signal ddr2_dq              : std_logic_vector(15 downto 0);
	signal ddr2_dqs_p           : std_logic_vector(1 downto 0);
	signal ddr2_dqs_n           : std_logic_vector(1 downto 0);
	
	signal led_w					 : std_logic;
	signal led_r					 : std_logic;
	
    -- Debug Ports:
	signal dbg_cnt_write               : integer := 0;
    signal dbg_cnt_read                : integer := 0;
    signal dbg_state                   : integer := 0;

begin

		top_0: top
		port map (
			clk_200MHz => clk_200MHz,
			rst => rst,
			btn_read => btn_read,
			btn_write => btn_write,
			data_in => data_in,
			led_out => led_out,
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
			ddr2_dqs_n => ddr2_dqs_n,
			led_w => led_w,
			led_r => led_r,
			
            -- Debug Ports:
            dbg_writecounter => dbg_cnt_write,
            dbg_readcounter => dbg_cnt_read,
            dbg_state  => dbg_state
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
        
		rst <= '0';
		wait for 100 ns;
		
		btn_write <= '1';
		btn_read <= '0';
		data_in <= "00001111";
        wait for 10000 ns;
		btn_write <= '0';
		btn_read <= '1';
		wait for 10000 ns;
		assert led_out = "00001111" report "Valid data output" severity error;

		wait for 10 ns;
		btn_write <= '1';
		btn_read <= '0';
		data_in <= "11111111";
        wait for 10000 ns;
		btn_write <= '0';
		btn_read <= '1';
		wait for 10000 ns;
		assert led_out = "11111111" report "Valid data output" severity error;
        
		assert false report "end of test" severity failure;

		--  Wait forever; this will finish the simulation.
		wait;

	end process stimuli;

end beh;
--
-------------------------------------------------------------------------------
