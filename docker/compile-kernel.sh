#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-imx6ul-kernel-module-build:ubuntu16-i386}"

docker run --rm \
  --platform linux/386 \
  -u "$(id -u):$(id -g)" \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  "${IMAGE_NAME}" \
  bash -lc '
set -euo pipefail

KERNEL_SRC=/work/sourcecode/kernel/linux-3.14.38
BUILD_DIR=/work/build/kernel-imx6ul
TOOLCHAIN=/work/tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain/bin/arm-fsl-linux-gnueabi-
SOURCE_CONFIG_BACKUP=

restore_source_config() {
  if [ -n "${SOURCE_CONFIG_BACKUP}" ] && [ -f "${SOURCE_CONFIG_BACKUP}" ]; then
    cp "${SOURCE_CONFIG_BACKUP}" "${KERNEL_SRC}/.config"
    rm -f "${SOURCE_CONFIG_BACKUP}"
  fi
}

trap restore_source_config EXIT

if [ -f "${KERNEL_SRC}/.config" ]; then
  SOURCE_CONFIG_BACKUP="$(mktemp /tmp/imx6ul-kernel-config.XXXXXX)"
  cp "${KERNEL_SRC}/.config" "${SOURCE_CONFIG_BACKUP}"
fi

make -C "${KERNEL_SRC}" ARCH=arm CROSS_COMPILE="${TOOLCHAIN}" mrproper

rm -rf "${BUILD_DIR}"
mkdir -p "${BUILD_DIR}"
cp "${KERNEL_SRC}/linux_imx6ul_config" "${BUILD_DIR}/.config"

make -C "${KERNEL_SRC}" O="${BUILD_DIR}" ARCH=arm CROSS_COMPILE="${TOOLCHAIN}" oldconfig
make -C "${KERNEL_SRC}" O="${BUILD_DIR}" ARCH=arm CROSS_COMPILE="${TOOLCHAIN}" zImage modules dtbs -j"$(nproc)"
'
