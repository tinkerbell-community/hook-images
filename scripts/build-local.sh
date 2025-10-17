#!/usr/bin/env bash
#
# Local testing script for Hook OS image building
#
# Usage:
#   ./scripts/build-local.sh <hook-version> <variant>
#
# Examples:
#   ./scripts/build-local.sh v0.11.1 lts
#   ./scripts/build-local.sh v0.11.1 armbian-bcm2711
#   ./scripts/build-local.sh v0.11.1 lts-all
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

HOOK_VERSION="${1:-v0.11.1}"
VARIANT="${2:-lts}"
WORK_DIR="${PROJECT_ROOT}/work/${VARIANT}"

usage() {
    cat <<EOF
Usage: $0 <hook-version> <variant>

Build Hook OS images locally for testing.

Arguments:
  hook-version  Hook version to build (e.g., v0.11.1)
  variant       Variant to build:
                  - lts
                  - armbian-uefi
                  - armbian-bcm2711
                  - armbian-meson64
                  - armbian-rk35xx
                  - armbian-rockchip64
                  - lts-all
                  - armbian-uefi-all
                  - armbian-bcm2711-all
                  - armbian-meson64-all
                  - armbian-rk35xx-all
                  - armbian-rockchip64-all

Examples:
  $0 v0.11.1 lts
  $0 v0.11.1 armbian-bcm2711
  $0 v0.11.1 lts-all

Requirements:
  - curl
  - tar
EOF
}

download_lts() {
    local base_url="$1"
    local work_dir="$2"
    
    echo "Downloading LTS archives..."
    curl -fsSL -o "${work_dir}/hook_latest-lts-aarch64.tar.gz" \
        "${base_url}/hook_latest-lts-aarch64.tar.gz" || true
    curl -fsSL -o "${work_dir}/hook_latest-lts-x86_64.tar.gz" \
        "${base_url}/hook_latest-lts-x86_64.tar.gz" || true
}

download_armbian_uefi() {
    local base_url="$1"
    local work_dir="$2"
    
    echo "Downloading Armbian UEFI archives..."
    curl -fsSL -o "${work_dir}/hook_armbian-uefi-arm64-edge.tar.gz" \
        "${base_url}/hook_armbian-uefi-arm64-edge.tar.gz" || true
    curl -fsSL -o "${work_dir}/hook_armbian-uefi-x86-edge.tar.gz" \
        "${base_url}/hook_armbian-uefi-x86-edge.tar.gz" || true
}

download_armbian_board() {
    local base_url="$1"
    local work_dir="$2"
    local board="$3"
    local suffix="$4"
    
    echo "Downloading Armbian ${board} archives..."
    curl -fsSL -o "${work_dir}/hook_armbian-${board}-${suffix}.tar.gz" \
        "${base_url}/hook_armbian-${board}-${suffix}.tar.gz" || true
    # Also download x86 for board variants
    curl -fsSL -o "${work_dir}/hook_armbian-uefi-x86-edge.tar.gz" \
        "${base_url}/hook_armbian-uefi-x86-edge.tar.gz" || true
}

extract_archives() {
    local work_dir="$1"
    
    echo "Extracting archives..."
    cd "${work_dir}"
    
    for archive in *.tar.gz; do
        if [ -f "$archive" ]; then
            echo "  Extracting $archive..."
            tar -xzf "$archive"
        fi
    done
    
    # Clean up tar.gz files
    rm -f *.tar.gz
    
    echo "Extracted files:"
    ls -lh
}

create_lts_symlinks() {
    local work_dir="$1"
    
    cd "${work_dir}"
    
    echo "LTS variant uses native architecture names, no symlinks needed"
}

create_armbian_uefi_symlinks() {
    local work_dir="$1"
    
    cd "${work_dir}"
    
    echo "Creating Armbian UEFI symlinks..."
    
    if [ -f "vmlinuz-armbian-uefi-arm64-edge" ]; then
        ln -sf vmlinuz-armbian-uefi-arm64-edge vmlinuz-arm64
        ln -sf vmlinuz-armbian-uefi-arm64-edge vmlinuz-aarch64
    fi
    if [ -f "initramfs-armbian-uefi-arm64-edge" ]; then
        ln -sf initramfs-armbian-uefi-arm64-edge initramfs-arm64
        ln -sf initramfs-armbian-uefi-arm64-edge initramfs-aarch64
    fi
    if [ -f "vmlinuz-armbian-uefi-x86-edge" ]; then
        ln -sf vmlinuz-armbian-uefi-x86-edge vmlinuz-x86_64
    fi
    if [ -f "initramfs-armbian-uefi-x86-edge" ]; then
        ln -sf initramfs-armbian-uefi-x86-edge initramfs-x86_64
    fi
}

create_board_symlinks() {
    local work_dir="$1"
    local board="$2"
    local suffix="$3"
    
    cd "${work_dir}"
    
    echo "Creating Armbian ${board} symlinks..."
    
    # ARM board -> standard ARM names
    if [ -f "vmlinuz-armbian-${board}-${suffix}" ]; then
        ln -sf "vmlinuz-armbian-${board}-${suffix}" vmlinuz-arm64
        ln -sf "vmlinuz-armbian-${board}-${suffix}" vmlinuz-aarch64
    fi
    if [ -f "initramfs-armbian-${board}-${suffix}" ]; then
        ln -sf "initramfs-armbian-${board}-${suffix}" initramfs-arm64
        ln -sf "initramfs-armbian-${board}-${suffix}" initramfs-aarch64
    fi
    
    # x86 UEFI -> standard x86_64 name
    if [ -f "vmlinuz-armbian-uefi-x86-edge" ]; then
        ln -sf vmlinuz-armbian-uefi-x86-edge vmlinuz-x86_64
    fi
    if [ -f "initramfs-armbian-uefi-x86-edge" ]; then
        ln -sf initramfs-armbian-uefi-x86-edge initramfs-x86_64
    fi
}

