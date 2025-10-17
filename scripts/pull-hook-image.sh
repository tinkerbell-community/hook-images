#!/usr/bin/env bash
#
# Helper script to pull and inspect Hook images published with ORAS
#
# Usage:
#   ./scripts/pull-hook-image.sh <image-kind> <version>
#
# Examples:
#   ./scripts/pull-hook-image.sh x86_64 v0.11.1
#   ./scripts/pull-hook-image.sh aarch64 latest
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

IMAGE_KIND="${1:-}"
VERSION="${2:-v0.11.1}"
REGISTRY="ghcr.io"
REPO="tinkerbell-community/hook-images"

usage() {
    cat <<EOF
Usage: $0 <image-kind> [version]

Pull and inspect a Hook image from GHCR using ORAS.

Arguments:
  image-kind    The image kind to pull (e.g., x86_64, aarch64, lts)
  version       The version tag (default: v0.11.1)

Examples:
  $0 x86_64 v0.11.1
  $0 aarch64 latest
  $0 lts v0.11.1

Available image kinds depend on the Hook release. Common types:
  - x86_64
  - aarch64
  - arm64
  - lts

Requirements:
  - oras CLI tool (https://oras.land/docs/installation)
EOF
}

if [[ -z "${IMAGE_KIND}" ]]; then
    echo "Error: image-kind is required"
    echo ""
    usage
    exit 1
fi

# Check if oras is installed
if ! command -v oras &> /dev/null; then
    echo "Error: oras CLI is not installed"
    echo ""
    echo "Install with:"
    echo "  macOS:    brew install oras"
    echo "  Linux:    See https://oras.land/docs/installation"
    exit 1
fi

IMAGE_REF="${REGISTRY}/${REPO}/${IMAGE_KIND}:${VERSION}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Pulling Hook Image"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Image:   ${IMAGE_REF}"
echo "Kind:    ${IMAGE_KIND}"
echo "Version: ${VERSION}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create output directory
OUTPUT_DIR="${PROJECT_ROOT}/downloads/${IMAGE_KIND}/${VERSION}"
mkdir -p "${OUTPUT_DIR}"
cd "${OUTPUT_DIR}"

echo "→ Pulling image to: ${OUTPUT_DIR}"
echo ""

# Pull the image
if oras pull "${IMAGE_REF}"; then
    echo ""
    echo "✓ Successfully pulled image"
    echo ""

    # List downloaded files
    echo "Downloaded files:"
    ls -lh
    echo ""

    # Show manifest
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Image Manifest"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    oras manifest fetch "${IMAGE_REF}" | jq '.'
    echo ""

    # Extract tar.xz if present
    TAR_XZ_FILE=$(find . -name "*.tar.xz" -type f | head -n 1)
    if [[ -n "${TAR_XZ_FILE}" ]]; then
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Archive Contents"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Listing contents of: ${TAR_XZ_FILE}"
        echo ""
        tar -tJf "${TAR_XZ_FILE}" | head -n 20
        echo ""
        TOTAL_FILES=$(tar -tJf "${TAR_XZ_FILE}" | wc -l)
        echo "Total files in archive: ${TOTAL_FILES}"
    fi
else
    echo ""
    echo "✗ Failed to pull image"
    echo ""
    echo "Make sure:"
    echo "  1. The image exists at ${IMAGE_REF}"
    echo "  2. You have access to the registry (may need to authenticate)"
    echo "  3. The version tag is correct"
    echo ""
    echo "To authenticate with GHCR:"
    echo "  echo \$GITHUB_TOKEN | oras login ghcr.io -u USERNAME --password-stdin"
    exit 1
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Done!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Files downloaded to: ${OUTPUT_DIR}"
