# Project setup
BUILD     = ./build
DEVICE    = 5k
FOOTPRINT = sg48

# Files
FILE = rgb.v
#FILE = blinky.v

PROJ = $(basename $(FILE))
.PHONY: all clean flash

all:
	# if build folder doesn't exist, create it
	mkdir -p $(BUILD)
	# synthesize using Yosys
	yosys -p "synth_ice40 -top fpga_top -blif $(BUILD)/$(PROJ).blif" $(FILE)
	# Place and route using arachne
	arachne-pnr -d $(DEVICE) -P $(FOOTPRINT) -o $(BUILD)/$(PROJ).asc -p pinmap.pcf $(BUILD)/$(PROJ).blif
	# Convert to bitstream using IcePack
	icepack $(BUILD)/$(PROJ).asc $(BUILD)/$(PROJ).bin

	bash bin_to_bc.sh $(BUILD)/$(PROJ).bin &>/dev/null

flash:
	npx webfpga-cli flash build/icestorm_example.bin.cbin

clean:
	rm build/*
