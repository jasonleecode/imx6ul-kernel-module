#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPO_ROOT="$(cd "${SOURCE_DIR}/.." && pwd)"

KERNEL_BUILD_DIR="${KERNEL_BUILD_DIR:-${REPO_ROOT}/build/kernel-imx6ul}"
BOOTLOADER_BUILD_DIR="${BOOTLOADER_BUILD_DIR:-${SOURCE_DIR}/bootloader/u-boot}"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_ROOT}/build/images/boot}"
DTB_NAME="${DTB_NAME:-imx6ul-14x14-evk.dtb}"

ZIMAGE="${KERNEL_BUILD_DIR}/arch/arm/boot/zImage"
DTB="${KERNEL_BUILD_DIR}/arch/arm/boot/dts/${DTB_NAME}"

if [ ! -f "${ZIMAGE}" ]; then
    echo "Kernel zImage not found: ${ZIMAGE}" >&2
    echo "Build the kernel first with ./docker/compile-kernel.sh" >&2
    exit 1
fi

if [ ! -f "${DTB}" ]; then
    echo "DTB not found: ${DTB}" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"
cp "${ZIMAGE}" "${OUTPUT_DIR}/zImage"
cp "${DTB}" "${OUTPUT_DIR}/${DTB_NAME}"

for name in u-boot.imx SPL u-boot.img u-boot-dtb.img; do
    if [ -f "${BOOTLOADER_BUILD_DIR}/${name}" ]; then
        cp "${BOOTLOADER_BUILD_DIR}/${name}" "${OUTPUT_DIR}/"
    fi
done

echo "Boot files collected in ${OUTPUT_DIR}"
