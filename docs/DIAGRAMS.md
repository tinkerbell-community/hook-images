# Hook OS Images Architecture Diagrams

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     GitHub Actions Workflow                      │
│                  publish-hook-os-images.yml                      │
└─────────────────────────────────────────────────────────────────┘
                              ▼
                    ┌──────────────────┐
                    │   prepare job    │
                    │ • Parse version  │
                    │ • Set variables  │
                    └──────────────────┘
                              ▼
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐   ┌──────────────────┐   ┌────────────────────┐
│  build-lts    │   │build-armbian-uefi│   │build-armbian-boards│
│               │   │                  │   │    (matrix: 4)     │
│ • Download    │   │ • Download       │   │                    │
│ • Extract     │   │ • Extract        │   │ • Download         │
│ • Push        │   │ • Symlink        │   │ • Extract          │
└───────────────┘   │ • Push           │   │ • Symlink          │
                    └──────────────────┘   │ • Push (parallel)  │
                                           └────────────────────┘
                              ▼
                  ┌─────────────────────┐
                  │build-all-variants   │
                  │    (matrix: 6)      │
                  │                     │
                  │ • Download all      │
                  │ • Extract all       │
                  │ • Create symlinks   │
                  │ • Push (parallel)   │
                  └─────────────────────┘
                              ▼
                    ┌──────────────────┐
                    │   summary job    │
                    │ • Report results │
                    └──────────────────┘
```

## Image Variants Structure

```
ghcr.io/tinkerbell-community/hook-images
│
├── v0.11.1 (→ LTS)
├── v0.11.1-lts
│   └── Contains: vmlinuz-{aarch64,x86_64}, initramfs-{aarch64,x86_64}
│
├── v0.11.1-armbian-uefi
│   ├── vmlinuz-armbian-uefi-arm64-edge
│   ├── initramfs-armbian-uefi-arm64-edge
│   ├── vmlinuz-armbian-uefi-x86-edge
│   ├── initramfs-armbian-uefi-x86-edge
│   └── Symlinks: {arm64,aarch64,x86_64} → armbian-uefi-*
│
├── v0.11.1-armbian-bcm2711 (Raspberry Pi 4)
│   ├── vmlinuz-armbian-bcm2711-current
│   ├── initramfs-armbian-bcm2711-current
│   ├── vmlinuz-armbian-uefi-x86-edge
│   ├── initramfs-armbian-uefi-x86-edge
│   └── Symlinks: arm64 → bcm2711, x86_64 → uefi-x86
│
├── v0.11.1-armbian-meson64 (Amlogic)
├── v0.11.1-armbian-rk35xx (Rockchip RK35xx)
├── v0.11.1-armbian-rockchip64 (Rockchip 64-bit)
│
├── v0.11.1-lts-all
│   ├── All LTS files
│   ├── All Armbian files
│   ├── All board files
│   └── Symlinks → LTS defaults
│
├── v0.11.1-armbian-bcm2711-all
│   ├── All LTS files
│   ├── All Armbian files
│   ├── All board files
│   └── Symlinks → bcm2711 + uefi-x86
│
├── ... (other -all variants)
│
├── latest (→ LTS, optional)
└── latest-all (→ LTS-all, optional)
```

## File Flow for Board Variant (Example: bcm2711)

```
┌─────────────────────────────────────────────────────────┐
│         Tinkerbell Hook Release v0.11.1                 │
│         https://github.com/tinkerbell/hook/releases     │
└─────────────────────────────────────────────────────────┘
                          ▼
        ┌─────────────────────────────────────┐
        │      Download Archives              │
        ├─────────────────────────────────────┤
        │ hook_armbian-bcm2711-current.tar.gz │
        │ hook_armbian-uefi-x86-edge.tar.gz   │
        └─────────────────────────────────────┘
                          ▼
              ┌───────────────────┐
              │  Extract Files    │
              └───────────────────┘
                          ▼
        ┌──────────────────────────────────────┐
        │       Extracted Files                │
        ├──────────────────────────────────────┤
        │ vmlinuz-armbian-bcm2711-current      │
        │ initramfs-armbian-bcm2711-current    │
        │ vmlinuz-armbian-uefi-x86-edge        │
        │ initramfs-armbian-uefi-x86-edge      │
        └──────────────────────────────────────┘
                          ▼
            ┌──────────────────────┐
            │  Create Symlinks     │
            └──────────────────────┘
                          ▼
        ┌──────────────────────────────────────┐
        │     Final Bundle Structure           │
        ├──────────────────────────────────────┤
        │ vmlinuz-armbian-bcm2711-current      │
        │ initramfs-armbian-bcm2711-current    │
        │ vmlinuz-armbian-uefi-x86-edge        │
        │ initramfs-armbian-uefi-x86-edge      │
        │                                      │
        │ vmlinuz-arm64 ──┐                    │
        │ vmlinuz-aarch64 ├→ bcm2711-current   │
        │ initramfs-arm64 ──┐                  │
        │ initramfs-aarch64 ├→ bcm2711-current │
        │                                      │
        │ vmlinuz-x86_64 ───→ uefi-x86-edge    │
        │ initramfs-x86_64 ─→ uefi-x86-edge    │
        └──────────────────────────────────────┘
                          ▼
                ┌──────────────┐
                │  Push ORAS   │
                └──────────────┘
                          ▼
        ┌──────────────────────────────────────┐
        │              GHCR                    │
        │ ghcr.io/tinkerbell-community/        │
        │   hook-images:v0.11.1-armbian-bcm2711│
        └──────────────────────────────────────┘
