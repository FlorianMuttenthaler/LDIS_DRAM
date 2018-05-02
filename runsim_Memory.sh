#!/bin/bash

# Script to simulate TRNG-VHDL designs

# Delete unused files
rm -f *.o *.cf *.vcd

# Simulate design

# Syntax check
ghdl -s Memory.vhdl Memory_pkg.vhdl Memory_tb.vhdl

# Compile the design
ghdl -a Memory.vhdl Memory_pkg.vhdl Memory_tb.vhdl

# Create executable
ghdl -e memory_tb

# Simulate
ghdl -r memory_tb --vcd=memory_tb.vcd

# Show simulation result as wave form
gtkwave memory_tb.vcd &

# Delete unused files
rm -f *.o *.cf
