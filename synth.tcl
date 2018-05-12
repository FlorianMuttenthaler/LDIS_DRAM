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
add_file Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ipcore_dir/ddr.xco
read_vhdl Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc_pkg.vhd
read_vhdl Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc.vhd
read_vhdl fifo_pkg.vhd
read_vhdl fifo.vhd

read_vhdl Memory.vhd

#read_xdc  Memory.xdc
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
