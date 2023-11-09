.PHONY: design-p design-i design-d bitstream boot clean
all: help

PROGRAM_     = dotproduct

help:
	@echo 'Supported targets:           $(PROGRAM_)-p, $(PROGRAM_)-i, $(PROGRAM_)-d, $(PROGRAM_)-seq, design-p, design-i, design-d, bitstream-p, bitstream-i, bitstream-d, clean, help'
	@echo 'FPGA env. variables:         BOARD, FPGA_CLOCK, FPGA_MEMORY_PORT_WIDTH, MEMORY_INTERLEAVING_STRIDE, SIMPLIFY_INTERCONNECTION, INTERCONNECT_OPT, INTERCONNECT_REGSLICE, FLOORPLANNING_CONSTR, SLR_SLICES, PLACEMENT_FILE'
	@echo 'Compiler env. variables:     CFLAGS, CROSS_COMPILE, LDFLAGS'
	@echo 'Supported targets:      bitstream, design-p, design-i, design-d, boot, build, clean, $(PROGRAM_)-d, $(PROGRAM_)-i, $(PROGRAM_)-p, help'

CLANG_TARGET =
ifdef CROSS_COMPILE
    CLANG_TARGET += -target $(CROSS_COMPILE)
endif

COMPILER_         = clang
COMPILER_FLAGS_   = $(CFLAGS) $(CLANG_TARGET) -fompss-2 -fompss-fpga-wrapper-code
COMPILER_FLAGS_D_ = -g -fompss-fpga-hls-tasks-dir $(PWD)
LINKER_FLAGS_     = $(LDFLAGS)

# FPGA bitstream parameters
FPGA_CLOCK     ?= 100

AIT_FLAGS__        = --name=$(PROGRAM_) --board=$(BOARD) -c=$(FPGA_CLOCK)
AIT_FLAGS_DESIGN__ = --to_step=design
AIT_FLAGS_BOOT__   = --from_step=boot --to_step=boot -v -i
AIT_FLAGS_D__      = --debug_intfs=both -k -i -v

# Optional optimization FPGA variables
ifdef FPGA_MEMORY_PORT_WIDTH
	COMPILER_FLAGS_ += -fompss-fpga-memory-port-width $(FPGA_MEMORY_PORT_WIDTH)
endif
ifdef MEMORY_INTERLEAVING_STRIDE
	AIT_FLAGS__ += --memory_interleaving_stride=$(MEMORY_INTERLEAVING_STRIDE)
endif
ifdef SIMPLIFY_INTERCONNECTION
	AIT_FLAGS__ += --simplify_interconnection
endif
ifdef INTERCONNECT_PRIORITIES
	AIT_FLAGS__ += --interconnect_priorities
endif
ifdef INTERCONNECT_OPT
	AIT_FLAGS__ += --interconnect_opt=$(INTERCONNECT_OPT)
endif
ifdef INTERCONNECT_REGSLICE
	AIT_FLAGS__ += --interconnect_regslice=$(INTERCONNECT_REGSLICE)
endif
ifdef FLOORPLANNING_CONSTR
	AIT_FLAGS__ += --floorplanning_constr=$(FLOORPLANNING_CONSTR)
endif
ifdef SLR_SLICES
	AIT_FLAGS__ += --slr_slices=$(SLR_SLICES)
endif
ifdef PLACEMENT_FILE
	AIT_FLAGS__ += --placement_file=$(PLACEMENT_FILE)
endif
ifdef DISABLE_UTILIZATION_CHECK
	AIT_FLAGS__ += --disable_utilization_check
endif

AIT_FLAGS_        = -fompss-fpga-ait-flags "$(AIT_FLAGS__)"
AIT_FLAGS_DESIGN_ = -fompss-fpga-ait-flags "$(AIT_FLAGS_DESIGN__)"
AIT_FLAGS_BOOT_   = -fompss-fpga-ait-flags "$(AIT_FLAGS_BOOT__)"
AIT_FLAGS_D_      = -fompss-fpga-ait-flags "$(AIT_FLAGS_D__)"

PROGRAM_SRC = \
    src/dotproduct.c

$(PROGRAM_)-p: $(PROGRAM_SRC)
	$(COMPILER_) $(COMPILER_FLAGS_) $^ -o $@ $(LINKER_FLAGS_)

$(PROGRAM_)-i: $(PROGRAM_SRC)
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_I_) $^ -o $@ $(LINKER_FLAGS_)

$(PROGRAM_)-d: $(PROGRAM_SRC)
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_D_) $^ -o $@ $(LINKER_FLAGS_)

$(PROGRAM_)-seq: $(PROGRAM_SRC)
	$(COMPILER_) $(COMPILER_FLAGS_) $^ -o $@ $(LINKER_FLAGS_)

design-p: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) \
		$(AIT_FLAGS_) $(AIT_FLAGS_DESIGN_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

design-i: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_I_) \
		$(AIT_FLAGS_) $(AIT_FLAGS_DESIGN_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

design-d: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_D_) \
		$(AIT_FLAGS_) $(AIT_FLAGS_DESIGN_) $(AIT_FLAGS_D_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

bitstream-p: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) \
		$(AIT_FLAGS_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

bitstream-i: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_I_) \
		$(AIT_FLAGS_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

bitstream-d: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) $(COMPILER_FLAGS_D_) \
		$(AIT_FLAGS_) $(AIT_FLAGS_D_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

boot: $(PROGRAM_SRC)
	$(eval TMPFILE := $(shell mktemp))
	$(COMPILER_) $(COMPILER_FLAGS_) \
		$(AIT_FLAGS_) $(AIT_FLAGS_BOOT_) \
		$^ -o $(TMPFILE) $(LINKER_FLAGS_)
	rm $(TMPFILE)

clean:
	rm -fv *.o $(PROGRAM_)-? $(PROGRAM_)_hls_automatic_clang.cpp ait_extracted.json
	rm -frv $(PROGRAM_)_ait
