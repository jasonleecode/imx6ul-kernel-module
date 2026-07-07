# Rootfs

This directory contains a minimal BusyBox rootfs project.

Build it inside the 32-bit Ubuntu 16.04 Docker environment:

```bash
./sourcecode/scripts/build-rootfs-docker.sh
```

The generated rootfs is written to:

```text
build/rootfs/
```

The build script installs:

- BusyBox from `sourcecode/busybox/busybox-1.20.2.tar.gz`.
- The overlay under `sourcecode/rootfs/overlay/`.
- Runtime glibc libraries from the bundled cross toolchain.
- Kernel modules from `build/kernel-imx6ul/` when that kernel build exists.

Package the result with:

```bash
./sourcecode/images/scripts/package-rootfs.sh
```
