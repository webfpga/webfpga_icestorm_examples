

# Project setup
DEVICE    = 5k
FOOTPRINT = sg48

# Include the `src` directory in the search path for source (verilog) files
VPATH=src

SOURCES := $(wildcard src/*.v)
BINFILES := $(addprefix build/, $(addsuffix .bin, $(basename $(notdir $(SOURCES)))))

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
ifdef proj
	$(MAKE) build/$(proj).bin
	npm run webfpga-cli flash $(proj).bin.cbin
else
	@echo 'Usage: flash proj={project name, e.g blinky}'
endif

clean:
	-rm -rf build
