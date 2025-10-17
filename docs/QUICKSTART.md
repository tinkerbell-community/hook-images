# Quick Start Guide

## Prerequisites

- GitHub repository with Actions enabled
- Access to `ghcr.io` (GitHub Container Registry)
- ORAS CLI installed (for local testing)

## Running the Workflow

### 1. Trigger the Workflow

Navigate to Actions → Publish Hook OS Images → Run workflow

**Inputs:**

- **hook_version:** `v0.11.1` (or any Hook release version)
- **publish_latest:** `false` (or `true` to tag as latest)

### 2. Via GitHub CLI

```bash
gh workflow run publish-hook-os-images.yml \
  -f hook_version=v0.11.1 \
  -f publish_latest=false
```

### 3. Monitor Progress

```bash
# Watch workflow run
gh run watch

# Or list runs
gh run list --workflow=publish-hook-os-images.yml
```

## Using Published Images

### Install ORAS

```bash
# macOS
brew install oras

# Linux
curl -LO https://github.com/oras-project/oras/releases/download/v1.1.0/oras_1.1.0_linux_amd64.tar.gz
tar -xzf oras_1.1.0_linux_amd64.tar.gz
sudo mv oras /usr/local/bin/
```

### Pull an Image

```bash
# Pull LTS variant
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Pull board-specific variant
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711

# Pull all-in-one bundle
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts-all
```

### List Available Tags

```bash
oras repo tags ghcr.io/tinkerbell-community/hook-images
```

### Inspect Image

```bash
# View manifest
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts | jq

# See annotations
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts | \
  jq '.annotations'
```

## Choosing the Right Variant

### Use LTS When

- You want standard Hook OS with stable kernel
- You need basic x86_64 and ARM64 support
- You're not using specific ARM boards

```bash
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts
```

### Use Armbian UEFI When

- You need UEFI boot support
- You're using generic ARM UEFI-capable boards
- You want latest Armbian edge kernels

```bash
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-uefi
```

### Use Board-Specific When

- You're using a specific ARM board (Pi 4, Amlogic, Rockchip)
- You need board-optimized kernels
- You want both ARM board and x86 support

```bash
# Raspberry Pi 4
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711

# Amlogic boards
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-meson64

# Rockchip RK35xx
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rk35xx

# Rockchip 64-bit
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-rockchip64
```

### Use All-in-One When

- You want all boot files in one image
- You're supporting multiple architectures/boards
- You want flexibility to switch variants without re-pulling

```bash
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts-all
```

## File Structure After Pulling

### LTS Variant

```
vmlinuz-aarch64
initramfs-aarch64
vmlinuz-x86_64
initramfs-x86_64
modloop-aarch64
modloop-x86_64
```

### Board Variant (e.g., bcm2711)

```
vmlinuz-armbian-bcm2711-current
initramfs-armbian-bcm2711-current
vmlinuz-armbian-uefi-x86-edge
initramfs-armbian-uefi-x86-edge
vmlinuz-arm64 -> vmlinuz-armbian-bcm2711-current
vmlinuz-aarch64 -> vmlinuz-armbian-bcm2711-current
initramfs-arm64 -> initramfs-armbian-bcm2711-current
initramfs-aarch64 -> initramfs-armbian-bcm2711-current
vmlinuz-x86_64 -> vmlinuz-armbian-uefi-x86-edge
initramfs-x86_64 -> initramfs-armbian-uefi-x86-edge
```

### All-in-One Variant

```
# LTS files
vmlinuz-aarch64
initramfs-aarch64
vmlinuz-x86_64
initramfs-x86_64

# Armbian UEFI files
vmlinuz-armbian-uefi-arm64-edge
initramfs-armbian-uefi-arm64-edge
vmlinuz-armbian-uefi-x86-edge
initramfs-armbian-uefi-x86-edge

# Board-specific files
vmlinuz-armbian-bcm2711-current
initramfs-armbian-bcm2711-current
vmlinuz-armbian-meson64-edge
initramfs-armbian-meson64-edge
vmlinuz-armbian-rk35xx-vendor
initramfs-armbian-rk35xx-vendor
vmlinuz-armbian-rockchip64-edge
initramfs-armbian-rockchip64-edge

# Standard symlinks (point to variant-specific defaults)
vmlinuz-arm64 -> vmlinuz-<variant>
initramfs-arm64 -> initramfs-<variant>
vmlinuz-x86_64 -> vmlinuz-<variant>
initramfs-x86_64 -> initramfs-<variant>
```

