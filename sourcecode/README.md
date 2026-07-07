# Source Code

本目录保存 i.MX6UL 相关源码和源码包：

- `kernel/linux-3.14.38/`：Linux 3.14.38 内核源码。
- `kernel/linux-3.14.38/linux_imx6ul_config`：仓库提供的 i.MX6UL 内核配置。
- `busybox/busybox-1.20.2.tar.gz`：BusyBox 1.20.2 源码包，可用于制作基础 rootfs。

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
cd busybox
tar xf busybox-1.20.2.tar.gz
cd busybox-1.20.2
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- defconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- menuconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- -j"$(nproc)"
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- CONFIG_PREFIX=/tmp/imx6ul-rootfs install
```

## 未包含内容

当前仓库未包含完整 U-Boot 源码、rootfs 工程、文件系统镜像或烧录脚本。实际启动和部署流程需要结合板卡启动介质、U-Boot 环境变量和目标文件系统补充。