```

## Layer Sharing Across Images

```
┌────────────────────────────────────────────────────────────┐
│                    OCI Registry (GHCR)                     │
└────────────────────────────────────────────────────────────┘
                              │
            ┌─────────────────┼─────────────────┐
            ▼                 ▼                 ▼
      ┌──────────┐      ┌──────────┐     ┌──────────┐
      │   LTS    │      │ bcm2711  │     │ meson64  │
      │  Image   │      │  Image   │     │  Image   │
      └──────────┘      └──────────┘     └──────────┘
            │                 │                 │
            └─────────────────┼─────────────────┘
                              ▼
                    ┌───────────────────┐
                    │  Shared Layers    │
                    ├───────────────────┤
                    │ x86 UEFI files    │
                    │ (deduplicated)    │
                    └───────────────────┘

Storage Efficiency:
• bcm2711 image:   100 MB
• meson64 image:   100 MB
• Total storage:   150 MB (not 200 MB)
  └─ 50 MB of x86 UEFI files shared
```

## Use Case: Tinkerbell Deployment

```
┌────────────────────────────────────────────────────┐
│               Kubernetes Cluster                   │
└────────────────────────────────────────────────────┘
                        ▼
        ┌───────────────────────────────┐
        │     Init Container            │
        │  oras pull ghcr.io/.../lts    │
        └───────────────────────────────┘
                        ▼
                ┌─────────────┐
                │   Volume    │
                │  (emptyDir) │
                └─────────────┘
                        ▼
        ┌───────────────────────────────┐
        │      Main Container           │
        │   (TFTP/HTTP Boot Server)     │
        │                               │
        │  /boot/vmlinuz-x86_64         │
        │  /boot/initramfs-x86_64       │
        │  /boot/vmlinuz-arm64          │
        │  /boot/initramfs-arm64        │
        └───────────────────────────────┘
                        ▼
        ┌───────────────────────────────┐
        │    Bare Metal Machines        │
        │   (Network Boot via TFTP)     │
        │                               │
        │  x86_64 machine  → vmlinuz-   │
        │                     x86_64    │
        │                               │
        │  ARM machine     → vmlinuz-   │
        │                     arm64     │
        └───────────────────────────────┘
```

## Variant Selection Decision Tree

```
                    Start
                      │
                      ▼
          ┌───────────────────────┐
          │ What architecture(s)? │
          └───────────────────────┘
                │           │
        ┌───────┴───┐   ┌──┴────────┐
        ▼           ▼   ▼           ▼
    Generic     Specific  Multiple  Mixed
      │         Board       │        │
      ▼           │         ▼        ▼
   ┌──┴──┐       │     ┌───────┐  ┌─────┐
   ▼     ▼       │     │ -all  │  │-all │
  LTS  UEFI      │     │variant│  │ LTS │
              ┌──┴──┐  └───────┘  └─────┘
              ▼     ▼
           bcm2711  meson64
           rk35xx   rockchip64

