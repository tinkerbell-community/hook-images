# ipmitool Binary

This directory contains the configuration to build and publish a statically compiled, multi-architecture `ipmitool` binary.

## Overview

The workflow builds a minimal container image containing only the `ipmitool` binary, compiled statically from the [ipmitool/ipmitool](https://github.com/ipmitool/ipmitool) repository.

## Image Details

- **Registry**: `ghcr.io/tinkerbell-community/hook-images/ipmitool`
- **Architectures**: `linux/amd64`, `linux/arm64`
- **Base**: `scratch` (minimal image with only the binary)
- **Binary**: Statically linked with musl libc (no dependencies)

## Usage

### Pull and Run

```bash
# Show version
docker run --rm ghcr.io/tinkerbell-community/hook-images/ipmitool:latest -V

# Run ipmitool command
docker run --rm --network host ghcr.io/tinkerbell-community/hook-images/ipmitool:latest \
  -I lanplus -H <BMC_IP> -U <USER> -P <PASS> chassis status
```

### Extract Binary

```bash
# Create container
docker create --name ipmitool ghcr.io/tinkerbell-community/hook-images/ipmitool:latest

# Copy binary
docker cp ipmitool:/ipmitool ./ipmitool

# Cleanup
docker rm ipmitool

# Make executable and run
chmod +x ./ipmitool
./ipmitool -V
```

### Use in Another Dockerfile

```dockerfile
FROM ghcr.io/tinkerbell-community/hook-images/ipmitool:latest AS ipmitool
FROM alpine:3.20
COPY --from=ipmitool /ipmitool /usr/local/bin/ipmitool
```

## Building Locally

```bash
# Build for your architecture
docker build -f Dockerfile.ipmitool -t ipmitool:local .

# Build multi-arch
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -f Dockerfile.ipmitool \
  -t ipmitool:local .
```

## Triggering the Workflow

The workflow runs automatically on:

- Pushes to `main` branch (when Dockerfile or workflow changes)
- Pull requests (when Dockerfile or workflow changes)
- Manual dispatch via GitHub Actions UI

To manually trigger:

```bash
gh workflow run publish-ipmitool.yml
```

## Technical Details

### Build Process

1. Uses Alpine Linux as build environment (musl libc for static linking)
2. Clones latest ipmitool from GitHub
3. Compiles with `--enable-static --disable-shared` and `LDFLAGS="-static"`
4. Strips debug symbols for smaller binary size
5. Verifies binary is truly static (no dynamic dependencies)
6. Copies to minimal `scratch` base image

### Static Linking

The binary is statically linked with:

- musl libc
- OpenSSL (static)
- readline (static)
- ncurses (static)
- zlib (static)

This ensures the binary has no runtime dependencies and can run in any Linux environment, including minimal containers or rescue environments.

### Why Static?

- **Portability**: Runs anywhere without dependencies
- **Minimal Size**: Final image contains only the binary
- **Rescue Scenarios**: Perfect for bare metal provisioning and recovery
- **No Library Conflicts**: Self-contained executable

## Verification

After building, the workflow:

1. Verifies the binary is statically linked
2. Tests the binary can execute (`ipmitool -V`)
3. Publishes to GitHub Container Registry

## Image Tags

- `latest`: Latest build from main branch
- `main-<sha>`: Specific commit from main branch
- `pr-<number>`: Pull request builds (not pushed)
