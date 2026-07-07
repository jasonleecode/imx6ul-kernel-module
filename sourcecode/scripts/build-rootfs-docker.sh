#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
IMAGE_NAME="${IMAGE_NAME:-imx6ul-kernel-module-build:ubuntu16-i386}"

docker run --rm \
  --platform linux/386 \
  -u "$(id -u):$(id -g)" \
  -v "${REPO_ROOT}:/work" \
  -w /work \
  "${IMAGE_NAME}" \
  /work/sourcecode/rootfs/scripts/build-rootfs.sh
