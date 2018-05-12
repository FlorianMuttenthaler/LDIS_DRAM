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
		btn_read                        : in std_logic;
		btn_write                       : in std_logic;
		led								: out std_logic;
		-- DDR2 interface
                ddr2_addr            : out   std_logic_vector(12 downto 0);
                ddr2_ba              : out   std_logic_vector(2 downto 0);
                ddr2_ras_n           : out   std_logic;
                ddr2_cas_n           : out   std_logic;
                ddr2_we_n            : out   std_logic;
                ddr2_ck_p            : out   std_logic_vector(0 downto 0);
                ddr2_ck_n            : out   std_logic_vector(0 downto 0);
                ddr2_cke             : out   std_logic_vector(0 downto 0);
                ddr2_cs_n            : out   std_logic_vector(0 downto 0);
                ddr2_dm              : out   std_logic_vector(1 downto 0);
                ddr2_odt             : out   std_logic_vector(0 downto 0);
                ddr2_dq              : inout std_logic_vector(15 downto 0);
                ddr2_dqs_p           : inout std_logic_vector(1 downto 0);
                ddr2_dqs_n           : inout std_logic_vector(1 downto 0)
	);

end top;
--
--------------------------------------------------------------------------------
--
architecture beh of top is
	--constant ENABLE_16_BIT: integer := 1;
	--constant FIFO_DEPTH_WRITE: integer := 8;
	--constant FIFO_DEPTH_READ: integer := 8;
	
	--signal rst: std_logic := '0';
	signal address: std_logic_vector(26 downto 0) := "000000000000000000000000001";
	signal data_in: std_logic_vector(15 downto 0) := "0101010101010101";
	signal mem_ready: std_logic;
	signal data_out: std_logic_vector(15 downto 0);
	signal r_w : std_logic := '1';
	
	constant COUNTER_MAX_WRITE		: integer := 100; -- for 260ns cycle
	signal counter					: integer := 0;
	
	
	-- DDR2 interface
--    signal ddr2_addr                     : std_logic_vector(12 downto 0);
--    signal ddr2_ba                          : std_logic_vector(2 downto 0);
--    signal ddr2_ras_n                    : std_logic;
--    signal ddr2_cas_n                    : std_logic;
--    signal ddr2_we_n                    : std_logic;
--    signal ddr2_ck_p                    : std_logic_vector(0 downto 0);
--    signal ddr2_ck_n                    : std_logic_vector(0 downto 0);
--    signal ddr2_cke                        : std_logic_vector(0 downto 0);
--    signal ddr2_cs_n                    : std_logic_vector(0 downto 0);
--    signal ddr2_odt                        : std_logic_vector(0 downto 0);
--    signal ddr2_dm                        : std_logic_vector(1 downto 0);
--    signal ddr2_dqs_p                    : std_logic_vector(1 downto 0);
--    signal ddr2_dqs_n                    : std_logic_vector(1 downto 0);
--    signal ddr2_dq                         : std_logic_vector(15 downto 0);
	
	
begin
	memory: entity work.memory
		generic map(
			ENABLE_16_BIT		=> 1,
			FIFO_DEPTH_WRITE 	=> 8,
			FIFO_DEPTH_READ 	=> 8
		)
			
		port map(
			clk_200MHz 		=> clk_200MHz,
			rst 			=> rst,
			address 		=> address,
			data_in 		=> data_in,
			r_w 			=> r_w,
			mem_ready 		=> mem_ready,
			data_out 		=> data_out,
			-- DDR2 interface
            ddr2_addr             => ddr2_addr,
            ddr2_ba             => ddr2_ba,
            ddr2_ras_n             => ddr2_ras_n,
            ddr2_cas_n             => ddr2_cas_n,
            ddr2_we_n             => ddr2_we_n,
            ddr2_ck_p             => ddr2_ck_p,
            ddr2_ck_n             => ddr2_ck_n,
            ddr2_cke             => ddr2_cke,
            ddr2_cs_n             => ddr2_cs_n,
            ddr2_dm             => ddr2_dm,
            ddr2_odt             => ddr2_odt,
            ddr2_dq             => ddr2_dq,
            ddr2_dqs_p             => ddr2_dqs_p,
            ddr2_dqs_n             => ddr2_dqs_n
		);

		
-------------------------------------------------------------------------------
--
-- Process main_proc: triggered by clk_200MHz, counter, rst, data_out, data_in
-- Main process for led control based on counter for read/write synchronization
--
	main_proc: process (clk_200MHz, counter, rst, data_out, data_in)
	begin
		if rising_edge(clk_200MHz) then
		    if btn_write = '1' then
		        r_w <= '1';
                led <= '0';
                address <= "000000000000000000000000001";
                data_in <= "0101010101010101";
            end if;
            
            if btn_read = '1' then
                r_w <= '0';
                
                if data_out = data_in then
                    led <= '1';
                else
                    led <= '0';
                end if;
            end if;
                
--			if rst = '1' then
--			    r_w <= '1';
--				led <= '0';
--				counter <= 0;
--				address <= "000000000000000000000000001";
--				data_in <= "0101010101010101";
--			else
--				if counter = COUNTER_MAX_WRITE then
--					r_w <= '0';
--				else
--					counter <= counter + 1;	
--				end if;
--				if data_out = data_in then
--					led <= '1';
--				else
--					led <= '0';
--				end if;
--			end if;
		end if;
	end process main_proc;
		
end beh;
--
-------------------------------------------------------------------------------