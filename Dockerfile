ARG DEBIAN_FRONTEND="noninteractive"
ARG INSTALLATION_PREFIX=/opt/bsc
ARG RELEASE_TAG

FROM ubuntu:22.04 AS base
ARG INSTALLATION_PREFIX
ARG RELEASE_TAG
LABEL AUTHOR="Programming Models Group at BSC <ompss-fpga-support@bsc.es> (https://pm.bsc.es/ompss-at-fpga)"
RUN apt-get update && apt-get install -y \
# llvm
        cmake \
        clang-12 \
        clang++-12 \
        lld-12 \
        ninja-build \
# Common
        autoconf \
        automake \
        build-essential \
        ca-certificates \
        curl \
        gfortran \
        gperf \
        git \
        libboost-all-dev \
        libiberty-dev \
        libltdl-dev \
        libsqlite3-dev \
        libtool \
        pkg-config \
        sudo \
        vim \
        wget \
# AIT
        python3 \
        python3-pip \
# Needed by Xilinx tools
        libgtk2.0-0 \
        libncurses5 \
        libx11-6 \
        libxext6 \
        libxrender1 \
        libxtst6 \
        procps \
# Needed by Petalinux tools
        bc \
        chrpath \
        cpio \
        diffstat \
        gawk \
        gnupg \
        gnupg-agent \
        libncurses5-dev \
        libtool-bin \
        locales \
        lsb-release \
        net-tools \
        rsync \
        socat \
        texinfo \
        unzip \
        xterm \
        zlib1g-dev \
# Extra tools
        openssh-client

RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-12 80 \
 && update-alternatives --install /usr/bin/clang clang /usr/bin/clang-12 80  \
 && update-alternatives --install /usr/bin/lld lld /usr/bin/lld-12 80 \
 && python3 -m pip install pip --upgrade \
 && python3 -m pip install wheel --upgrade \
 && python3 -m pip install setuptools --upgrade \
 && export DEBIAN_FRONTEND=noninteractive \
 && export DEBCONF_NONINTERACTIVE_SEEN=true \
 && echo 'tzdata tzdata/Areas select Etc' | debconf-set-selections \
 && echo 'tzdata tzdata/Zones/Etc select UTC' | debconf-set-selections \
 && apt-get install --no-install-recommends tzdata

#if is arm64
RUN if [ \"`arch`\" = \"aarch64\" ] || [ \"`arch`\" = \"arm64\" ] ; then \
        dpkg --add-architecture amd64 && apt-get update && apt-get install -y\
        crossbuild-essential-amd64 \
        gfortran-x86-64-linux-gnu \
        g++-multilib-x86-64-linux-gnu \
        gcc-multilib-x86-64-linux-gnu ; \
    elif [ \"`arch`\" = \"x86_64\" ]; then \
        apt-get install -y \
        crossbuild-essential-arm64 \
        gfortran-aarch64-linux-gnu; \
    else \
        false; \
    fi;

#arm32
#RUN apt-get update \
# && apt-get install -y -q \
#     crossbuild-essential-armhf \
#     gfortran-arm-linux-gnueabihf

RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

FROM base as build
ARG INSTALLATION_PREFIX
ARG RELEASE_TAG

## Install dependencies

#LIBNUMA
WORKDIR /tmp/work/

RUN wget https://github.com/numactl/numactl/releases/download/v2.0.16/numactl-2.0.16.tar.gz \
 && tar -zxf numactl-2.0.16.tar.gz \
 && rm numactl-2.0.16.tar.gz

WORKDIR /tmp/work/numactl-2.0.16

RUN autoreconf -ifv

#ARM64
RUN ./configure --prefix=$INSTALLATION_PREFIX/arm64/libnuma --host=aarch64-linux-gnu \
 && make install \
 && make distclean

#ARM32
#RUN ./configure --prefix=$INSTALLATION_PREFIX/arm32/libnuma --host=arm-linux-gnueabihf \
# && make install \
# && make distclean

#X86_64
RUN ./configure --prefix=$INSTALLATION_PREFIX/x86_64/libnuma --host=x86_64-linux-gnu \
 && make install \
 && make distclean


#HWLOC
WORKDIR /tmp/work/

RUN wget https://download.open-mpi.org/release/hwloc/v2.9/hwloc-2.9.3.tar.gz \
 && tar -zxf hwloc-2.9.3.tar.gz \
 && rm hwloc-2.9.3.tar.gz

WORKDIR /tmp/work/hwloc-2.9.3

RUN autoreconf -ifv

#ARM64
RUN ./configure --prefix=$INSTALLATION_PREFIX/arm64/hwloc --host=aarch64-linux-gnu \
 && make install \
 && make distclean

#ARM32
#RUN ./configure --prefix=$INSTALLATION_PREFIX/arm32/hwloc --host=arm-linux-gnueabihf \
# && make install \
# && make distclean

#X86_64
RUN ./configure --prefix=$INSTALLATION_PREFIX/x86_64/hwloc --host=x86_64-linux-gnu \
 && make install \
 && make distclean


##PARAVER
##ONLY COMPILE FOR LOCAL MACHINE
#
#WORKDIR /tmp/work/
#
#RUN git clone https://github.com/bsc-performance-tools/paraver-kernel
#
#WORKDIR /tmp/work/paraver-kernel
#RUN ./bootstrap \
# && ./configure --with-boost-libdir=/usr/lib/$(gcc -dumpmachine) --prefix=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/paraver \
# && make -j`nproc` \
# && make install
#
#WORKDIR /tmp/work
#RUN apt-get install -y libwxgtk3.0-gtk3-dev libssl-dev
#RUN git clone https://github.com/bsc-performance-tools/wxparaver
#
#WORKDIR /tmp/work/wxparaver
#RUN ./bootstrap \
# && ./configure --with-boost-libdir=/usr/lib/$(gcc -dumpmachine) --prefix=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/paraver \
# && make -j`nproc` \
# && make install


WORKDIR /tmp/work/
ADD Makefile ./
ADD ait ./ait
ADD llvm ./llvm
ADD nanos6-fpga ./nanos6-fpga
ADD ompss-at-fpga-kernel-module ./ompss-at-fpga-kernel-module
ADD xdma ./xdma
ADD xtasks ./xtasks


ENV CFLAGS=
ENV CXXFLAGS=
ENV LDFLAGS=

#INSTALL TOOLCHAIN
WORKDIR /tmp/work

#X86_64
RUN make \
    TARGET=$(test $(arch) != x86_64 && echo x86_64-linux-gnu) \
    PREFIX_TARGET=$INSTALLATION_PREFIX/x86_64/ompss-2/${RELEASE_TAG} \
    PREFIX_HOST=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG} \
    PLATFORM=qdma \
    all \
 && make mrproper

