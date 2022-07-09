# Copyright 2019-2022 Auburn Ventures LLC and contributors
# SPDX-License-Identifier: MIT

# Project setup
DEVICE    = 5k
FOOTPRINT = sg48

# Include the `src` directory in the search path for source (verilog) files
VPATH=src

# Find all verilog files
SOURCES := $(wildcard src/*.v)
# Create a list of .bin files from the sources
BINFILES := $(addprefix build/, $(addsuffix .bin, $(basename $(notdir $(SOURCES)))))
# Look for the `webfpga` tool on the path and save the return code
HAS_CLI = $(shell which webfpga; echo $$?)


.PHONY: all build clean flash proj

# Compiles all .v files so they're ready to flash
all	: $(BINFILES)
	echo '$(SOURCES)'

# Compiles verilog to an intermediate form
build/%.blif	: %.v build
	yosys -q -p "synth_ice40 -top fpga_top -blif $@" $<

# Place and route using arachne
build/%.asc : build/%.blif
	arachne-pnr -q -d $(DEVICE) -P $(FOOTPRINT) -o $@ -p pinmap.pcf $<

# Prepare for flashing. Convert to bitstream w/ icepack then compress
build/%.bin : build/%.asc
	icepack $< $@
	tools/compress-bitstream $@ $@.h h  "$E+Fri_14_Jun_2019_09:00:38_PM_UTC+shastaplus"
	tools/compress-bitstream $@.h $@.c  c
	tools/compress-bitstream $@.c $@.cbin  b
	tools/compress-bitstream $@.cbin $@.db db

build:
	mkdir -p build

# Usage: make flash proj={project}
flash:
ifeq ($(HAS_CLI), 1) 
	$(error "Run `pip install webfpga` first, please")
endif
ifdef proj
	$(MAKE) build/$(proj).bin
	webfpga flash build/$(proj).bin
else
	@echo 'Usage: flash proj={project name, e.g blinky}'
endif

clean:
	-rm -rf build
