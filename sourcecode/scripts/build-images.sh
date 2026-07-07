#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

"${REPO_ROOT}/sourcecode/images/scripts/collect-boot-files.sh"
"${REPO_ROOT}/sourcecode/images/scripts/package-rootfs.sh"

echo "Images are ready under ${REPO_ROOT}/build/images"
