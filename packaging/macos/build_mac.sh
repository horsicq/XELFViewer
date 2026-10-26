#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

QT_PREFIX_PATH="${1:-${QT_PREFIX_PATH:-}}"
BUILD_GENERATOR="${CMAKE_GENERATOR_NAME:-}"
MACOS_ARCHITECTURES="${CMAKE_OSX_ARCHITECTURES:-${MACOS_ARCHITECTURES:-}}"
MACOS_DEPLOYMENT_TARGET="${CMAKE_OSX_DEPLOYMENT_TARGET:-${MACOSX_DEPLOYMENT_TARGET:-}}"
MAC_BUNDLE_ID="${MACOSX_BUNDLE_GUI_IDENTIFIER:-${X_PRIVATE_NOTARIZE_BUNDLE:-com.ntinfo.xelfviewer}}"

APP_CERT="${X_PRIVATE_CERT_APP:-}"
INSTALLER_CERT="${X_PRIVATE_CERT_INSTALL:-}"
APP_ENTITLEMENTS="${X_PRIVATE_APP_ENTITLEMENTS:-}"
KEYCHAIN_PATH="${X_PRIVATE_KEYCHAIN_PATH:-}"
NOTARY_PROFILE="${X_PRIVATE_NOTARIZE_KEYCHAIN_PROFILE:-}"
NOTARY_LOGIN="${X_PRIVATE_NOTARIZE_LOGIN:-}"
NOTARY_PASSWORD="${X_PRIVATE_NOTARIZE_PWD:-}"
NOTARY_TEAM_ID="${X_PRIVATE_NOTARIZE_TEAMID:-}"

WORK_ROOT="${TMPDIR:-/tmp}/xelfviewer_mac"
BUILD_DIR="${WORK_ROOT}/build"
CPACK_ZIP_DIR="${WORK_ROOT}/cpack_zip"
CPACK_PKG_DIR="${WORK_ROOT}/cpack_pkg"
CPACK_OUTPUT_DIR="${WORK_ROOT}/output"
RELEASE_DIR="${PROJECT_ROOT}/release"
CPACK_FINALIZE_SCRIPT="${SCRIPT_DIR}/cpack_finalize_bundle.cmake"

usage() {
    echo "Usage: $(basename "$0") [qt-prefix-path]"
    echo
    echo "Optional env:"
    echo "  CMAKE_GENERATOR_NAME"
    echo "  CMAKE_OSX_ARCHITECTURES or MACOS_ARCHITECTURES"
    echo "  CMAKE_OSX_DEPLOYMENT_TARGET or MACOSX_DEPLOYMENT_TARGET"
    echo "  MACOSX_BUNDLE_GUI_IDENTIFIER"
    echo "  X_PRIVATE_CERT_APP"
    echo "  X_PRIVATE_CERT_INSTALL"
    echo "  X_PRIVATE_NOTARIZE_BUNDLE"
    echo "  X_PRIVATE_NOTARIZE_KEYCHAIN_PROFILE"
    echo "  X_PRIVATE_NOTARIZE_LOGIN / X_PRIVATE_NOTARIZE_PWD / X_PRIVATE_NOTARIZE_TEAMID"
}

fail() {
    echo "$1" >&2
    exit 1
}

require_tool() {
    command -v "$1" >/dev/null 2>&1 || fail "Required tool not found: $1"
}

find_app_bundle() {
    local candidate=""

    for candidate in \
        "${BUILD_DIR}/src/gui/xelfviewer.app" \
        "${BUILD_DIR}/src/gui/Release/xelfviewer.app" \
        "${BUILD_DIR}/src/gui/XELFViewer.app" \
        "${BUILD_DIR}/src/gui/Release/XELFViewer.app"
    do
        if [[ -d "${candidate}" ]]; then
            echo "${candidate}"
            return 0
        fi
    done

    find "${BUILD_DIR}" -maxdepth 6 -type d \( -name "xelfviewer.app" -o -name "XELFViewer.app" \) -print -quit
}

find_macdeployqt() {
    local candidate=""

    if command -v macdeployqt >/dev/null 2>&1; then
        command -v macdeployqt
        return 0
    fi

    for candidate in \
        "${QT_PREFIX_PATH}/bin/macdeployqt" \
        "${QT_PREFIX_PATH}/libexec/macdeployqt" \
        "${QT_PREFIX_PATH}/../bin/macdeployqt" \
        "${QT_PREFIX_PATH}/../libexec/macdeployqt"
    do
        if [[ -x "${candidate}" ]]; then
            echo "${candidate}"
            return 0
        fi
    done

    return 1
}

