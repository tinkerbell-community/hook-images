#!/usr/bin/env bash
#
# Helper script to list available Hook images in the registry
#
# Usage:
#   ./scripts/list-images.sh [image-kind]
#
# Examples:
#   ./scripts/list-images.sh           # List all image kinds
#   ./scripts/list-images.sh x86_64    # List tags for x86_64
#

set -euo pipefail

IMAGE_KIND="${1:-}"
REGISTRY="ghcr.io"
REPO="tinkerbell-community/hook-images"

usage() {
    cat <<EOF
Usage: $0 [image-kind]

List available Hook images from GHCR.

Arguments:
  image-kind    Optional: specific image kind to show tags for

Examples:
  $0              # List all available image kinds
  $0 x86_64       # List all tags for x86_64 images

Common image kinds:
  - x86_64
  - aarch64
  - arm64
  - lts

Requirements:
  - oras CLI tool (https://oras.land/docs/installation)
  - Authentication to GHCR may be required
EOF
}

# Check if oras is installed
if ! command -v oras &> /dev/null; then
    echo "Error: oras CLI is not installed"
    echo ""
    echo "Install with:"
    echo "  macOS:    brew install oras"
    echo "  Linux:    See https://oras.land/docs/installation"
    exit 1
fi

if [[ -n "${IMAGE_KIND}" ]]; then
    # List tags for specific image kind
    IMAGE_REF="${REGISTRY}/${REPO}/${IMAGE_KIND}"

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Available tags for: ${IMAGE_KIND}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if oras repo tags "${IMAGE_REF}"; then
        echo ""
        echo "To pull a specific version:"
        echo "  oras pull ${IMAGE_REF}:<tag>"
        echo ""
        echo "Or use the helper script:"
        echo "  ./scripts/pull-hook-image.sh ${IMAGE_KIND} <tag>"
    else
        echo ""
        echo "Failed to list tags. You may need to authenticate:"
        echo "  echo \$GITHUB_TOKEN | oras login ghcr.io -u USERNAME --password-stdin"
        exit 1
    fi
else
    # List expected image kinds
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Hook Images Repository"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Registry: ${REGISTRY}"
    echo "Repository: ${REPO}"
    echo ""
    echo "Common image kinds:"
    echo ""

    IMAGE_KINDS=("x86_64" "aarch64" "arm64" "lts")

    for kind in "${IMAGE_KINDS[@]}"; do
        IMAGE_REF="${REGISTRY}/${REPO}/${kind}"
        echo "  • ${kind}"
        echo "    ${IMAGE_REF}"

        # Try to fetch tags
        if tags=$(oras repo tags "${IMAGE_REF}" 2>/dev/null | head -n 5); then
            if [[ -n "${tags}" ]]; then
                echo "    Available tags:"
                echo "${tags}" | sed 's/^/      - /'
            fi
        fi
        echo ""
    done

    echo "To list tags for a specific image kind:"
    echo "  $0 <image-kind>"
    echo ""
    echo "To pull an image:"
    echo "  ./scripts/pull-hook-image.sh <image-kind> <version>"
fi

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