Decision Guide:
├─ Generic x86/ARM          → v0.11.1-lts
├─ UEFI-capable boards      → v0.11.1-armbian-uefi
├─ Raspberry Pi 4           → v0.11.1-armbian-bcm2711
├─ Amlogic boards           → v0.11.1-armbian-meson64
├─ Rockchip RK35xx          → v0.11.1-armbian-rk35xx
├─ Rockchip 64-bit          → v0.11.1-armbian-rockchip64
├─ Multiple architectures   → v0.11.1-<variant>-all
└─ Everything, flexible     → v0.11.1-lts-all
```

## Symlink Strategy

```
Board Variant Example (bcm2711):

Physical Files:
├── vmlinuz-armbian-bcm2711-current      ← ARM board kernel
├── initramfs-armbian-bcm2711-current    ← ARM board initramfs
├── vmlinuz-armbian-uefi-x86-edge        ← x86 UEFI kernel
└── initramfs-armbian-uefi-x86-edge      ← x86 UEFI initramfs

Standard Symlinks (for compatibility):
├── vmlinuz-arm64      ──→ vmlinuz-armbian-bcm2711-current
├── vmlinuz-aarch64    ──→ vmlinuz-armbian-bcm2711-current
├── initramfs-arm64    ──→ initramfs-armbian-bcm2711-current
├── initramfs-aarch64  ──→ initramfs-armbian-bcm2711-current
├── vmlinuz-x86_64     ──→ vmlinuz-armbian-uefi-x86-edge
└── initramfs-x86_64   ──→ initramfs-armbian-uefi-x86-edge

Benefit:
• Applications use standard names (vmlinuz-arm64)
• Symlinks point to correct variant files
• Easy to switch variants by pulling different image
```

## Timeline: From Release to Deployment

```
T+0        Tinkerbell Hook Release Published
           └─ v0.11.1 with tar.gz archives
                          ▼
T+1        Trigger GitHub Workflow
           └─ Manual or automated trigger
                          ▼
T+2        Workflow Runs (15-20 minutes)
           ├─ Download archives
           ├─ Extract files
           ├─ Create symlinks
           └─ Push to GHCR
                          ▼
T+20       Images Available in GHCR
           └─ All variants published
                          ▼
T+21       Pull Image
           └─ oras pull ghcr.io/.../lts
                          ▼
T+22       Deploy to Tinkerbell
           └─ Boot files ready for network boot
                          ▼
T+25       Bare Metal Machines Boot
           └─ Network boot using pulled files
```

## Monitoring and Observability

```
┌──────────────────────────────────────────────────┐
│            GitHub Actions Dashboard              │
└──────────────────────────────────────────────────┘
                        ▼
        ┌───────────────────────────────┐
        │     Workflow Run Summary      │
        ├───────────────────────────────┤
        │ ✓ prepare                     │
        │ ✓ build-lts                   │
        │ ✓ build-armbian-uefi          │
        │ ✓ build-armbian-boards (4/4)  │
        │ ✓ build-all-variants (6/6)    │
        │ ✓ summary                     │
        └───────────────────────────────┘
                        ▼
        ┌───────────────────────────────┐
        │      Published Images         │
        ├───────────────────────────────┤
        │ • v0.11.1                     │
        │ • v0.11.1-lts                 │
        │ • v0.11.1-armbian-*           │
        │ • v0.11.1-*-all               │
        └───────────────────────────────┘
                        ▼
        ┌───────────────────────────────┐
        │      Verify in GHCR           │
        │   oras repo tags ghcr.io/...  │
        └───────────────────────────────┘
```

______________________________________________________________________

## Legend

- `▼` : Flow direction
- `→` : Symlink / Reference
- `├─` : Branch / Multiple options
- `└─` : End of branch
- `┌─┐` : Container / Component
- `│` : Vertical connection
- `─` : Horizontal connection
