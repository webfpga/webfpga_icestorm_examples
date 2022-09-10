# WebFPGA Icestorm Examples

## [1.0.0] Example as shipped with WebFPGA

## [1.1.0] 

### Using make

* The makefile has been completely redone. 
	* You no longer need to edit the makefile to specify a project. 
	* Add the project to `make flash`  like this: `make flash proj=blinky`.
	* Bitstream compression is inline in the make file, removing the need for `bin_to_bc.sh`.
	* `make all` builds everything in `src`

### Pinmaps

* `src/pinmap.pcf` contains the hard-wired perhipherals on the Shasta Plus board. 

### Layout changes
* Sample code moves to the `src` directory.
* Code builds into the `build` directory.
* Tooling moves to the `tools` directory. 

## [1.1.1]

Added configuration file for [gitpod.io](https://gitpod.io). This gives you a browser-based editor 
along all with all the build tools. (But no USB-based flashing, yet.)

## [1.1.2]

Implements `@FPGA_TOP`.

## [1.1.3]

Turns on linting via verilator.