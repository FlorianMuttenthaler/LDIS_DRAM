#!/bin/bash

# Script to simulate TRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# compile unsisim
#do "Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ipcore_dir/ddr/example_design/sim/sim.do"

# Syntax check
ghdl -s fifo.vhd fifo_pkg.vhd
ghdl -s Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc.vhd Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc_pkg.vhd
ghdl -s Memory.vhd Memory_pkg.vhd Memory_tb.vhd

# Compile the design
ghdl -a fifo.vhd fifo_pkg.vhd
ghdl -a Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc.vhd Ram2Ddr_RefComp/Source/Ram2DdrXadc_RefComp/ram2ddrxadc_pkg.vhd
ghdl -a Memory.vhd Memory_pkg.vhd Memory_tb.vhd

# Create executable
ghdl -e memory_tb

# Simulate
ghdl -r memory_tb --vcd=memory_tb.vcd

# Show simulation result as wave form
gtkwave memory_tb.vcd &

# Delete unused files
rm -f *.o *.cf
