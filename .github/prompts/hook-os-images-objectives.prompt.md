---
mode: agent
---
# Goals

Create OCI images for Hook OS images that include all necessary boot files and symbolic links for standard architectures.

The goal is to produce images that can be pulled from GitHub Container Registry (GHCR) for various Hook OS images, ensuring compatibility with standard architecture naming conventions.

We will load these as volumes in Tinkerbell deployments.

## Objectives

Create a Github workflow that uses:
```
- uses: oras-project/setup-oras@v1
```
The workflow should leverage ORAS to extract all '*.tar.xz'  releases in https://github.com/tinkerbell/hook/releases/tag/v0.11.1 - using a provided hook version in the workflow. It should publish an OCI image to the ghcr.io registry of this project like:

- ghcr.io/${{ github.repository }}:latest
- ghcr.io/${{ github.repository }}:latest-all
- ghcr.io/${{ github.repository }}:latest-lts
- ghcr.io/${{ github.repository }}:latest-lts-all
- ghcr.io/${{ github.repository }}:v0.11.1
- ghcr.io/${{ github.repository }}:v0.11.1-all
- ghcr.io/${{ github.repository }}:v0.11.1-lts
- ghcr.io/${{ github.repository }}:v0.11.1-lts-all
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-uefi
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-uefi-all
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-bcm2711
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-bcm2711-all
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-meson64
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-meson64-all
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-rk35xx
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-rk35xx-all
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-rockchip64
- ghcr.io/${{ github.repository }}:v0.11.1-armbian-rockchip64-all

etc, for each archive name - where archive represents an image kind

The default, non-suffixed image should symlink to the extracted lts archives:

- hook_latest-lts-aarch64.tar.gz
- hook_latest-lts-x86_64.tar.gz

These archives will export (which will not need to be symlinked):
- vmlinuz-aarch64
- initramfs-aarch64
- vmlinuz-x86_64
- initramfs-x86_64



## Guidelines

Next, let's edit the logic to use the following naming convention:

For the files:

- hook_armbian-uefi-arm64-edge.tar.gz
- hook_armbian-uefi-x86-edge.tar.gz

You would create an image named:

`ghcr.io/${{ github.repository }}:v0.11.1-armbian-uefi`

There are also 3 board flavors of arbian including:

- hook_armbian-bcm2711-current.tar.gz
- hook_armbian-meson64-edge.tar.gz
- hook_armbian-rk35xx-vendor.tar.gz
- hook_armbian-rockchip64-edge.tar.gz

For each of these, you will create a tag matching:

`ghcr.io/${{ github.repository }}:v0.11.1-armbian-bcm2711`
`ghcr.io/${{ github.repository }}:v0.11.1-armbian-meson64`
`ghcr.io/${{ github.repository }}:v0.11.1-armbian-rk35xx`
`ghcr.io/${{ github.repository }}:v0.11.1-armbian-rockchip64`

In these bundles, we will need **both** the `hook_armbian-${board}-current.tar.gz` and `hook_armbian-uefi-x86-edge.tar.gz` to be included.

For every bundle, you will need to append the resulting kernel, initramfs, and extra files from the target archives **as well as** symbolic links for standard arch names.

We will also want images for each variant with the suffix `-all` that includes all the above images in a single bundle.
The difference for each all image is which files are symbolic linked to the standard names.

For example, for the `ghcr.io/${{ github.repository }}:v0.11.1-armbian-bcm2711-all` image, the symbolic links would be:
> **Note:** We will remove the current suffix from the board name for the version and symbolic links. The download path includes the suffix current for this instance.
- `vmlinuz-arm64` -> `vmlinuz-armbian-bcm2711-current`
- `initramfs-arm64` -> `initramfs-armbian-bcm2711-current`
- `vmlinuz-x86_64` -> `vmlinuz-armbian-uefi-x86-edge`
- `initramfs-x86_64` -> `initramfs-armbian-uefi-x86-edge`

## Tasks

- [ ] Create GitHub Actions workflow to automate the above process.
- [ ] Ensure that all images share common shareable layers using ORAS.
- [ ] Ensure proper tagging and versioning of the images.
