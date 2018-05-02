#------------------------------------------------------------------------------
#
# Synthesis script for RNG using Digilent Nexys 4 DDR board
#
# -----------------------------------------------------------------------------
#
create_project -part xc7a100t -force vivado/RNG
#
# -----------------------------------------------------------------------------
#

#read_vhdl TRNG_pkg.vhdl
#read_vhdl TRNG.vhdl
#read_vhdl SlowClock_pkg.vhdl
#read_vhdl SlowClock.vhdl
#read_vhdl 7seg_pkg.vhdl
#read_vhdl 7seg.vhdl
#read_vhdl uart/uart_tx/uart_tx_pkg.vhd
#read_vhdl uart/uart_tx/uart_tx.vhd
#read_vhdl uart/uart_rx/uart_rx_pkg.vhd
#read_vhdl uart/uart_rx/uart_rx.vhd
read_vhdl Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc.vhd


read_vhdl Memory.vhdl

read_xdc  Memory.xdc
#
# -----------------------------------------------------------------------------
#
synth_design -top memory
#
# -----------------------------------------------------------------------------
#
opt_design
place_design
route_design
#
# -----------------------------------------------------------------------------
#
#write_verilog -force -mode timesim RNG_post.v
write_bitstream -force vivado/memory.bit
#
# -----------------------------------------------------------------------------
