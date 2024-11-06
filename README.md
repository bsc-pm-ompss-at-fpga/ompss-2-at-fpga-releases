# OmpSs-2@FPGA releases

This meta-repository contains the official OmpSs-2@FPGA releases.

This repository uses submodules to link against the different OmpSs-2@FPGA tools. To download all the submodules when cloning this repository, you might use:

* When cloning from GitHub:
```bash
    git clone --recursive https://github.com/bsc-pm-ompss-at-fpga/ompss-2-at-fpga-releases.git
```

* When cloning from our internal GitLab repository (BSC users only):
```bash
    git clone --recursive https://gitlab.bsc.es/ompss-at-fpga/ompss-2-at-fpga-releases.git
```

To obtain further information about each tool, visit the README of each tool.
For general information, visit the [OmpSs-2@FPGA User Guide](https://pm.bsc.es/ftp/ompss-2-at-fpga/doc/user-guide-3.2.0-rc1/index.html#ompss-2-fpga-user-guide).


### Build docker image

To build the docker image, you just need to recursively clone and the repository and recursively checkout the desired version.
After that, you might run the following docker command in the root repository directory (to create the `ompss_2_at_fpga` docker image with the `unknwn` tag):
```bash
docker build --squash -t "ompss_2_at_fpga:unknwn" --force-rm .
```

NOTES:
 - The `--squash` option creates a final image without the intermediate build layers. This creates a smaller but less modular image.
   This option requires the `--experimental` option in the docker daemon, see [docker build Reference Manual](https://docs.docker.com/engine/reference/commandline/build/#squash-an-images-layers---squash-experimental).
 - The `--force-rm` option removes the intermediate layers after build.
