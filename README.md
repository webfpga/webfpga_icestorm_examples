# WebFPGA - FPGA IceStorm Examples

This repository is set up for command-line development or online development using [Gitpod](https://gitpod.io). The `src` directory has a couple of examples to get you started:

* blinky.v: blinks the LED once a second using the internal oscillator
* top.v: fades the on-board RGB Neopixel

## If you are using Gitpod (online editing and compiling)

1. [Fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) this repo
2. Prefix the URL with `gitpod.io/#` like this: `gitpod.io/#https://github.com/yourname/webfpga-icestorm-example`
3. Enjoy editing in Visual Studio Code or JetBrains

Use `make` to build your code. 

**Note** You can't flash from Gitpod yet. We're working on it.

## If you are working from the command line

1. Clone this repo
2. Install the [OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build) which includes Yosys, NextPNR, Verilator, etc.

Use `make` to build your code. Use `make flash proj=` and your project name to flash the FPGA.

## Change from the example on Youtube

* The makefile has been completely redone. You no longer need to edit the makefile to specify a project. Instead, add it to the `make flash` command like this: `make flash proj=blinky`.
* Sample code moves to the `src` directory. `make all` builds all of it.
* Tooling moves to the `tools` directory. 