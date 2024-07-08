# Release 3.1.0-rc1

2024-07-08

* OmpSs-2@FPGA
  * Added support for arm32 architecture
  * Added support for intra-FPGA instrumentation based in ovni
* ait
  * Version 7.5.0
  * Updated bitinfo to v12
  * Added `--disable_creator_ports` option to disable memory ports in task-creator accelerators
  * Added support for multi-slr crossing register slices
  * Added support for tuning register slices stages
  * Several bug fixes
* xtasks
  * Version 17.0
  * Added tool to monitor power and temperature stats
  * Added API to access CMS and SYSMON registers
  * Added option to `read_bitinfo` to retrieve bitstream user-id
  * Fixed memory leaks
* xdma
  * Optimization of instrumentation backend
* llvm
  * Keep original FPGA function name when generating HLS wrapper
  * Always emit FPGA HLS copies in the same order to avoid non-deterministic outputs

# Release 3.0.0

2024-03-09

* ait
  * Version 7.3.1
  * Removed support for Vivado < 2021.1
  * Added support for `kv260` board
  * Updated boot step for Petalinux 2021.1
  * Reduced number of default Vivado jobs to launch
* xtasks
  * Added support for multi-FPGA environments
* xdma
  * Added support for multi-FPGA environments
* ompss-at-fpga-kernel-module
  * Disable dma support for kernel >= 6

# Release 2.1.0

2023-12-01

* clang
  * Fix importer issues in C++ code
  * Fix wrong array initializer being emitted in HLS code when using user-defined types
  * Support for class serialization in HLS wrapper
    * Fixes issues using `half` and wide port
  * Support function calls with template parameters
  * Support calling functions defined inside namespaces
  * Support recursive `constexpr`
* ait
  * Version 6.13.0
  * Implemented feature to easily add register slices and floorplanning constraints for SLR-based boards
  * Added static register slices and constraints for `alveo_u200`, `alveo_u280`, `alveo_u280_hbm` and `alveo_u55c` boards
  * Added feature `power_monitor` to instantiate power monitoring infrastructure
  * Added feature `thermal_monitor` to instantiate thermal monitoring infrastructure
  * Added `dump_board_info` argument  to dump board info JSON
  * Fixed HBM AXI resets
  * Excluded unused DDR address segments from address map
  * Fixed `datainterfaces_map` and `interconnect_priorities` features
  * Updated HDL language and C++ standard used in HLS step
  * Fixed POM configuration
* nanos6
  * Added `nanos6_fpga_memcpy_wideport` stubs to the FPGA API
* Picos OmpSs Manager (POM)
  * Version 7.2
  * Added support for multi-level nesting

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
