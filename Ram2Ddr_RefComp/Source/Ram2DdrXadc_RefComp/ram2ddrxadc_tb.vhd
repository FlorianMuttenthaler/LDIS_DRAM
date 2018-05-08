----------------------------------------------------
--    Simulated Nexys4DDR SRAM to DDR component   --
--                                                --
-- Originally by DOULOS, adapted by Warren Toomey --
----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram2ddrxadc_tb is
end ram2ddrxadc_tb;

-- architecture
architecture behaviour of ram2ddrxadc_tb is
    component ram2ddrxadc is
   port (
      -- Common
      clk_200MHz_i         : in    std_logic; 			  -- 200 MHz system clock
      rst_i                : in    std_logic; 			  -- active high system reset
      device_temp_i        : in    std_logic_vector(11 downto 0); -- not implemented!
      
      -- RAM interface
      ram_a                : in    std_logic_vector(26 downto 0);
      ram_dq_i             : in    std_logic_vector(15 downto 0);
      ram_dq_o             : out   std_logic_vector(15 downto 0);
      ram_cen              : in    std_logic;
      ram_oen              : in    std_logic;
      ram_wen              : in    std_logic;
      ram_ub               : in    std_logic;
      ram_lb               : in    std_logic;
      
      -- DDR2 interface.
      -- None of the signals below are implemented in this simulated component!
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
   end component;

   -- Signals to display as waveforms
   signal RST_I: std_logic;
   signal RAM_A: std_logic_vector(26 downto 0);
   signal RAM_DQ_I: std_logic_vector(15 downto 0);
   signal RAM_DQ_O: std_logic_vector(15 downto 0);
   signal RAM_CEN: std_logic;
   signal RAM_OEN: std_logic;
   signal RAM_WEN: std_logic;
   signal RAM_UB: std_logic;
   signal RAM_LB: std_logic;

   signal clk: std_logic;
   signal end_simulation: integer := 0;

   -- Clock period definitions
   constant clock_period : time := 5 ns;

begin

    -- Clock process definition
    clock_process: process
    begin
        clk <= '0';
        wait for clock_period/2;
        clk <= '1';
        wait for clock_period/2;

        if end_simulation = 1 then wait;
        end if;
    end process;

    -- Unit under test port map
    uut: ram2ddrxadc port map (
          clk_200MHz_i => clk,
          rst_i => '0',
          device_temp_i => (others => '0'),
          ram_a => RAM_A,
          ram_dq_i => RAM_DQ_I,
          ram_dq_o => RAM_DQ_O,
          ram_cen => RAM_CEN,
          ram_oen => RAM_OEN,
          ram_wen => RAM_WEN,
          ram_ub => RAM_UB,
          ram_lb => RAM_LB,
          ddr2_addr => open,
          ddr2_ba => open,
          ddr2_ras_n => open,
          ddr2_cas_n => open,
          ddr2_we_n => open,
          ddr2_ck_p => open,
          ddr2_ck_n => open,
          ddr2_cke => open,
          ddr2_cs_n => open,
          ddr2_dm => open,
          ddr2_odt => open,
          ddr2_dq => open,
          ddr2_dqs_p => open,
          ddr2_dqs_n => open);

    --- Stimulation process
    stim_proc: process
    begin
	-- Write 0x1234 at location 0
	RAM_A <= "000000000000000000000000000";
	RAM_DQ_I <= x"1234";
	RAM_WEN <= '0'; RAM_CEN <= '0'; RAM_OEN <= '1';
	RAM_UB <= '0'; RAM_LB <= '0';
	wait for clock_period * 60;

	-- Write 0x5678 at location 1
	RAM_A <= "000000000000000000000000001";
	RAM_DQ_I <= x"5678";
	RAM_WEN <= '0'; RAM_CEN <= '0'; RAM_OEN <= '1';
	RAM_UB <= '0'; RAM_LB <= '0';
	wait for clock_period * 60;

	-- Write 0x9abc at location 2
	RAM_A <= "000000000000000000000000010";
	RAM_DQ_I <= x"9abc";
	RAM_WEN <= '0'; RAM_CEN <= '0'; RAM_OEN <= '1';
	RAM_UB <= '0'; RAM_LB <= '0';
	wait for clock_period * 60;

	-- Read from location 0
	RAM_A <= "000000000000000000000000000";
	RAM_WEN <= '1'; RAM_CEN <= '0'; RAM_OEN <= '0';
	RAM_UB <= '0'; RAM_LB <= '0';
	wait for clock_period * 60;

	-- Read from location 1
	RAM_A <= "000000000000000000000000001";
	RAM_WEN <= '1'; RAM_CEN <= '0'; RAM_OEN <= '0';
	RAM_UB <= '0'; RAM_LB <= '0';
	wait for clock_period * 60;

	-- Read upper from location 2
	RAM_A <= "000000000000000000000000010";
	RAM_WEN <= '1'; RAM_CEN <= '0'; RAM_OEN <= '0';
	RAM_UB <= '0'; RAM_LB <= '1';
	wait for clock_period * 60;

	-- Read lower from location 2
	RAM_A <= "000000000000000000000000010";
	RAM_WEN <= '1'; RAM_CEN <= '0'; RAM_OEN <= '0';
	RAM_UB <= '1'; RAM_LB <= '0';
	wait for clock_period * 60;

        report "test finished" severity note;
        end_simulation <= 1;
        wait;
    end process;
end;
