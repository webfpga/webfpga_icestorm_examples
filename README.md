WebFPGA - FPGA IceStorm Examples
================================

This repository contains a couple of Verilog examples. (In fact, these
examples are stripped verbatim from our website.) We have added
a Makefile that shows a functional build and flash process using IceStorm
with our board. https://www.youtube.com/watch?v=GwvMhctskyo

![Close-Up of WebFPGA Device with RGB LED](https://raw.githubusercontent.com/webfpga/webfpga_icestorm_examples/master/still.jpg)
![Close-Up IceStorm Makefile](https://raw.githubusercontent.com/webfpga/webfpga_icestorm_examples/master/icestorm-still.jpg)

## Change from the example on Youtube

* The makefile has been completely redone. You no longer need to edit the makefile to specify a project. Instead, add it to the `make flash` command like this: `make flash proj=blinky`.
* Sample code moves to the `src` directory. `make all` builds all of them.
* Tooling moves to the `tools` directory. 
## Examples in the `src` directory

* blinky.v: blinks the LED once a second using the internal oscillator
* top.v: fades the on-board RGB Neopixel

