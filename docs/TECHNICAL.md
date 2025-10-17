# Hook OS Images - Technical Documentation

## Overview

This document provides detailed technical information about the Hook OS image building and publishing system.

## Image Variants

### Variant Types

#### 1. LTS (Long Term Support)

**Archives:**

- `hook_latest-lts-aarch64.tar.gz`
- `hook_latest-lts-x86_64.tar.gz`

**Extracted Files:**

- `vmlinuz-aarch64`
- `initramfs-aarch64`
- `vmlinuz-x86_64`
- `initramfs-x86_64`
- Additional files: `modloop-*`

**Symlinks:** None required (files already use standard names)

**Image Tags:**

- `v0.11.1` (default)
- `v0.11.1-lts`
- `latest` (if enabled)
- `latest-lts` (if enabled)

#### 2. Armbian UEFI

**Archives:**

- `hook_armbian-uefi-arm64-edge.tar.gz`
- `hook_armbian-uefi-x86-edge.tar.gz`

**Extracted Files:**

- `vmlinuz-armbian-uefi-arm64-edge`
- `initramfs-armbian-uefi-arm64-edge`
- `vmlinuz-armbian-uefi-x86-edge`
- `initramfs-armbian-uefi-x86-edge`

**Symlinks:**

```
vmlinuz-arm64 -> vmlinuz-armbian-uefi-arm64-edge
vmlinuz-aarch64 -> vmlinuz-armbian-uefi-arm64-edge
initramfs-arm64 -> initramfs-armbian-uefi-arm64-edge
initramfs-aarch64 -> initramfs-armbian-uefi-arm64-edge
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

**Image Tags:**

- `v0.11.1-armbian-uefi`

#### 3. Armbian Board-Specific

##### BCM2711 (Raspberry Pi 4)

**Archives:**

- `hook_armbian-bcm2711-current.tar.gz`
- `hook_armbian-uefi-x86-edge.tar.gz`

**Extracted Files:**

- `vmlinuz-armbian-bcm2711-current`
- `initramfs-armbian-bcm2711-current`
- `vmlinuz-armbian-uefi-x86-edge`
- `initramfs-armbian-uefi-x86-edge`

**Symlinks:**

```
vmlinuz-arm64 -> vmlinuz-armbian-bcm2711-current
vmlinuz-aarch64 -> vmlinuz-armbian-bcm2711-current
initramfs-arm64 -> initramfs-armbian-bcm2711-current
initramfs-aarch64 -> initramfs-armbian-bcm2711-current
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

**Image Tags:**

- `v0.11.1-armbian-bcm2711`

##### Meson64 (Amlogic)

**Archives:**

- `hook_armbian-meson64-edge.tar.gz`
- `hook_armbian-uefi-x86-edge.tar.gz`

**Symlinks:**

```
vmlinuz-arm64 -> vmlinuz-armbian-meson64-edge
vmlinuz-aarch64 -> vmlinuz-armbian-meson64-edge
initramfs-arm64 -> initramfs-armbian-meson64-edge
initramfs-aarch64 -> initramfs-armbian-meson64-edge
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

**Image Tags:**

- `v0.11.1-armbian-meson64`

##### RK35xx (Rockchip RK35xx)

**Archives:**

- `hook_armbian-rk35xx-vendor.tar.gz`
- `hook_armbian-uefi-x86-edge.tar.gz`

**Symlinks:**

```
vmlinuz-arm64 -> vmlinuz-armbian-rk35xx-vendor
vmlinuz-aarch64 -> vmlinuz-armbian-rk35xx-vendor
initramfs-arm64 -> initramfs-armbian-rk35xx-vendor
initramfs-aarch64 -> initramfs-armbian-rk35xx-vendor
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

**Image Tags:**

- `v0.11.1-armbian-rk35xx`

##### Rockchip64

**Archives:**

- `hook_armbian-rockchip64-edge.tar.gz`
- `hook_armbian-uefi-x86-edge.tar.gz`

**Symlinks:**

