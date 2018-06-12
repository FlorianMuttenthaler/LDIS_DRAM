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

package top_pkg is

	component top is
		-- 'clk_200MHz' are the inputs of entity.

		port (
			clk_200MHz      				: in  std_logic; -- 200 MHz system clock => 5 ns period time
			rst								: in std_logic;
			btn_read                        : in std_logic;
			btn_write                       : in std_logic;
			data_in							: in std_logic_vector(7 downto 0);
			led_out						: out std_logic_vector(7 downto 0);
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
			ddr2_dqs_n           : inout std_logic_vector(1 downto 0);
			
			led_w						: out std_logic;
			led_r						: out std_logic
		);
	end component top;
	
end top_pkg;