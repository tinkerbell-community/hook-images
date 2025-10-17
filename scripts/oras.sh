#!/usr/bin/env bash

images=(
  hook_armbian-bcm2711-current
  hook_armbian-meson64-edge
  hook_armbian-rk35xx-vendor
  hook_armbian-rockchip64-edge
  hook_armbian-uefi-arm64-edge
  hook_armbian-uefi-x86-edge
)
repository="https://github.com/tinkerbell/hook"
version="v0.11.1"

mkdir -p downloads

for image in "${images[@]}"; do
  echo "Downloading ${image}.tar.xz..."
  curl -sLO "${repository}/releases/download/${version}/${image}.tar.xz" | tar xzv - --strip-components=1 -C downloads/
done
