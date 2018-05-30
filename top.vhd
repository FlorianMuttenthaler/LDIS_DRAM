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
use work.Dbncr_pkg.all;
--
-------------------------------------------------------------------------------
--
entity top is

	-- 'clk_200MHz' are the inputs of entity.

	port (
    	clk_200MHz      				: in  std_logic; -- 200 MHz system clock => 5 ns period time
		rst								: in std_logic;
		btn_read                        : in std_logic;
		btn_write                       : in std_logic;
		data_in							: in std_logic_vector(7 downto 0);
		data_out						: out std_logic_vector(7 downto 0);
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
	signal address: std_logic_vector(26 downto 0) := "000000000000000000000000001";
	signal mem_ready: std_logic;
	signal data_out: std_logic_vector(15 downto 0);
	signal r_w : std_logic;
	
	-- Input Dbncr module
	signal btn_write_en : std_logic := '0';
	signal btn_read_en : std_logic := '0';

	-- States:
	type type_state is (
		STATE_IDLE,
		STATE_WRITE,
		STATE_READ
	);

	signal state, state_next 			: type_state := STATE_IDLE;
	
begin
	memory: entity work.memory
		generic map(
			ENABLE_16_BIT		=> 0,
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
            ddr2_addr       => ddr2_addr,
            ddr2_ba         => ddr2_ba,
            ddr2_ras_n      => ddr2_ras_n,
            ddr2_cas_n      => ddr2_cas_n,
            ddr2_we_n       => ddr2_we_n,
            ddr2_ck_p       => ddr2_ck_p,
            ddr2_ck_n       => ddr2_ck_n,
            ddr2_cke        => ddr2_cke,
            ddr2_cs_n       => ddr2_cs_n,
            ddr2_dm         => ddr2_dm,
            ddr2_odt        => ddr2_odt,
            ddr2_dq         => ddr2_dq,
            ddr2_dqs_p      => ddr2_dqs_p,
            ddr2_dqs_n      => ddr2_dqs_n
		);
		
		Dbncr_w : entity work.Dbncr
		generic map(
			NR_OF_CLKS => 1000
		)

		port map(
			clk_i   => clk_200MHz,
			sig_i   => btn_write,
			pls_o   => btn_write_en
		);

		Dbncr_r : entity work.Dbncr
		generic map(
			NR_OF_CLKS => 1000
		)

		port map(
			clk_i   => clk_200MHz,
			sig_i   => btn_read,
			pls_o   => btn_read_en
		);
			
	sync_proc: process (clk_200MHz, rst)
	begin
		if rst = '1' then
			state <= STATE_IDLE;
		else
			state <= state_next;
		end if;
	end process sync_proc;
			
	main_proc: process (state, btn_write_en, btn_read_en)
	begin
		-- prevent latches for state machine
		state_next 	<= state;
		
		case state is
			when STATE_IDLE =>
				if btn_write_en = '1' then
					state_next <=  STATE_WRITE;
				elsif btn_read_en = '1' then
					state_next <=  STATE_READ;
				end if;
			when STATE_WRITE =>
				r_w <= '1';
				state_next <= STATE_IDLE; 
			when STATE_READ =>
				r_w <= '0';
				state_next <= STATE_IDLE; 
			when others =>
				state_next <= STATE_IDLE; 
	end process main_proc;
		
end beh;
--
-------------------------------------------------------------------------------