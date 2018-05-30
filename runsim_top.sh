#!/bin/bash

# Script to simulate TRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s fifo.vhd fifo_pkg.vhd
ghdl -s ram2ddrxadc.vhd ram2ddrxadc_pkg.vhd
ghdl -s Memory.vhd Memory_pkg.vhd
ghdl -s Dbncr.vhd Dbncr_pkg.vhd
ghdl -s top.vhd top_pkg.vhd top_tb.vhd

# Compile the design
ghdl -a fifo.vhd fifo_pkg.vhd
ghdl -a ram2ddrxadc.vhd ram2ddrxadc_pkg.vhd
ghdl -a Memory.vhd Memory_pkg.vhd
ghdl -a Dbncr.vhd Dbncr_pkg.vhd
ghdl -a top.vhd top_pkg.vhd top_tb.vhd
# Create executable
ghdl -e top_tb

# Simulate
ghdl -r top_tb --vcd=top_tb.vcd

# Show simulation result as wave form
gtkwave top_tb.vcd &

# Delete unused files
rm -f *.o *.cf
