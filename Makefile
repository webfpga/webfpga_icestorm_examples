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

# Keep these files in the build directory (and remove other intermediates)
.PRECIOUS: build/%.pcf build/%.bin

# Compiles all .v files so they're ready to flash
all	: $(BINFILES)
	echo '$(SOURCES)'

# Compile verilog to an intermediate form, and create the build dir if needed
build/%.json	: %.v build
	yosys -q -p "synth_ice40 -top $(shell tools/get_top.py $<) -json $@" $<

# Generate .pcf (Physical Constraints File) from @MAP_IO statements
build/%.pcf : src/%.v
	tools/map_io.py -o $@ $<

# Place and route using arachne
build/%.asc : build/%.json build/%.pcf
	nextpnr-ice40 --up5k --package $(FOOTPRINT) --asc $@ --pcf $(addsuffix .pcf, $(basename $<)) --json $<

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
