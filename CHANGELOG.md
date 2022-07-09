# WebFPGA Icestorm Examples

## [1.0.0] Example as shipped with WebFPGA

## [2.0.0] 

* The makefile has been completely redone. 
	* You no longer need to edit the makefile to specify a project. 
	* Add the project to `make flash`  like this: `make flash proj=blinky`.
	* Bitstream compression is is inline in the make file, removing the need for `bin_to_bc.sh`.
* Sample code moves to the `src` directory. `make all` builds everything.
* Tooling moves to the `tools` directory. 
