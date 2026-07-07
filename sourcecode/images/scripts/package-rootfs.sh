#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
REPO_ROOT="$(cd "${SOURCE_DIR}/.." && pwd)"

ROOTFS_DIR="${ROOTFS_DIR:-${REPO_ROOT}/build/rootfs}"
OUTPUT_DIR="${OUTPUT_DIR:-${REPO_ROOT}/build/images}"
IMAGE_SIZE_MB="${IMAGE_SIZE_MB:-128}"
ROOTFS_TAR="${OUTPUT_DIR}/rootfs.tar.gz"
ROOTFS_EXT4="${OUTPUT_DIR}/rootfs.ext4"

if [ ! -d "${ROOTFS_DIR}" ]; then
    echo "Rootfs directory not found: ${ROOTFS_DIR}" >&2
    echo "Build it first with ./sourcecode/scripts/build-rootfs-docker.sh" >&2
    exit 1
fi

mkdir -p "${OUTPUT_DIR}"

tar --numeric-owner --owner=0 --group=0 -czf "${ROOTFS_TAR}" -C "${ROOTFS_DIR}" .

if command -v mkfs.ext4 >/dev/null 2>&1; then
    rm -f "${ROOTFS_EXT4}"
    dd if=/dev/zero of="${ROOTFS_EXT4}" bs=1M count="${IMAGE_SIZE_MB}" status=none
    mkfs.ext4 -q -d "${ROOTFS_DIR}" "${ROOTFS_EXT4}"
else
    echo "mkfs.ext4 not found; skipped ext4 image generation" >&2
fi

echo "Rootfs package written to ${OUTPUT_DIR}"
