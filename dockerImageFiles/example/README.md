OmpSs-2@FPGA Example Readme
=========================

This directory contains a basic implementation of the dotproduct kernel using FPGA tasks.

### Build

There are some steps to build the application: setup the environment, generate the bitstream, generate the boot files (depending on the board) and build the executables.
The example comes with a Makefile that allows easily building the bitstream (and boot) and executables.

##### Environment setup

The environment variables that we may need to set up for the compilation process are:
 * `CROSS_COMPILE` [Def: ""] Cross compiler prefix. The docker image has the tool-chain supporting:
   * `aarch64-linux-gnu-` (ARM 64bits).
   * `arm-linux-gnueabihf-` (ARM 32bits).
 * `CFLAGS` [Def: ""] Compiler flags.
 * `LDFLAGS` [Def: ""] Linker flags.
 * `PETALINUX_BUILD` [Def: ""] Petalinux project directory (only needed when building boot files)

**NOTE: Do not source petalinux and/or vivado settings as they may break toolchain configuration.**

For example, we will set the following environment variables to build the example application for the ZCU102:

```bash
export CROSS_COMPILE=aarch64-linux-gnu-
```

##### Bitstream

To generate the bitstream, we must enable the bitstream generation in the LLVM/Clang compiler (using the `--fompss-fpga-wrapper-code` flag) and provide it the FPGA linker (aka `ait`) flags with `--fompss-fpga-ait-flags` option.
In addition, we can use the `--fompss-fpga-instrumentation` option of LLVM/Clang to enable the HW instrumentation generation.
The instrumentation can be generated and not used when running the application, but if we generate the bitstream without instrumentation support we will not be able to instrument the execution in the FPGA accelerators.

The Makefile has a set of generic targets to build the bitstream for any board.
One just enables bitstream generation, another enables instrumentation and the third one enables hardware debug.
Then, we can just execute the following command to generate a first bitstream:

```bash
make bitstream-p BOARD=zcu102
```

Note that `ait` expects to have `vitis_hls` and `vivado` tools in the path.
Therefore, we need to add them to the `PATH` environment variable.
Assuming that Xilinx software version 2021.1 is available in `/opt/xilinx` folder, we can add them with the following command:

```bash
export PATH=$PATH:/opt/xilinx/Vivado/2021.1/bin
```

**NOTE: Do not source vivado settings as it may break the toolchain configuration.**

##### Boot Files

The Makefile has a target to build the boot once the bitstream has been created.

To generate the boot files, we need to have the `PETALINUX_BUILD` environment variable appropriately set.
Then, we can run:

```bash
make boot BOARD=zcu102
```

##### Executables

The build target of the Makefile builds 3 versions of the application (and not the bitstream): performance, debug and instrumentation.
To generate them we have to execute:

```bash
make dotprodut-p dotproduct-d dotproduct-i
```

### Run

We should copy the files to the board and after that we can proceed with the following steps.
The files should include at least:
 * dotproduct.bin (bitstream).
 * dotproduct-d, dotproduct-i, dotproduct-p (executables).

##### Load the bitstream

In order to load the bitstream we can use the `fpgautil` utility from Xilinx.

```bash
fpgautil -b dotproduct.bin
```

##### Debug run

The debug version of the application runs using the Nanos6 debug version, which has sanity checks to avoid hangs or runtime crashes.
It is used like other binaries but some runtime options will provide more information (like `version.instrument=verbose`).

```bash
NANOS6_CONFIG_OVERRIDE="version.instrument=verbose" ./dotproduct-d
```

##### Performance run

The performance version of the application runs without instrumentation nor debug enabled.

```bash
./dotproduct-p
```

##### Instrumentation run

The ovni instrumentation tool has been extended to support device instrumentation, so the runtime will gather information from the FPGA accelerators and add them to the ovni trace.

```bash
NANOS6_CONFIG_OVERRIDE="version.instrument=ovni" ./dotproduct-i
```
