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

ifndef MCXX_NAME
	MCXX_NAME := mcxx
endif

ifndef ENVSCRIPT_NAME
	ENVSCRIPT_NAME := environment_ompss_2_fpga.sh
endif

export CROSS_COMPILE := $(TARGET)-

all: xdma-install xtasks-install nanos6-install mcxx-install ait-install envscript-install

.PHONY: xdma xdma-install xtasks xtasks-install

xdma:
	$(MAKE) -C xdma/src/$(XDMA_PLATFORM) KERNEL_MODULE_DIR=$(PWD)/ompss-at-fpga-kernel-module

xdma-install: xdma
	$(MAKE) -C xdma/src/$(XDMA_PLATFORM) install PREFIX=$(PREFIX_TARGET)/libxdma

xtasks: xdma-install
	$(MAKE) -C xtasks/src/$(XTASKS_PLATFORM) LIBXDMA_DIR=$(PREFIX_TARGET)/libxdma

xtasks-install: xtasks
	$(MAKE) -C xtasks/src/$(XTASKS_PLATFORM) install PREFIX=$(PREFIX_TARGET)/libxtasks
	pushd $(PREFIX_TARGET)/libxtasks/lib; \
		ln -s libxtasks-hwruntime.so libxtasks.so; popd;

.PHONY: nanos6-bootstrap nanos6-config mcxx-config-force nanos6-build nanos6-install

nanos6-bootstrap:
	cd nanos6-fpga; 	\
	autoreconf -fiv

ifdef EXTRAE_HOME
WITH_EXTRAE := --with-extrae=$(EXTRAE_HOME)
endif

nanos6-config-force: nanos6-bootstrap
	mkdir -p nanos6-build;	\
	cd nanos6-build;	\
	../nanos6-fpga/configure --prefix=$(PREFIX_TARGET)/nanos6 \
		--host=$(TARGET) \
		--enable-fpga --with-xtasks=$(PREFIX_TARGET)/libxtasks \
		--with-symbol-resolution=indirect \
		$(WITH_EXTRAE) \
		--disable-all-instrumentations --disable-discrete-deps \
		$(NANOS6_CONFIG_FLAGS)

nanos6-config:
	if [ ! -r nanos6-build/config.status ]; \
	then	\
		$(MAKE) nanos6-config-force; \
	fi

nanos6-build: nanos6-config
	$(MAKE) -C nanos6-build -j$(BUILDCPUS)

nanos6-install: nanos6-build
	$(MAKE) -C nanos6-build install

.PHONY: mcxx-bootstrap mcxx-config mcxx-config-force mcxx-build mcxx-install

mcxx-bootstrap:
	cd mcxx && autoreconf -fiv

mcxx-config: nanos6-install
	if [ ! -r mcxx-build/config.status ]; \
	then	\
		$(MAKE) mcxx-config-force; \
	fi

mcxx-config-force: mcxx-bootstrap
	mkdir -p mcxx-build; \
	cd mcxx-build; \
	../mcxx/configure \
		--prefix=$(PREFIX_HOST)/$(MCXX_NAME) \
		--with-nanos6=$(PREFIX_TARGET)/nanos6 \
		--target=$(TARGET) \
		--enable-ompss-2 \
		--disable-vectorization \
		$(MCXX_CONFIG_FLAGS)

mcxx-build: mcxx-config
	$(MAKE) -C mcxx-build -j$(BUILDCPUS)

mcxx-install: mcxx-build
	$(MAKE) -C mcxx-build install

.PHONY: ait-install

ait-install:
	export DEB_PYTHON_INSTALL_LAYOUT=deb_system; \
	rm -rf $(PREFIX_HOST)/ait; \
	python3 -m pip install ./ait -t $(PREFIX_HOST)/ait

.PHONY: environment_ompss_2_fpga.sh envscript-install

environment_ompss_2_fpga.sh:
	@echo "#!/bin/bash" >environment_ompss_2_fpga.sh
	@echo 'export PATH=$$PATH:'$(PREFIX_HOST)'/'$(MCXX_NAME)'/bin' >>environment_ompss_2_fpga.sh
	@echo 'export PATH=$$PATH:'$(PREFIX_HOST)'/ait/bin' >>environment_ompss_2_fpga.sh
	@echo 'export PYTHONPATH='$(PREFIX_HOST)'/ait' >>environment_ompss_2_fpga.sh

envscript-install: environment_ompss_2_fpga.sh
	cp -v $^ $(PREFIX_HOST)/$(ENVSCRIPT_NAME)

.PHONY: clean mrproper

clean:
	if [ -d mcxx-build ]; then $(MAKE) -C mcxx-build clean; fi
	if [ -d nanos6-build ]; then $(MAKE) -C nanos6-build clean; fi
	$(MAKE) -C xdma/src/$(PLATFORM) clean
	$(MAKE) -C xtasks/src/$(PLATFORM) clean
	rm -f environment_ompss_2_fpga.sh 2>/dev/null

mrproper: clean
	rm -rf mcxx-build 2>/dev/null
	rm -rf nanos6-build 2>/dev/null

.PHONY: help

help:
	@echo "Environment variables:"
	@echo "  TARGET               Linux architecture that toolchain will target [def: native]"
	@echo "  PLATFORM             Fallback board platform that xtasks and xdma backends will target if no specific one has been defined (e.g. zynq, qdma) [def: zynq]"
	@echo "  XDMA_PLATFORM        Board platform that xdma backend will target (e.g. zynq, qdma, euroexa_maxilink) [def: PLATFORM]"
	@echo "  XTASKS_PLATFORM      Board platform that xtasks backend will target (e.g. zynq, qdma) [def: PLATFORM]"
	@echo "  PREFIX_HOST          Installation prefix for the host tools (e.g. mcxx, ait) [def: /]"
	@echo "  PREFIX_TARGET        Installation prefix for the target tools (e.g. nanos6, libxdma) [def: /]"
	@echo "  EXTRAE_HOME          Extrae installation path"
	@echo "  BUILDCPUS            Number of processes used for building [def: nproc]"
	@echo "  MCXX_NAME            Mercurium installation path within PREFIX_HOST [def: mcxx]"
	@echo "  ENVSCRIPT_NAME       Environment script name within PREFIX_HOST [def: environment_ompss_2_fpga.sh]"
	@echo "Targets:"
	@echo "  xdma                 Build xdma library"
	@echo "  xdma-install         Install xdma library"
	@echo "  xtasks               Build xtasks library"
	@echo "  xtasks-install       Install xtasks library"
	@echo "  nanos6-bootstrap      Nanos++ configuration bootstrap"
	@echo "  nanos6-config         Nanos++ configuration"
	@echo "  nanos6-config-force   Force Nanos++ configuration"
	@echo "  nanos6-build          Build Nanos++"
	@echo "  nanos6-install        Install Nanos++"
	@echo "  mcxx-bootstrap       Mercurium configuration bootstrap"
	@echo "  mcxx-config          Mercurium configuration"
	@echo "  mcxx-config-force    Force Mercurium configuration"
	@echo "  mcxx-build           Build Mercurium"
	@echo "  mcxx-install         Install Mercurium"
	@echo "  envscript-install    Install environment script"
