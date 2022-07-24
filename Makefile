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
build/%.json	: %.v build
	yosys -q -p "synth_ice40 -top fpga_top -json $@" $<

# Place and route using arachne
build/%.asc : build/%.json pinmap.pcf
	nextpnr-ice40 --up5k --package $(FOOTPRINT)\
		--asc $@ --json $< \
		--pcf src/pinmap.pcf

# Prepare for flashing. Convert to bitstream w/ icepack
build/%.bin : build/%.asc
	icepack $< $@

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
