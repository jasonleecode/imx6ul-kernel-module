# Bootloader

This directory is reserved for the board U-Boot project.

The repository currently does not contain the vendor board U-Boot source, SPL DDR initialization code, or a validated board defconfig. Do not reuse a random i.MX6UL EVK U-Boot binary without checking DDR, boot media, PMIC, Ethernet PHY reset, and storage layout against the schematics.

## Expected Layout

Put the board U-Boot source here when available:

```text
sourcecode/bootloader/u-boot/
```

Expected build outputs are usually one of:

```text
u-boot.imx
SPL
u-boot.img
u-boot-dtb.img
```

`sourcecode/images/scripts/collect-boot-files.sh` will copy these files if they exist.

## Environment Template

`env/imx6ul-default.env` records a conservative boot command template for SD/eMMC style boot. Treat it as a starting point, not a validated production environment.
