# Source Code

本目录保存 i.MX6UL 相关源码和源码包：

- `bootloader/`：U-Boot 接入说明、默认环境模板和预留源码目录。
- `kernel/linux-3.14.38/`：Linux 3.14.38 内核源码。
- `kernel/linux-3.14.38/linux_imx6ul_config`：仓库提供的 i.MX6UL 内核配置。
- `busybox/busybox-1.20.2.tar.gz`：BusyBox 1.20.2 源码包，可用于制作基础 rootfs。
- `rootfs/`：最小 BusyBox rootfs overlay 和构建脚本。
- `images/`：启动文件收集和 rootfs 打包脚本。
- `scripts/`：组合构建入口。

## 依赖

```bash
sudo apt-get install lzop libncurses-dev
```

## 编译内核

```bash
cd kernel/linux-3.14.38
make distclean
cp linux_imx6ul_config .config
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- oldconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- zImage modules dtbs -j"$(nproc)"
```

内核输出目录：

```text
kernel/linux-3.14.38/arch/arm/boot/zImage
kernel/linux-3.14.38/arch/arm/boot/dts/*.dtb
```

内核源码包含多份 i.MX6UL 参考设备树，例如 `imx6ul-14x14-evk.dts`、`imx6ul-14x14-ddr3-arm2.dts` 和 `imx6ul-9x9-evk.dts`。当前没有按本核心板单独命名的 DTS，实际使用前需要结合 `hardware/` 下的原理图核对并派生板级设备树。

## BusyBox

```bash
./sourcecode/scripts/build-rootfs-docker.sh
```

输出目录：

```text
build/rootfs/
```

## 打包

收集内核启动文件：

```bash
./sourcecode/images/scripts/collect-boot-files.sh
```

打包 rootfs：

```bash
./sourcecode/images/scripts/package-rootfs.sh
```

输出目录：

```text
build/images/
```

## 尚需板级确认

`bootloader/` 目录已经预留 U-Boot 接入位置，但仓库当前仍未包含厂商板级 U-Boot 源码。实际烧录前还需要结合启动介质、DDR 初始化、U-Boot 环境变量和目标板 DTS 做板级验证。
