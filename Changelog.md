# Release 2.0.1
2023-08-03

* ait
  * Version 6.8.2
  * Fixed ZynqMP address mapping
  * Fixed POM configuration setting
* xdma
  * Added support for unaligned memcpy on Zynq backend
* nanos6
  * Fixed race condition
  * Fixes on FPGAReverseOffload polling service

# Release 2.0.0
2023-06-28

* ait
  * Version 6.8.0
  * Added support for `alveo_u55c` board
  * Added support for HBM-based boards
  * Updated bitinfo to v10
  * Fixes for Vitis HLS and newer Vivado versions
* mcxx
  * Deprecated support for Mercurium compiler
* llvm
  * Added support for clang compiler
* nanos6
  * Updated with upstream repository
* xdma
  * Bump version to 4.3
  * Reduce copy chunk size to workaround issues in qdma 5
* xtasks
  * Implemented `read_bitinfo` tool to read bitstream information from bitInfo BRAM
* Picos OmpSs Manager (POM)
  * Version 7.1
  * Updated encryption key

# Release 1.0.1
2023-03-06

* ait
  * Version 6.5.3
  * Added support for `alveo_u280` and `alveo_u280_hbm` boards
  * Fixed not being able to correctly run AIT from synthesis or implementation step
  * Fixed timing constraints
  * Changed default target language to verilog
  * Correctly check Vivado naming conventions
* Picos OmpSs Manager (POM)
  * Version 6.1
  * Disable dependencies, reverse offload and task creation by default


# Release 1.0.0
2023-02-03

Initial release of OmpSs-2@FPGA toolchain