create_all_variant_symlinks() {
    local work_dir="$1"
    local variant="$2"
    
    cd "${work_dir}"
    
    echo "Creating symlinks for ${variant}-all variant..."
    
    case "$variant" in
        lts)
            ARM_SOURCE="aarch64"
            X86_SOURCE="x86_64"
            ;;
        armbian-uefi)
            ARM_SOURCE="armbian-uefi-arm64-edge"
            X86_SOURCE="armbian-uefi-x86-edge"
            ;;
        armbian-bcm2711)
            ARM_SOURCE="armbian-bcm2711-current"
            X86_SOURCE="armbian-uefi-x86-edge"
            ;;
        armbian-meson64)
            ARM_SOURCE="armbian-meson64-edge"
            X86_SOURCE="armbian-uefi-x86-edge"
            ;;
        armbian-rk35xx)
            ARM_SOURCE="armbian-rk35xx-vendor"
            X86_SOURCE="armbian-uefi-x86-edge"
            ;;
        armbian-rockchip64)
            ARM_SOURCE="armbian-rockchip64-edge"
            X86_SOURCE="armbian-uefi-x86-edge"
            ;;
        *)
            echo "ERROR: Unknown variant for symlinks: $variant"
            return 1
            ;;
    esac
    
    echo "  ARM source: ${ARM_SOURCE}"
    echo "  x86 source: ${X86_SOURCE}"
    
    # ARM symlinks
    if [ -f "vmlinuz-${ARM_SOURCE}" ]; then
        ln -sf "vmlinuz-${ARM_SOURCE}" vmlinuz-arm64
        ln -sf "vmlinuz-${ARM_SOURCE}" vmlinuz-aarch64
    fi
    if [ -f "initramfs-${ARM_SOURCE}" ]; then
        ln -sf "initramfs-${ARM_SOURCE}" initramfs-arm64
        ln -sf "initramfs-${ARM_SOURCE}" initramfs-aarch64
    fi
    
    # x86 symlinks
    if [ -f "vmlinuz-${X86_SOURCE}" ]; then
        ln -sf "vmlinuz-${X86_SOURCE}" vmlinuz-x86_64
    fi
    if [ -f "initramfs-${X86_SOURCE}" ]; then
        ln -sf "initramfs-${X86_SOURCE}" initramfs-x86_64
    fi
}

# Main script
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Building Hook OS Image Locally"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Version: ${HOOK_VERSION}"
echo "Variant: ${VARIANT}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create work directory
mkdir -p "${WORK_DIR}"
cd "${WORK_DIR}"

BASE_URL="https://github.com/tinkerbell/hook/releases/download/${HOOK_VERSION}"

# Download based on variant
case "$VARIANT" in
    lts)
        download_lts "$BASE_URL" "$WORK_DIR"
        extract_archives "$WORK_DIR"
        create_lts_symlinks "$WORK_DIR"
        ;;
    
    armbian-uefi)
        download_armbian_uefi "$BASE_URL" "$WORK_DIR"
        extract_archives "$WORK_DIR"
        create_armbian_uefi_symlinks "$WORK_DIR"
        ;;
    
    armbian-bcm2711)
        download_armbian_board "$BASE_URL" "$WORK_DIR" "bcm2711" "current"
        extract_archives "$WORK_DIR"
        create_board_symlinks "$WORK_DIR" "bcm2711" "current"
        ;;
    
    armbian-meson64)
        download_armbian_board "$BASE_URL" "$WORK_DIR" "meson64" "edge"
        extract_archives "$WORK_DIR"
        create_board_symlinks "$WORK_DIR" "meson64" "edge"
        ;;
    
    armbian-rk35xx)
        download_armbian_board "$BASE_URL" "$WORK_DIR" "rk35xx" "vendor"
        extract_archives "$WORK_DIR"
        create_board_symlinks "$WORK_DIR" "rk35xx" "vendor"
        ;;
    
    armbian-rockchip64)
        download_armbian_board "$BASE_URL" "$WORK_DIR" "rockchip64" "edge"
        extract_archives "$WORK_DIR"
        create_board_symlinks "$WORK_DIR" "rockchip64" "edge"
        ;;
    
    *-all)
        BASE_VARIANT="${VARIANT%-all}"
        echo "Building ${BASE_VARIANT}-all variant (includes all archives)..."
        
        # Download all archives
        download_lts "$BASE_URL" "$WORK_DIR"
        download_armbian_uefi "$BASE_URL" "$WORK_DIR"
        download_armbian_board "$BASE_URL" "$WORK_DIR" "bcm2711" "current"
        download_armbian_board "$BASE_URL" "$WORK_DIR" "meson64" "edge"
        download_armbian_board "$BASE_URL" "$WORK_DIR" "rk35xx" "vendor"
        download_armbian_board "$BASE_URL" "$WORK_DIR" "rockchip64" "edge"
        
        extract_archives "$WORK_DIR"
        create_all_variant_symlinks "$WORK_DIR" "$BASE_VARIANT"
        ;;
    
    *)
        echo "ERROR: Unknown variant: $VARIANT"
        usage
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Build Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Output directory: ${WORK_DIR}"
echo ""
echo "Files and symlinks:"
ls -lh "${WORK_DIR}"
echo ""
echo "To test with ORAS locally, run:"
echo "  cd ${WORK_DIR}"
echo "  oras push localhost:5000/test:${VARIANT} \\"
echo "    \$(find . -type f -o -type l | grep -E '(vmlinuz|initramfs)' | xargs -I {} echo '{}:application/octet-stream')"