```
vmlinuz-arm64 -> vmlinuz-armbian-rockchip64-edge
vmlinuz-aarch64 -> vmlinuz-armbian-rockchip64-edge
initramfs-arm64 -> initramfs-armbian-rockchip64-edge
initramfs-aarch64 -> initramfs-armbian-rockchip64-edge
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

**Image Tags:**

- `v0.11.1-armbian-rockchip64`

#### 4. All-in-One Variants

Each variant has a corresponding `-all` image that includes **all** boot files from all variants:

- All LTS files
- All Armbian UEFI files (ARM and x86)
- All board-specific files

The difference between `-all` variants is which files the standard symlinks point to.

**Example: `v0.11.1-armbian-bcm2711-all`**

**Includes all files:**

- `vmlinuz-aarch64`, `initramfs-aarch64` (LTS)
- `vmlinuz-x86_64`, `initramfs-x86_64` (LTS)
- `vmlinuz-armbian-uefi-arm64-edge`, `initramfs-armbian-uefi-arm64-edge`
- `vmlinuz-armbian-uefi-x86-edge`, `initramfs-armbian-uefi-x86-edge`
- `vmlinuz-armbian-bcm2711-current`, `initramfs-armbian-bcm2711-current`
- `vmlinuz-armbian-meson64-edge`, `initramfs-armbian-meson64-edge`
- `vmlinuz-armbian-rk35xx-vendor`, `initramfs-armbian-rk35xx-vendor`
- `vmlinuz-armbian-rockchip64-edge`, `initramfs-armbian-rockchip64-edge`

**Symlinks point to bcm2711:**

```
vmlinuz-arm64 -> vmlinuz-armbian-bcm2711-current
vmlinuz-aarch64 -> vmlinuz-armbian-bcm2711-current
initramfs-arm64 -> initramfs-armbian-bcm2711-current
initramfs-aarch64 -> initramfs-armbian-bcm2711-current
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

## Workflow Architecture

### Job Flow

```
prepare
  ↓
├─→ build-lts
├─→ build-armbian-uefi
└─→ build-armbian-boards (matrix)
      ↓
    build-all-variants (matrix)
      ↓
    summary
```

### Job Details

#### `prepare`

**Purpose:** Determine version tags and configuration

**Outputs:**

- `version_tag`: Full version (e.g., `v0.11.1`)
- `version_short`: Version without prefix (e.g., `0.11.1`)
- `publish_latest`: Whether to tag as latest

#### `build-lts`

**Purpose:** Build and publish LTS variant

**Steps:**

1. Download LTS archives (aarch64, x86_64)
1. Extract to working directory
1. Verify expected files exist
1. Push to GHCR with ORAS
1. Tag as `${VERSION}` and `${VERSION}-lts`
1. Optionally tag as `latest` and `latest-lts`

#### `build-armbian-uefi`

**Purpose:** Build and publish Armbian UEFI variant

**Steps:**

1. Download Armbian UEFI archives (arm64, x86)
1. Extract files
1. Create standard architecture symlinks
1. Push to GHCR as `${VERSION}-armbian-uefi`

#### `build-armbian-boards`

**Purpose:** Build and publish board-specific variants

**Matrix Strategy:**

```yaml
matrix:
  board:
    - name: bcm2711
      kernel_suffix: current
    - name: meson64
      kernel_suffix: edge
    - name: rk35xx
      kernel_suffix: vendor
    - name: rockchip64
      kernel_suffix: edge
```

**Steps (per board):**

1. Download board archive and x86 UEFI archive
1. Extract files
1. Create symlinks (board → ARM, x86 UEFI → x86_64)
1. Push to GHCR as `${VERSION}-armbian-${BOARD}`

#### `build-all-variants`

**Purpose:** Build all-in-one bundles with variant-specific symlinks

**Matrix Strategy:**

```yaml
matrix:
  variant:
    - name: lts
      base: lts
      symlink_arm: aarch64
      symlink_x86: x86_64
    - name: armbian-bcm2711
      base: armbian-bcm2711
      symlink_arm: armbian-bcm2711-current
      symlink_x86: armbian-uefi-x86-edge
    # ... more variants
```

**Steps (per variant):**

1. Download **all** archives (LTS + all Armbian variants)
1. Extract all files
1. Create variant-specific symlinks
1. Push to GHCR as `${VERSION}-${VARIANT}-all`
1. Optionally tag LTS as `latest-all`

#### `summary`

**Purpose:** Generate workflow summary

Creates markdown summary with all published image tags.

## ORAS Usage

### Push Command Structure

```bash
oras push <image-reference> \
  --artifact-type application/vnd.tinkerbell.hook.os.v1+tar \
  --annotation "org.opencontainers.image.source=..." \
  --annotation "org.opencontainers.image.version=..." \
  --annotation "org.opencontainers.image.description=..." \
  --annotation "org.tinkerbell.hook.variant=..." \
  $(find . -type f -o -type l | grep -E '(vmlinuz|initramfs|modloop)' | xargs -I {} echo "{}:application/octet-stream")
```

### Key Points

