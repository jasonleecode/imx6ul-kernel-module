# imx6ul-kernel-module

这是一个基于 NXP/Freescale i.MX6UL 平台的核心板资料仓库，包含硬件原理图、PCB 源文件、关键器件数据手册、Linux 内核源码、BusyBox 源码包和交叉编译工具链。当前资料更偏向归档和二次开发参考，不是一个完整的一键构建 BSP。

## 仓库内容

```text
.
├── hardware/
│   ├── datasheet/        # 关键器件数据手册
│   ├── 原理图/            # PDF 原理图
│   └── 源文件/            # Altium Designer 原理图/PCB 源文件
├── sourcecode/
│   ├── busybox/          # BusyBox 1.20.2 源码包
│   ├── kernel/           # Linux 3.14.38 内核源码
│   └── README.md         # 源码构建说明
├── tools/
│   ├── gcc-4.6.2-glibc-2.13-linaro-multilib/
│   │   └── fsl-linaro-toolchain/  # arm-fsl-linux-gnueabi 交叉工具链
│   └── scripts/          # 辅助脚本
└── LICENSE
```

## 硬件资料

硬件设计文件位于 `hardware/`：

- `hardware/原理图/FETIMX6UL.pdf`：i.MX6UL 核心板/开发板原理图，包含框图、电源树、CPU 电源、DDR3/LvDDR3、eMMC/NAND/TF/QSPI、外设、启动配置、SO-DIMM 和 IOMUX 等页面。
- `hardware/原理图/pdf原理图.PDF`：扩展/演示板相关原理图。
- `hardware/源文件/*.SchDoc`、`hardware/源文件/*.PcbDoc`：Altium Designer 工程源文件。
- `hardware/datasheet/KSZ8081MNX_RNB.pdf`：Micrel/Microchip KSZ8081 以太网 PHY 数据手册。
- `hardware/datasheet/RX8010SJ_RTC芯片_en.pdf`：RX8010SJ RTC 数据手册。

从现有原理图和内核配置可确认的主要资源：

- SoC：i.MX6UL。
- 内存：DDR3/LvDDR3 设计。
- 存储接口：eMMC、NAND、TF/MicroSD、QSPI 相关设计。
- 网络：ENET1/ENET2 信号，KSZ8081 100M Ethernet PHY。
- USB：USB OTG、USB Host 相关设计。
- 显示：RGB LCD，原理图框图中包含 4.3 inch TFT 480x272 示例。
- 调试/外设：UART、JTAG、CAN、I2C、SPI、GPIO、RTC 等。

## 软件资料

软件相关内容位于 `sourcecode/`：

- `sourcecode/kernel/linux-3.14.38/`：Linux 3.14.38 内核源码。
- `sourcecode/kernel/linux-3.14.38/linux_imx6ul_config`：本仓库提供的 i.MX6UL 内核配置。
- `sourcecode/busybox/busybox-1.20.2.tar.gz`：BusyBox 1.20.2 源码包。

当前仓库没有提供完整的 U-Boot 源码、根文件系统工程或烧录脚本；相关内容需要根据实际板卡启动介质和部署方式补充。

## 构建环境

建议使用 Linux 主机。内核构建和 `menuconfig` 至少需要：

```bash
sudo apt-get install lzop libncurses-dev
```

仓库已包含交叉编译工具链：

```text
tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi-
```

可以按需加入 `PATH`：

```bash
export PATH="$PWD/tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin:$PATH"
```

推荐使用仓库内的 Docker 环境构建，避免宿主机缺少 32 位运行库或 GCC 版本过新导致 Linux 3.14 编译失败：

```bash
./docker/build-image.sh
./docker/compile-kernel.sh
```

Docker 构建环境说明见 [docker/README.md](docker/README.md)。编译输出会写入 `build/kernel-imx6ul/`。

## 编译 Linux 内核

```bash
cd sourcecode/kernel/linux-3.14.38
make distclean
cp linux_imx6ul_config .config
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- oldconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- zImage modules dtbs -j"$(nproc)"
```

编译产物通常位于：

```text
sourcecode/kernel/linux-3.14.38/arch/arm/boot/zImage
sourcecode/kernel/linux-3.14.38/arch/arm/boot/dts/*.dtb
```

如需安装内核模块到临时 rootfs：

```bash
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- INSTALL_MOD_PATH=/tmp/imx6ul-rootfs modules_install
```

当前内核配置的 `CONFIG_LOCALVERSION` 为 `-6UL_ga`，默认命令行基线包含 `console=ttymxc0,115200`。实际启动参数仍建议由 U-Boot 环境变量提供。

## 设备树

内核源码中包含多份 i.MX6UL 参考 DTS，例如：

```text
arch/arm/boot/dts/imx6ul-14x14-ddr3-arm2.dts
arch/arm/boot/dts/imx6ul-14x14-ddr3-arm2-emmc.dts
arch/arm/boot/dts/imx6ul-14x14-ddr3-arm2-lcdif.dts
arch/arm/boot/dts/imx6ul-14x14-evk.dts
arch/arm/boot/dts/imx6ul-9x9-evk.dts
```

这些文件可作为移植参考，但仓库当前没有按本核心板单独命名的 DTS。适配实际硬件时，建议基于原理图核对以下内容后再派生板级 DTS：

- DDR 类型和容量。
- 启动介质：eMMC、NAND、TF/MicroSD 或 QSPI。
- ENET PHY 地址、复位脚、中断脚和参考时钟。
- UART 控制台端口。
- LCD 分辨率、时序和背光控制。
- RTC、触摸、CAN、USB ID/VBUS、GPIO 扩展等外设连接。

具体镜像格式、设备树选择、启动参数和烧录方式取决于实际 U-Boot/启动介质配置，本仓库当前未固化这些流程。

## BusyBox

BusyBox 源码包位于：

```text
sourcecode/busybox/busybox-1.20.2.tar.gz
```

可用于制作基础 rootfs。一个最小的交叉编译流程如下：

```bash
cd sourcecode/busybox
tar xf busybox-1.20.2.tar.gz
cd busybox-1.20.2
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- defconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- menuconfig
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- -j"$(nproc)"
make ARCH=arm CROSS_COMPILE=../../../tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi- CONFIG_PREFIX=/tmp/imx6ul-rootfs install
```

常见 rootfs 还需要补充：

- `/etc/inittab`、`/etc/init.d/rcS` 等启动脚本。
- `/dev`、`/proc`、`/sys`、`/tmp`、`/run` 等目录。
- C 库运行时文件，需与当前交叉工具链匹配。
- 网络、挂载、串口登录和应用程序配置。

当前仓库未提供 rootfs 配置、init 脚本、打包脚本或文件系统镜像。

## 资料使用建议

1. 先阅读 `hardware/原理图/FETIMX6UL.pdf`，确认板卡接口、电源和启动配置。
2. 使用 `linux_imx6ul_config` 构建内核，作为驱动和板级配置的基线。
3. 根据实际启动介质补充 U-Boot、设备树、rootfs 和烧录流程。
4. 修改硬件设计时优先使用 `hardware/源文件/` 中的 Altium 源文件，并同步导出 PDF 原理图。

## 许可证

本仓库根目录包含 `LICENSE` 文件。第三方源码、工具链和数据手册可能带有各自的许可条款，使用和分发前请分别确认。
