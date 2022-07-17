# WebFPGA Icestorm Examples

## [1.0.0] Example as shipped with WebFPGA

## [1.1.0] 

### Using make

* The makefile has been completely redone. 
	* You no longer need to edit the makefile to specify a project. 
	* Add the project to `make flash`  like this: `make flash proj=blinky`.
	* Bitstream compression is is inline in the make file, removing the need for `bin_to_bc.sh`.
	* `make all` builds everything in `src`

### Pinmaps

* `src/pinmap.pcf` contains the hard-wired perhipherals on the Shasta Plus board. 

### Layout changes
* Sample code moves to the `src` directory.
* Code builds into the `build` directory.
* Tooling moves to the `tools` directory. 

