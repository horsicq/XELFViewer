#!/usr/bin/env bash
set -euo pipefail

# Repo convention:
# - build trees and CPack staging always live under the temp directory
# - the repository release/ directory stores only ready-to-use packages

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

QT_PREFIX_PATH="${1:-}"

WORK_ROOT="${TMPDIR:-/tmp}/xelfviewer_linux"
BUILD_DIR="${WORK_ROOT}/build"
CPACK_DIR="${WORK_ROOT}/cpack"
CPACK_OUTPUT_DIR="${WORK_ROOT}/output"
RELEASE_DIR="${PROJECT_ROOT}/release"

usage() {
    echo "Usage: $(basename "$0") [qt-prefix-path]"
}

fail() {
    echo "$1" >&2
    exit 1
}

require_tool() {
    command -v "$1" >/dev/null 2>&1 || fail "Required tool not found: $1"
}

require_tool cmake
require_tool cpack
require_tool find

if [[ "${QT_PREFIX_PATH}" == "--help" || "${QT_PREFIX_PATH}" == "-h" ]]; then
    usage
    exit 0
fi

if [[ -n "${QT_PREFIX_PATH}" && ! -d "${QT_PREFIX_PATH}" ]]; then
    fail "Qt prefix path not found: ${QT_PREFIX_PATH}"
fi

if [[ ! -f "${PROJECT_ROOT}/release_version.txt" ]]; then
    fail "release_version.txt not found: ${PROJECT_ROOT}/release_version.txt"
fi

mkdir -p "${RELEASE_DIR}"

rm -rf "${WORK_ROOT}"
mkdir -p "${WORK_ROOT}"

cmake_args=(
    -S "${PROJECT_ROOT}"
    -B "${BUILD_DIR}"
    -DCMAKE_BUILD_TYPE=Release
    -DXELFVIEWER_PORTABLE_LAYOUT=ON
)

if [[ -n "${QT_PREFIX_PATH}" ]]; then
    cmake_args+=(-DCMAKE_PREFIX_PATH="${QT_PREFIX_PATH}")
fi

echo "Configuring Linux portable build..."
cmake "${cmake_args[@]}"

echo "Building Linux Release..."
cmake --build "${BUILD_DIR}" --clean-first

APP_EXE=""
for candidate in \
    "${BUILD_DIR}/src/gui/xelfviewer" \
    "${BUILD_DIR}/src/gui/Release/xelfviewer"
do
    if [[ -f "${candidate}" ]]; then
        APP_EXE="${candidate}"
        break
    fi
done

if [[ -z "${APP_EXE}" ]]; then
    fail "Built executable not found under ${BUILD_DIR}"
fi

CPACK_CONFIG="${BUILD_DIR}/CPackConfig.cmake"
if [[ ! -f "${CPACK_CONFIG}" ]]; then
    fail "CPack config not found: ${CPACK_CONFIG}"
fi

rm -rf "${CPACK_DIR}" "${CPACK_OUTPUT_DIR}"

echo "Creating Linux portable archive with CPack..."
cpack \
    --config "${CPACK_CONFIG}" \
    -G TGZ \
    -B "${CPACK_DIR}" \
    -D "CPACK_OUTPUT_FILE_PREFIX=${CPACK_OUTPUT_DIR}"

mapfile -t tgz_files < <(find "${CPACK_OUTPUT_DIR}" -type f \( -name "*.tar.gz" -o -name "*.tgz" \) -print)

if [[ "${#tgz_files[@]}" -eq 0 ]]; then
    fail "CPack did not produce a .tar.gz archive in ${CPACK_OUTPUT_DIR}"
fi

PACKAGE_TGZ="${tgz_files[0]}"
FINAL_TGZ="${RELEASE_DIR}/$(basename "${PACKAGE_TGZ}")"

rm -f "${FINAL_TGZ}"
cp -f "${PACKAGE_TGZ}" "${FINAL_TGZ}"

rm -rf "${WORK_ROOT}"

echo
echo "Linux portable archive created:"
echo "  ${FINAL_TGZ}"
