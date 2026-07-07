#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_NAME="${IMAGE_NAME:-imx6ul-kernel-module-build:ubuntu16-i386}"

docker build --platform linux/386 -t "${IMAGE_NAME}" "${SCRIPT_DIR}"