run_cpack() {
    local generator="$1"
    local build_dir="$2"
    shift 2

    echo "Creating ${generator} package with CPack..."
    cpack \
        --config "${CPACK_CONFIG}" \
        -G "${generator}" \
        -C Release \
        -B "${build_dir}" \
        -D "CPACK_OUTPUT_FILE_PREFIX=${CPACK_OUTPUT_DIR}" \
        -D "CPACK_PRE_BUILD_SCRIPTS=${CPACK_FINALIZE_SCRIPT}" \
        "$@"
}

copy_package_files() {
    local pattern="$1"
    local copied_any="0"
    local package_file=""
    local release_file=""

    while IFS= read -r package_file; do
        copied_any="1"
        release_file="${RELEASE_DIR}/$(basename "${package_file}")"
        cp -f "${package_file}" "${release_file}"
    done < <(find "${CPACK_OUTPUT_DIR}" -type f -name "${pattern}" -print | sort)

    [[ "${copied_any}" == "1" ]] || fail "CPack did not produce a ${pattern} package in ${CPACK_OUTPUT_DIR}"
}

notarization_requested() {
    [[ -n "${NOTARY_PROFILE}" || -n "${NOTARY_LOGIN}" || -n "${NOTARY_PASSWORD}" || -n "${NOTARY_TEAM_ID}" ]]
}

validate_notarization_env() {
    if ! notarization_requested; then
        return 0
    fi

    require_tool xcrun
    xcrun notarytool --help >/dev/null 2>&1 || fail "xcrun notarytool is required for notarization"

    [[ -n "${APP_CERT}" ]] || fail "X_PRIVATE_CERT_APP is required for notarized macOS builds"
    [[ -n "${INSTALLER_CERT}" ]] || fail "X_PRIVATE_CERT_INSTALL is required for notarized macOS builds"
    [[ -n "${MAC_BUNDLE_ID}" ]] || fail "MACOSX_BUNDLE_GUI_IDENTIFIER or X_PRIVATE_NOTARIZE_BUNDLE is required for notarized macOS builds"

    if [[ -n "${NOTARY_PROFILE}" ]]; then
        return 0
    fi

    [[ -n "${NOTARY_LOGIN}" ]] || fail "X_PRIVATE_NOTARIZE_LOGIN is required for notarization"
    [[ -n "${NOTARY_PASSWORD}" ]] || fail "X_PRIVATE_NOTARIZE_PWD is required for notarization"
    [[ -n "${NOTARY_TEAM_ID}" ]] || fail "X_PRIVATE_NOTARIZE_TEAMID is required for notarization"
}