## Using in Tinkerbell

### Kubernetes Pod Example

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: hook-boot-files
spec:
  initContainers:
  - name: pull-hook-os
    image: ghcr.io/oras-project/oras:latest
    command:
    - sh
    - -c
    - |
      cd /hook-files
      oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts
    volumeMounts:
    - name: hook-files
      mountPath: /hook-files

  containers:
  - name: tftp-server
    image: your-tftp-server:latest
    volumeMounts:
    - name: hook-files
      mountPath: /tftp/boot
      readOnly: true

  volumes:
  - name: hook-files
    emptyDir: {}
```

### Docker Compose Example

```yaml
version: '3'
services:
  hook-files:
    image: ghcr.io/oras-project/oras:latest
    command:
      - pull
      - ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts
    volumes:
      - hook-files:/output
    working_dir: /output

  tftp:
    image: your-tftp-server:latest
    depends_on:
      - hook-files
    volumes:
      - hook-files:/tftp/boot:ro

volumes:
  hook-files:
```

## Local Testing

### Build Locally

```bash
# Test LTS build
./scripts/build-local.sh v0.11.1 lts

# Test board variant
./scripts/build-local.sh v0.11.1 armbian-bcm2711

# Test all variant
./scripts/build-local.sh v0.11.1 lts-all
```

### Verify Output

```bash
# Check files
ls -lh work/lts/

# Verify symlinks
ls -la work/lts/ | grep '^l'

# Test with local ORAS
cd work/lts
oras push localhost:5000/test:lts \
  $(find . -type f -o -type l | grep -E '(vmlinuz|initramfs)' | \
    sed 's/^\.\///' | xargs -I {} echo "{}:application/octet-stream")
```

## Troubleshooting

### Image Not Found

```bash
# Check if workflow ran successfully
gh run list --workflow=publish-hook-os-images.yml

# View workflow logs
gh run view <run-id> --log
```

### Authentication Required

```bash
# Login to GHCR
echo $GITHUB_TOKEN | oras login ghcr.io -u USERNAME --password-stdin
```

### Wrong Files in Image

```bash
# Inspect manifest to see included files
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts | jq '.layers'
```

## Getting Help

1. **Check Documentation:**

   - `README.md` - General overview
   - `docs/TECHNICAL.md` - Technical details
   - `docs/WORKFLOWS.md` - Workflow architecture

1. **Review Logs:**

   - GitHub Actions workflow logs
   - Local build script output

1. **Test Locally:**

   - Use `scripts/build-local.sh` to reproduce issues

1. **Open Issue:**

   - Provide version, variant, and error logs
   - Include steps to reproduce

## Quick Reference

### Common Commands

```bash
# Trigger workflow
gh workflow run publish-hook-os-images.yml -f hook_version=v0.11.1

# Pull LTS
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Pull board variant
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-armbian-bcm2711

# Pull all-in-one
oras pull ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts-all

# List tags
oras repo tags ghcr.io/tinkerbell-community/hook-images

# Inspect image
oras manifest fetch ghcr.io/tinkerbell-community/hook-images:v0.11.1-lts

# Local build
./scripts/build-local.sh v0.11.1 lts
```

### Available Variants

- `v0.11.1` (default LTS)
- `v0.11.1-lts`
- `v0.11.1-armbian-uefi`
- `v0.11.1-armbian-bcm2711`
- `v0.11.1-armbian-meson64`
- `v0.11.1-armbian-rk35xx`
- `v0.11.1-armbian-rockchip64`
- `v0.11.1-lts-all`
- `v0.11.1-armbian-uefi-all`
- `v0.11.1-armbian-bcm2711-all`
- `v0.11.1-armbian-meson64-all`
- `v0.11.1-armbian-rk35xx-all`
- `v0.11.1-armbian-rockchip64-all`

______________________________________________________________________

**Ready to start?** Run the workflow and pull your first image! 🚀
