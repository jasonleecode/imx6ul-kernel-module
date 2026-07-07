#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPO_ROOT="$(cd "${SOURCE_DIR}/.." && pwd)"

BUSYBOX_VERSION="${BUSYBOX_VERSION:-1.20.2}"
BUILD_ROOT="${BUILD_ROOT:-${REPO_ROOT}/build}"
BUSYBOX_BUILD_DIR="${BUSYBOX_BUILD_DIR:-${BUILD_ROOT}/busybox-${BUSYBOX_VERSION}}"
ROOTFS_DIR="${ROOTFS_DIR:-${BUILD_ROOT}/rootfs}"
KERNEL_SRC="${KERNEL_SRC:-${SOURCE_DIR}/kernel/linux-3.14.38}"
KERNEL_BUILD_DIR="${KERNEL_BUILD_DIR:-${BUILD_ROOT}/kernel-imx6ul}"
TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-${REPO_ROOT}/tools/gcc-4.6.2-glibc-2.13-linaro-multilib/fsl-linaro-toolchain}"
CROSS_COMPILE="${CROSS_COMPILE:-${TOOLCHAIN_ROOT}/bin/arm-fsl-linux-gnueabi-}"
SYSROOT="${SYSROOT:-${TOOLCHAIN_ROOT}/arm-fsl-linux-gnueabi/multi-libs/default}"

BUSYBOX_TARBALL="${SOURCE_DIR}/busybox/busybox-${BUSYBOX_VERSION}.tar.gz"
OVERLAY_DIR="${SOURCE_DIR}/rootfs/overlay"

if [ ! -f "${BUSYBOX_TARBALL}" ]; then
    echo "BusyBox tarball not found: ${BUSYBOX_TARBALL}" >&2
    exit 1
fi

if [ ! -x "${CROSS_COMPILE}gcc" ]; then
    echo "Cross compiler not found or not executable: ${CROSS_COMPILE}gcc" >&2
    exit 1
fi

rm -rf "${BUSYBOX_BUILD_DIR}" "${ROOTFS_DIR}"
mkdir -p "${BUILD_ROOT}" "${ROOTFS_DIR}"

tar xf "${BUSYBOX_TARBALL}" -C "${BUILD_ROOT}"

make -C "${BUSYBOX_BUILD_DIR}" ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" defconfig >/dev/null
sed -i \
    -e 's/^.*CONFIG_STATIC.*/# CONFIG_STATIC is not set/' \
    -e 's/^.*CONFIG_INSTALL_APPLET_SYMLINKS.*/CONFIG_INSTALL_APPLET_SYMLINKS=y/' \
    "${BUSYBOX_BUILD_DIR}/.config"

make -C "${BUSYBOX_BUILD_DIR}" ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" -j"$(nproc)"
make -C "${BUSYBOX_BUILD_DIR}" ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" CONFIG_PREFIX="${ROOTFS_DIR}" install >/dev/null

mkdir -p \
    "${ROOTFS_DIR}/dev" \
    "${ROOTFS_DIR}/dev/pts" \
    "${ROOTFS_DIR}/etc" \
    "${ROOTFS_DIR}/lib" \
    "${ROOTFS_DIR}/proc" \
    "${ROOTFS_DIR}/root" \
    "${ROOTFS_DIR}/run" \
    "${ROOTFS_DIR}/sys" \
    "${ROOTFS_DIR}/tmp" \
    "${ROOTFS_DIR}/usr/lib" \
    "${ROOTFS_DIR}/var/log" \
    "${ROOTFS_DIR}/var/run"

cp -a "${OVERLAY_DIR}/." "${ROOTFS_DIR}/"
chmod 755 "${ROOTFS_DIR}/etc/init.d/rcS" "${ROOTFS_DIR}/etc/init.d/S50network"
chmod 1777 "${ROOTFS_DIR}/tmp"

copy_pattern() {
    local source_dir="$1"
    local target_dir="$2"
    local pattern="$3"
    local source

    for source in "${source_dir}"/${pattern}; do
        [ -e "${source}" ] || continue
        cp -a "${source}" "${target_dir}/"
    done
}

copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "ld-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "ld-linux.so.3"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libc-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libc.so.6"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libm-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libm.so.6"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libpthread-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libpthread.so.0"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libdl-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libdl.so.2"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "librt-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "librt.so.1"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libnss_files-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libnss_files.so.2"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libnss_dns-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libnss_dns.so.2"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libresolv-*.so"
copy_pattern "${SYSROOT}/lib" "${ROOTFS_DIR}/lib" "libresolv.so.2"
copy_pattern "${SYSROOT}/usr/lib" "${ROOTFS_DIR}/usr/lib" "libgcc_s.so.1"
copy_pattern "${SYSROOT}/usr/lib" "${ROOTFS_DIR}/usr/lib" "libstdc++.so.6*"

if [ -d "${KERNEL_BUILD_DIR}" ]; then
    make -C "${KERNEL_SRC}" O="${KERNEL_BUILD_DIR}" ARCH=arm CROSS_COMPILE="${CROSS_COMPILE}" INSTALL_MOD_PATH="${ROOTFS_DIR}" modules_install
fi

echo "Rootfs generated at ${ROOTFS_DIR}"
