################################################################################
##  <Makefile for udp_responder project>
##  Copyright (C) 2026 James Hicks
##
##  This program is free software: you can redistribute it and/or modify
##  it under the terms of the GNU General Public License as published by
##  the Free Software Foundation, either version 3 of the License, or
##  (at your option) any later version.
##
##  This program is distributed in the hope that it will be useful,
##  but WITHOUT ANY WARRANTY; without even the implied warranty of
##  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##  GNU General Public License for more details.
##
##  You should have received a copy of the GNU General Public License
##  along with this program.  If not, see <https://www.gnu.org/licenses/>.
################################################################################

# Makefile

# Defaults
SIM ?= verilator
EXTRA_ARGS += --coverage
EXTRA_ARGS += --trace --trace-fst --trace-structs

WAVES = 1

TOPLEVEL_LANG ?= verilog

VERILOG_SOURCES += $(PWD)/../src/mac_tx.sv

COCOTB_LOG_LEVEL = DEBUG

# COCOTB_TOPLEVEL is the name of the toplevel module in your Verilog or VHDL file
COCOTB_TOPLEVEL = mac_tx

# COCOTB_TEST_MODULES is the basename of the Python test file(s)
COCOTB_TEST_MODULES = test_11_normal_operation

COCOTB_HDL_TIMEUNIT = 1us
COCOTB_HDL_TIMEPRECISION = 1us

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim
