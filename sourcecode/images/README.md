# Images

This directory contains packaging helpers. Generated files are written to `build/images/`.

Collect boot files from the kernel build:

```bash
./sourcecode/images/scripts/collect-boot-files.sh
```

Package the rootfs:

```bash
./sourcecode/images/scripts/package-rootfs.sh
```

Defaults:

- Kernel build directory: `build/kernel-imx6ul/`
- Rootfs directory: `build/rootfs/`
- Default DTB: `imx6ul-14x14-evk.dtb`
- Rootfs image size: 128 MiB

Override examples:

```bash
DTB_NAME=imx6ul-14x14-ddr3-arm2-emmc.dtb ./sourcecode/images/scripts/collect-boot-files.sh
IMAGE_SIZE_MB=256 ./sourcecode/images/scripts/package-rootfs.sh
```
