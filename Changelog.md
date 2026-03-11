# Release 4.0.1
2026-03-10

* ait
  * Version 8.2.1
  * Updated bitinfo to v16
  * Fixed IMP not beig enabled
  * Added IMP flag to the bitinfo feature bitmap
  * Fixed printing color codes on non-TTY stdouts
* llvm
  * Add missing operators to the mcxx_pointer type to support functions and local arrays
  * Properly initialize mcxx_ptr when converting from local storage pointer
* xtasks
  * Version 17.11
  * Added information about IMP in `read_bitinfo`
* ovni
  * Updated to upstream version 1.13.0
  * Fixed error when using `-x xtasksfile` option
* IPs
  * OMPIF - Message sender
    * Version 1.4
    * Fixed MAX_RETRIES register overflow

# Release 4.0.0
2025-12-19

* ait 
  * Version 8.1.0
  * Updated bitinfo to v15
  * Internal refactor
  * Removed arguments:
    * `datainterfaces_map`, `debug_intfs`, `debug_intfs_list`, `disable_creator_ports`, `floorplanning_constr`, `interconnect_regslice`, `simplify_interconnection` and `slr_slices`
  * Added arguments:
    * `disable_static_constraints`, `interconnect_regslices` and `user_config`
  * Implemented user configuration json to allow for fine-grain configuration
  * Default value for argument `interconnect_opt` changed from `area` to `performance`
  * Constraints and register slices for static logic enabled by default, added an argument to disable them
  * Added information about memory size in the bitinfo
  * Added workaround to avoid a bug when adding System ILAs automatically in a Vivado design
  * Remove memory interleaving limitation
  * Fixed detecting modified sources when installing
  * Removed `simulation` board
* Clang 
  * Add support for the IMP model
  * Update OMPIF API
  * Updated format of generated json for AIT
  * Fix incompatible pointer types in some OMPIF primitives
  * Fix a crash when calling data copies API inside a nested task
  * Fix task definitions are not emitted to HLS when they are declared (but not defined) in a different file
  * Fix unknown pointer conversion in function calls inside a task
  * Fix copies being emitted in a random order each compilation
  * Fix ignored point dependencies containing array references being ignored
  * Fix task definitions not being emitted if were declared in a different file
* xtasks
  * Version 17.10
  * Added function to retrieve available board memory from bitinfo
  * Added scripts to read pom registers
  * Add parameter to diable event invalidation on QDMA backend
  * Fixed wrong environment variable on error message
  * Updated read_bitinfo text
* xdma
  * Version 4.10
  * Added functions to set the available board memory for discrete devices
* ovni
  * Updated to upstream version 1.12.0
* IPs
  * Picos OmpSs Manager
    * Version 7.5
    * Fix task affinity not being honored
  * Task spawner
    * Version 2.2
    * Added support for IMP
    * Fix send/receive task affinity not being properly set
  * Instrumentation adapter
    * Version 2.1
    * Changed layout of event struct
    * Make num_events bits configurable
  * OMPIF - Message receiver
    * Version 1.3
  * OMPIF - Message sender
    * Version 1.3
  * OMPIF - Packet decoder
    * Version 1.1

# Release 3.2.0

2024-11-25

* OmpSs-2@FPGA
  * Added support for OMPIF inter-FPGA communication
* ait
  * Version 7.7.2
  * Added support for ethernet subsystem and OMPIF accelerators
  * Refactored clocks and resets
  * Fixed issue adding register slices on instrumentation ports
  * Fixed issue trying to simplify memory interconnection on HBM-based boards
  * Added workaround to avoid a bug with Vivado IPCACHE
* nanos6
  * Added OMPIF API functions
  * Added `--enable-distributed` configuration flag to enable support for OMPIF API
* llvm
  * Added support for nanos6 OMPIF API
* xtasks
  * Version 17.5
  * Added support for multi-node execution
* xdma
  * Version 4.9
  * Added support for multi-node execution
* ovni
  * Fixed passing xtasks config file to ovniemu

# Release 3.1.1

2024-07-31

* ait
  * Version 7.5.5
  * Fixed dangling instrumentation ports
  * Minor fixes on constraints files
* ovni
  * Updated to upstream version 1.10.0

# Release 3.1.0

2024-07-24

* OmpSs-2@FPGA
  * Added support for arm32 architecture
  * Added support for intra-FPGA instrumentation based in ovni
* ait
  * Version 7.5.1
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
  * Added `dump_board_info` argument to dump board info JSON
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
