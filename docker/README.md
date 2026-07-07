# Docker Build Environment

This directory provides a 32-bit Ubuntu 16.04 build environment for the bundled `arm-fsl-linux-gnueabi-` toolchain.

## Build Image

```bash
./docker/build-image.sh
```

## Compile Kernel

```bash
./docker/compile-kernel.sh
```

The kernel build output is written to:

```text
build/kernel-imx6ul/
```

Expected outputs include:

```text
build/kernel-imx6ul/arch/arm/boot/zImage
build/kernel-imx6ul/arch/arm/boot/dts/*.dtb
```

The build directory is ignored by git.

The script uses:

```text
sourcecode/kernel/linux-3.14.38/linux_imx6ul_config
tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi-
```

`compile-kernel.sh` runs `make mrproper` before the out-of-tree build because this Linux 3.14 tree refuses external builds when the source directory contains generated files. If `sourcecode/kernel/linux-3.14.38/.config` exists, the script backs it up and restores it when finished.