1. **Artifact Type:** Custom type for Hook OS images
1. **Annotations:** OCI standard + custom Tinkerbell annotation
1. **Files:** Dynamically discovered boot files
1. **Symlinks:** Included as-is (ORAS handles them)
1. **Media Type:** `application/octet-stream` for binary files

## File Naming Conventions

### Archive Names (from Hook releases)

```
hook_latest-lts-<arch>.tar.gz
hook_armbian-uefi-<arch>-<suffix>.tar.gz
hook_armbian-<board>-<suffix>.tar.gz
```

### Extracted File Names

```
vmlinuz-<variant>
initramfs-<variant>
modloop-<variant>
```

### Standard Symlink Names

```
vmlinuz-arm64
vmlinuz-aarch64
vmlinuz-x86_64
initramfs-arm64
initramfs-aarch64
initramfs-x86_64
```

### Image Tag Format

```
<registry>/<repo>:<version>-<variant>[-all]
```

Examples:

- `ghcr.io/tinkerbell-community/hook-images:v0.11.1`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711-all`

## Layer Sharing and Efficiency

### Common Files Across Variants

**x86 UEFI files** (shared by all board variants):

- `vmlinuz-armbian-uefi-x86-edge`
- `initramfs-armbian-uefi-x86-edge`

**All files** (shared by all `-all` variants):

- Complete set of LTS and Armbian files

### ORAS Layer Management

ORAS (and OCI registries) automatically deduplicate identical layers:

1. When pushing multiple images with the same file, only one copy is stored
1. Images reference the same layer digest
1. Pulls are optimized to fetch each unique layer once

### Storage Efficiency

**Example:**

- `v0.11.1-armbian-bcm2711`: ~100MB
- `v0.11.1-armbian-meson64`: ~100MB
- Total storage: ~150MB (not 200MB) due to shared x86 files

**All variants:**

- Each `-all` variant: ~400MB
- 6 `-all` variants: ~500MB total (not 2.4GB) due to shared files

## Testing and Validation

### Local Testing Script

Use `scripts/build-local.sh` to test variant building locally:

```bash
# Test LTS
./scripts/build-local.sh v0.11.1 lts

# Test board variant
./scripts/build-local.sh v0.11.1 armbian-bcm2711

# Test all variant
./scripts/build-local.sh v0.11.1 armbian-bcm2711-all
```

### Validation Checklist

For each variant, verify:

- [ ] All expected files are present
- [ ] Symlinks point to correct targets
- [ ] Standard architecture symlinks exist
- [ ] File permissions are correct
- [ ] Image can be pulled with ORAS
- [ ] Annotations are correct

### Manual Verification

```bash
# Pull image
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Check files
ls -lh

# Verify symlinks
ls -la | grep '^l'

# Check manifest
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts | jq
```

## Troubleshooting

### Common Issues

#### Archive Not Found

**Symptom:** Download fails with 404

**Solution:** Verify archive exists in Hook release at:
`https://github.com/tinkerbell/hook/releases/tag/<version>`

#### Missing Files After Extraction

**Symptom:** Expected files don't exist after `tar -xzf`

**Solution:** Check archive contents:

```bash
tar -tzf archive.tar.gz | head -20
```

#### Symlink Creation Fails

**Symptom:** `ln -sf` command fails

**Solution:** Check that target file exists before creating symlink

#### ORAS Push Fails

**Symptom:** Cannot push to GHCR

**Solutions:**

1. Verify authentication: `docker login ghcr.io`
1. Check permissions: workflow needs `packages: write`
1. Verify image reference syntax

#### Wrong Files in Image

**Symptom:** Image contains unexpected files or missing files

**Solution:** Check `find` command filters:

```bash
find . -type f -o -type l | grep -E '(vmlinuz|initramfs|modloop)'
```

## Future Enhancements

### Planned Features

1. **Checksums:** Verify archive integrity with SHA256 checksums
1. **Signing:** Sign images with Cosign
1. **Multi-arch Manifests:** Create proper OCI manifest lists
1. **Automated Testing:** Run boot tests in QEMU
1. **Version Matrix:** Support building multiple versions in one run
1. **Incremental Updates:** Only rebuild changed variants

### Extensibility

The workflow is designed to be extensible:

- Add new boards by updating the matrix
- Add new archive types with new jobs
- Customize symlink strategies per variant
- Add validation steps

## References

- [ORAS Documentation](https://oras.land/)
- [OCI Artifacts Spec](https://github.com/opencontainers/artifacts)
- [Tinkerbell Hook](https://github.com/tinkerbell/hook)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
