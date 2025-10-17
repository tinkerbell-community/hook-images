# hook-images

This repository provides GitHub workflows to automatically publish [Tinkerbell Hook](https://github.com/tinkerbell/hook) OS images as OCI artifacts using ORAS (OCI Registry as Storage).

## Overview

The workflows download Hook OS archives (tar.gz) from Tinkerbell Hook releases, extract boot files (kernel, initramfs), create standard architecture symlinks, and publish them as OCI images to GitHub Container Registry (GHCR) for use in Tinkerbell deployments.

## Published Images

Images are published to: `ghcr.io/tinkerbell-community/hook-images:<variant-version>`

### Available Variants

#### Base LTS (Default)

- `ghcr.io/tinkerbell-community/hook-images:v0.11.1` (default, uses LTS)
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts`
- `ghcr.io/tinkerbell-community/hook-images:latest` (when enabled)
- `ghcr.io/tinkerbell-community/hook-images:latest-lts` (when enabled)

**Includes:** `vmlinuz-aarch64`, `initramfs-aarch64`, `vmlinuz-x86_64`, `initramfs-x86_64`

#### Armbian UEFI

- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-uefi`

**Includes:** ARM64 and x86 UEFI boot files with standard arch symlinks

#### Armbian Board-Specific

- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711` (Raspberry Pi 4)
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-meson64` (Amlogic)
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rk35xx` (Rockchip RK35xx)
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rockchip64` (Rockchip 64-bit)

**Includes:** Board-specific ARM files + x86 UEFI files with standard arch symlinks

#### All-in-One Bundles

Each variant also has an `-all` version that includes **all** boot files from all variants, with variant-specific symlinks:

- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts-all`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-uefi-all`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711-all`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-meson64-all`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rk35xx-all`
- `ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rockchip64-all`

**Benefit:** Pull once, get all boot files. Symlinks point to the variant-specific defaults.

## Workflows

### Main Workflow: `publish-hook-os-images.yml`

This workflow builds and publishes all Hook OS image variants with proper boot files and architecture symlinks.

**Features:**

- Downloads tar.gz archives from Hook releases
- Extracts kernel and initramfs files
- Creates standard architecture symlinks (`vmlinuz-arm64`, `initramfs-x86_64`, etc.)
- Bundles board-specific variants with x86 UEFI support
- Creates all-in-one variants with all boot files
- Publishes to GHCR with proper OCI annotations
- Shares common layers across variants for efficiency

**Usage:**

```bash
# Publish a specific version
gh workflow run publish-hook-os-images.yml \
  -f hook_version=v0.11.1 \
  -f publish_latest=false

# Publish and tag as latest
gh workflow run publish-hook-os-images.yml \
  -f hook_version=v0.11.1 \
  -f publish_latest=true
```

### Legacy Workflows

- `publish-hook-images.yml` - Simple static archive publishing
- `publish-hook-images-dynamic.yml` - Dynamic archive discovery

These are maintained for simple use cases but don't include the full OS image building logic.

## Using Published Images

### Pull with ORAS

```bash
# Install ORAS
brew install oras  # macOS
# or follow: https://oras.land/docs/installation

# Pull LTS variant
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Pull board-specific variant
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711

# Pull all-in-one bundle
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts-all
```

### Inspect Image Metadata

```bash
# View manifest
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Discover available tags
oras repo tags ghcr.io/tinkerbell-community/hook-images
```

### Use in Tinkerbell Deployments

Images can be mounted as volumes in Kubernetes for Tinkerbell deployments:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hook-os-files
spec:
  initContainers:
  - name: pull-hook-os
    image: ghcr.io/oras-project/oras:latest
    command:
    - oras
    - pull
    - ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts
    volumeMounts:
    - name: hook-files
      mountPath: /output
  volumes:
  - name: hook-files
    emptyDir: {}
```

## Architecture

### Build Process

The main workflow (`publish-hook-os-images.yml`) performs these steps:

1. **Prepare**: Determine version tags and configuration
1. **Build LTS**: Download and extract LTS archives, publish base images
1. **Build Armbian UEFI**: Create UEFI variant with ARM and x86 support
1. **Build Board Variants**: Create board-specific images (bcm2711, meson64, rk35xx, rockchip64)
1. **Build All-in-One**: Create `-all` variants with all boot files and variant-specific symlinks
1. **Publish**: Push all images to GHCR with OCI annotations

### File Structure

Each variant includes:

- **Native boot files**: `vmlinuz-<variant>`, `initramfs-<variant>`
- **Standard symlinks**: `vmlinuz-arm64`, `vmlinuz-aarch64`, `vmlinuz-x86_64`, `initramfs-arm64`, `initramfs-aarch64`, `initramfs-x86_64`
- **Additional files**: `modloop-*` and other variant-specific files

### Symlink Strategy

Standard architecture symlinks point to variant-specific files:

**LTS Variant:**

- `vmlinuz-arm64` → `vmlinuz-aarch64` (native)
- `initramfs-arm64` → `initramfs-aarch64` (native)
- `vmlinuz-x86_64` (native)
- `initramfs-x86_64` (native)

**Board Variants (e.g., bcm2711):**

- `vmlinuz-arm64` → `vmlinuz-armbian-bcm2711-current`
- `initramfs-arm64` → `initramfs-armbian-bcm2711-current`
- `vmlinuz-x86_64` → `vmlinuz-armbian-uefi-x86-edge`
- `initramfs-x86_64` → `initramfs-armbian-uefi-x86-edge`

## OCI Artifact Structure

Each published artifact includes:

- **Artifact Type**: `application/vnd.tinkerbell.hook.os.v1+tar`
- **Media Type**: `application/octet-stream` (for boot files)
- **Annotations**:
  - `org.opencontainers.image.source`: Source repository URL
  - `org.opencontainers.image.version`: Hook version
  - `org.opencontainers.image.description`: Human-readable description
  - `org.tinkerbell.hook.variant`: Variant name (e.g., `lts`, `armbian-bcm2711`, `lts-all`)

### Layer Sharing

Images share common layers when they include the same files:

- All board variants include `vmlinuz-armbian-uefi-x86-edge` and `initramfs-armbian-uefi-x86-edge`
- All `-all` variants include the complete set of LTS and Armbian files
- ORAS efficiently handles layer deduplication

## Local Testing

Use the provided script to build and test variants locally:

```bash
# Build LTS variant
./scripts/build-local.sh v0.11.1 lts

# Build board-specific variant
./scripts/build-local.sh v0.11.1 armbian-bcm2711

# Build all-in-one variant
./scripts/build-local.sh v0.11.1 lts-all
```

The script downloads archives, extracts files, and creates symlinks just like the CI workflow.

## Contributing

To add support for new board variants:

1. Update the matrix in `.github/workflows/publish-hook-os-images.yml`:

   ```yaml
   matrix:
     board:
       - name: bcm2711
         kernel_suffix: current
       - name: new-board      # Add here
         kernel_suffix: edge  # Use appropriate suffix
   ```

1. Update the `build-all-variants` job matrix to include the new variant

1. Add corresponding logic to `scripts/build-local.sh` for local testing

## License

This repository follows the same license as the Tinkerbell project.