notarize_file() {
    local artifact="$1"

    if ! notarization_requested; then
        return 0
    fi

    echo "Submitting $(basename "${artifact}") for notarization..."

    if [[ -n "${NOTARY_PROFILE}" ]]; then
        xcrun notarytool submit "${artifact}" --keychain-profile "${NOTARY_PROFILE}" --wait
    else
        xcrun notarytool submit "${artifact}" \
            --apple-id "${NOTARY_LOGIN}" \
            --password "${NOTARY_PASSWORD}" \
            --team-id "${NOTARY_TEAM_ID}" \
            --wait
    fi

    if [[ "${artifact}" == *.pkg ]]; then
        echo "Stapling $(basename "${artifact}")..."
        xcrun stapler staple "${artifact}"
        xcrun stapler validate "${artifact}"
    fi
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

[[ "$(uname -s)" == "Darwin" ]] || fail "build_mac.sh must be run on macOS"

[[ -f "${PROJECT_ROOT}/release_version.txt" ]] || fail "release_version.txt not found: ${PROJECT_ROOT}/release_version.txt"

validate_notarization_env

mkdir -p "${RELEASE_DIR}"

rm -rf "${WORK_ROOT}"
mkdir -p "${WORK_ROOT}"

cmake_args=(
    -S "${PROJECT_ROOT}"
    -B "${BUILD_DIR}"
    -DCMAKE_BUILD_TYPE=Release
)

if [[ -n "${QT_PREFIX_PATH}" ]]; then
    cmake_args+=(-DCMAKE_PREFIX_PATH="${QT_PREFIX_PATH}")
fi

if [[ -n "${BUILD_GENERATOR}" ]]; then
    cmake_args+=(-G "${BUILD_GENERATOR}")
fi

if [[ -n "${MACOS_ARCHITECTURES}" ]]; then
    cmake_args+=(-DCMAKE_OSX_ARCHITECTURES="${MACOS_ARCHITECTURES}")
fi

if [[ -n "${MACOS_DEPLOYMENT_TARGET}" ]]; then
    cmake_args+=(-DCMAKE_OSX_DEPLOYMENT_TARGET="${MACOS_DEPLOYMENT_TARGET}")
fi

if [[ -n "${MAC_BUNDLE_ID}" ]]; then
    cmake_args+=(
        -DMACOSX_BUNDLE_GUI_IDENTIFIER="${MAC_BUNDLE_ID}"
        -DBUNDLE_ID_OPTION="${MAC_BUNDLE_ID}"
    )
fi

echo "Configuring macOS build..."
cmake "${cmake_args[@]}"

echo "Building macOS Release..."
cmake --build "${BUILD_DIR}" --config Release --clean-first

APP_BUNDLE="$(find_app_bundle)"
[[ -n "${APP_BUNDLE}" ]] || fail "Built app bundle not found under ${BUILD_DIR}"

CPACK_CONFIG="${BUILD_DIR}/CPackConfig.cmake"
[[ -f "${CPACK_CONFIG}" ]] || fail "CPack config not found: ${CPACK_CONFIG}"

[[ -f "${CPACK_FINALIZE_SCRIPT}" ]] || fail "CPack bundle finalizer not found: ${CPACK_FINALIZE_SCRIPT}"
MACDEPLOYQT_BIN="$(find_macdeployqt)" || fail "macdeployqt was not found"

if [[ -n "${APP_ENTITLEMENTS}" && ! -f "${APP_ENTITLEMENTS}" ]]; then
    fail "Entitlements file not found: ${APP_ENTITLEMENTS}"
fi

export XELFVIEWER_CPACK_MACDEPLOYQT="${MACDEPLOYQT_BIN}"
export XELFVIEWER_CPACK_APP_CERT="${APP_CERT}"
export XELFVIEWER_CPACK_APP_ENTITLEMENTS="${APP_ENTITLEMENTS}"

rm -rf "${CPACK_ZIP_DIR}" "${CPACK_PKG_DIR}" "${CPACK_OUTPUT_DIR}"

set --
if [[ -n "${INSTALLER_CERT}" ]]; then
    set -- "$@" \
        -D "CPACK_PRODUCTBUILD_IDENTITY_NAME=${INSTALLER_CERT}" \
        -D "CPACK_PKGBUILD_IDENTITY_NAME=${INSTALLER_CERT}"
fi

if [[ -n "${KEYCHAIN_PATH}" ]]; then
    set -- "$@" \
        -D "CPACK_PRODUCTBUILD_KEYCHAIN_PATH=${KEYCHAIN_PATH}" \
        -D "CPACK_PKGBUILD_KEYCHAIN_PATH=${KEYCHAIN_PATH}"
fi

run_cpack ZIP "${CPACK_ZIP_DIR}"
run_cpack productbuild "${CPACK_PKG_DIR}" "$@"

copy_package_files "*.zip"
copy_package_files "*.pkg"

RELEASE_ZIPS=()
while IFS= read -r package_file; do
    RELEASE_ZIPS+=("${RELEASE_DIR}/$(basename "${package_file}")")
done < <(find "${CPACK_OUTPUT_DIR}" -type f -name "*.zip" -print | sort)

RELEASE_PKGS=()
while IFS= read -r package_file; do
    RELEASE_PKGS+=("${RELEASE_DIR}/$(basename "${package_file}")")
done < <(find "${CPACK_OUTPUT_DIR}" -type f -name "*.pkg" -print | sort)

for release_zip in "${RELEASE_ZIPS[@]}"; do
    notarize_file "${release_zip}"
done

for release_pkg in "${RELEASE_PKGS[@]}"; do
    notarize_file "${release_pkg}"
done

if [[ "${KEEP_WORK_ROOT:-0}" != "1" ]]; then
    rm -rf "${WORK_ROOT}"
fi

echo
echo "macOS packages created:"
printf '%s\n' "${RELEASE_ZIPS[@]}" "${RELEASE_PKGS[@]}"
