SHELL := /bin/bash

ifndef BUILDCPUS
	BUILDCPUS := $(shell nproc)
endif

ifndef TARGET
	TARGET := $(gcc -dumpmachine)
endif

ifndef PLATFORM
	PLATFORM := zynq
endif

ifndef XDMA_PLATFORM
	XDMA_PLATFORM := $(PLATFORM)
endif

ifndef XTASKS_PLATFORM
	XTASKS_PLATFORM := $(PLATFORM)
endif

ifndef ENVSCRIPT_NAME
	ENVSCRIPT_NAME := environment_ompss_2_fpga.sh
endif

export CROSS_COMPILE := $(TARGET)-

all: xdma-install xtasks-install nanos6-install llvm-install ait-install envscript-install

.PHONY: xdma xdma-install xtasks xtasks-install

xdma:
	$(MAKE) -j$(BUILDCPUS) -C xdma/src/$(XDMA_PLATFORM) KERNEL_MODULE_DIR=$(PWD)/ompss-at-fpga-kernel-module

xdma-install: xdma
	$(MAKE) -j$(BUILDCPUS) -C xdma/src/$(XDMA_PLATFORM) install PREFIX=$(PREFIX_TARGET)/libxdma

xtasks: xdma-install
	$(MAKE) -j$(BUILDCPUS) -C xtasks/src/$(XTASKS_PLATFORM) LIBXDMA_DIR=$(PREFIX_TARGET)/libxdma

xtasks-install: xtasks
	$(MAKE) -j$(BUILDCPUS) -C xtasks/src/$(XTASKS_PLATFORM) install PREFIX=$(PREFIX_TARGET)/libxtasks
	pushd $(PREFIX_TARGET)/libxtasks/lib; \
		ln -s libxtasks-hwruntime.so libxtasks.so; popd;

.PHONY: nanos6-bootstrap nanos6-config llvm-config nanos6-build nanos6-install

nanos6-bootstrap:
	cd nanos6-fpga; 	\
	./autogen.sh

nanos6-config-force: nanos6-bootstrap
	mkdir -p nanos6-build;	\
	cd nanos6-build;	\
	../nanos6-fpga/configure --prefix=$(PREFIX_TARGET)/nanos6 \
		--host=$(TARGET) \
		--enable-fpga --with-xtasks=$(PREFIX_TARGET)/libxtasks \
		--with-symbol-resolution=indirect \
		--disable-all-instrumentations --disable-discrete-deps \
		$(NANOS6_CONFIG_FLAGS)

nanos6-config: xtasks-install
	if [ ! -r nanos6-build/config.status ]; \
	then	\
		$(MAKE) nanos6-config-force; \
	fi

nanos6-build: nanos6-config
	$(MAKE) -j$(BUILDCPUS) -C nanos6-build

nanos6-install: nanos6-build
	$(MAKE) -j$(BUILDCPUS) -C nanos6-build install

.PHONY: llvm-config llvm-build llvm-install

llvm-config: nanos6-install
	mkdir -p llvm-build; \
	cd llvm-build; \
	cmake -G Ninja \
	  -DCMAKE_INSTALL_PREFIX=$(PREFIX_HOST)/llvm \
	  -DLLVM_TARGETS_TO_BUILD="X86;AArch64;ARM" \
	  -DCMAKE_BUILD_TYPE=Release \
	  -DCLANG_DEFAULT_NANOS6_HOME=$(PREFIX_TARGET)/nanos6 \
	  -DLLVM_USE_SPLIT_DWARF=ON \
	  -DLLVM_ENABLE_PROJECTS="clang" \
	  -DLLVM_INSTALL_TOOLCHAIN_ONLY=ON \
	  -DCMAKE_C_COMPILER=clang \
	  -DCMAKE_CXX_COMPILER=clang++ \
	  -DLLVM_USE_LINKER=lld \
	../llvm/llvm

llvm-build: llvm-config
	ninja -j$(BUILDCPUS) -C llvm-build

llvm-install: llvm-build
	ninja -j$(BUILDCPUS) install -C llvm-build

.PHONY: ait-install

ait-install:
	export DEB_PYTHON_INSTALL_LAYOUT=deb_system; \
	rm -rf $(PREFIX_HOST)/ait; \
	python3 -m pip install ./ait -t $(PREFIX_HOST)/ait

.PHONY: environment_ompss_2_fpga.sh envscript-install

environment_ompss_2_fpga.sh: ait-install llvm-install
	@echo "#!/bin/bash" >environment_ompss_2_fpga.sh
	@echo 'export PATH='$(PREFIX_HOST)'/llvm/bin:$$PATH' >>environment_ompss_2_fpga.sh
	@echo 'export PATH='$(PREFIX_HOST)'/ait/bin:$$PATH' >>environment_ompss_2_fpga.sh
	@echo 'export PYTHONPATH='$(PREFIX_HOST)'/ait' >>environment_ompss_2_fpga.sh

envscript-install: environment_ompss_2_fpga.sh
	cp -v $^ $(PREFIX_HOST)/$(ENVSCRIPT_NAME)

.PHONY: clean mrproper

clean:
	if [ -d llvm-build ]; then rm llvm-build/CMakeCache.txt; fi
	if [ -d nanos6-build ]; then $(MAKE) -C nanos6-build clean; fi
	$(MAKE) -C xdma/src/$(PLATFORM) clean
	$(MAKE) -C xtasks/src/$(PLATFORM) clean
	rm -f environment_ompss_2_fpga.sh 2>/dev/null

mrproper: clean
	rm -rf llvm-build 2>/dev/null
	rm -rf nanos6-build 2>/dev/null

.PHONY: help

help:
	@echo "Environment variables:"
	@echo "  TARGET               Linux architecture that toolchain will target [def: native]"
	@echo "  PLATFORM             Fallback board platform that xtasks and xdma backends will target if no specific one has been defined (e.g. zynq, qdma) [def: zynq]"
	@echo "  XDMA_PLATFORM        Board platform that xdma backend will target (e.g. zynq, qdma, euroexa_maxilink) [def: PLATFORM]"
	@echo "  XTASKS_PLATFORM      Board platform that xtasks backend will target (e.g. zynq, qdma) [def: PLATFORM]"
	@echo "  PREFIX_HOST          Installation prefix for the host tools (e.g. llvm, ait) [def: /]"
	@echo "  PREFIX_TARGET        Installation prefix for the target tools (e.g. nanos6, libxdma) [def: /]"
	@echo "  BUILDCPUS            Number of processes used for building [def: nproc]"
	@echo "  ENVSCRIPT_NAME       Environment script name within PREFIX_HOST [def: environment_ompss_2_fpga.sh]"
	@echo "Targets:"
	@echo "  xdma                  Build xdma library"
	@echo "  xdma-install          Install xdma library"
	@echo "  xtasks                Build xtasks library"
	@echo "  xtasks-install        Install xtasks library"
	@echo "  nanos6-bootstrap      Nanos6 configuration bootstrap"
	@echo "  nanos6-config         Nanos6 configuration"
	@echo "  nanos6-config-force   Force Nanos6 configuration"
	@echo "  nanos6-build          Build Nanos6"
	@echo "  nanos6-install        Install Nanos6"
	@echo "  llvm-config           LLVM configuration"
	@echo "  llvm-build            Build LLVM"
	@echo "  llvm-install          Install LLVM"
	@echo "  envscript-install     Install environment script"