#ARM64
RUN make \
    TARGET=$(test $(arch) != aarch64 && echo aarch64-linux-gnu) \
    PREFIX_TARGET=$INSTALLATION_PREFIX/arm64/ompss-2/${RELEASE_TAG} \
    PREFIX_HOST=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG} \
    NANOS6_CONFIG_FLAGS="--with-libnuma=$INSTALLATION_PREFIX/arm64/libnuma --with-symbol-resolution=indirect" \
    hwloc_CFLAGS="-I$INSTALLATION_PREFIX/arm64/hwloc/include" \
    hwloc_LIBS="-L$INSTALLATION_PREFIX/arm64/hwloc/lib -lhwloc" \
    PLATFORM=zynq \
    all \
 && make mrproper

##ARM32
##Assuming no one will compile from an arm32 platform => always setting TARGET
#RUN make \
#    TARGET=arm-linux-gnueabihf \
#    PREFIX_TARGET=$INSTALLATION_PREFIX/arm32/ompss-2/${RELEASE_TAG} \
#    PREFIX_HOST=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG} \
#    NANOS6_CONFIG_FLAGS="--with-libnuma=$INSTALLATION_PREFIX/arm32/libnuma --with-symbol-resolution=indirect" \
#    hwloc_CFLAGS="-I$INSTALLATION_PREFIX/arm32/hwloc/include" \
#    hwloc_LIBS="-L$INSTALLATION_PREFIX/arm32/hwloc/lib -lhwloc" \
#    PLATFORM=zynq \
#    all \
# && make mrproper

FROM build AS dist_img
ARG INSTALLATION_PREFIX
ARG RELEASE_TAG

ARG INSTALLATION_PREFIX
COPY --from=build $INSTALLATION_PREFIX $INSTALLATION_PREFIX
LABEL AUTHOR="Programming Models Group at BSC <ompss-fpga-support@bsc.es> (https://pm.bsc.es/ompss-at-fpga)"

RUN adduser --disabled-password --gecos '' ompss \
 && adduser ompss sudo \
 && echo 'ompss:ompss' | chpasswd

ADD ./dockerImageFiles/welcome_ompss_fpga.txt $INSTALLATION_PREFIX
WORKDIR /home/ompss/
USER ompss
ADD --chmod=0775 --chown=ompss:ompss ./dockerImageFiles/example ./example/

RUN echo "cat $INSTALLATION_PREFIX/welcome_ompss_fpga.txt" >>.bashrc \
 && echo "export PATH=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG}/llvm/bin:\$PATH" >>.bashrc \
 && echo "export PATH=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG}/ait/bin:\$PATH" >>.bashrc \
 && echo "export PYTHONPATH=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss-2/${RELEASE_TAG}/ait" >>.bashrc
# && echo "export PATH=$INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/wxparaver/bin:\$PATH" >>.bashrc \
# && ln -s $INSTALLATION_PREFIX/$(arch | sed 's/aarch64/arm64/g' | sed 's/armhf/arm32/g')/ompss/${RELEASE_TAG}/nanos6-fpga/share/doc/nanox/paraver_configs/ompss ./example/paraver_configs

CMD ["bash"]
