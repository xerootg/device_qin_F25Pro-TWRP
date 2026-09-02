# TWRP device tree for Qin F25 Pro (F25Pro)

Ported from the Lenovo TB330FU (mt6768) tree. The F25 Pro ships DUOQIN's
F22Pro firmware (`ro.product.device=F22Pro`, board `4313RO_P0`), Android 12,
MediaTek Helio G85 (mt6768).

## Layout

Stock uses boot header v4 with recovery-in-vendor_boot:

- `boot`: kernel + generic ramdisk (leave alone — Magisk lives here)
- `vendor_boot`: dtb + recovery ramdisk — **TWRP is flashed here**

Kernel and dtb under `prebuilt/` are extracted from the stock
`boot_a` / `vendor_boot_a` backups.

## Decryption

FBE (aes-256-xts v2) with metadata encryption; metadata lives on the
`md_udc` partition (per stock `fstab.mt6768`). TEE is TrustKernel:
`teed`, TAs (`vendor/app/t6`, `vendor/thh/ta`), keymaster@4.1 and
gatekeeper@1.0 blobs are bundled from stock vendor and started via
`init.recovery.trustkernel.rc`.

## Building

Use the twrp-12.1 minimal manifest, clone this tree to
`device/qin/F25Pro`, then:

```
lunch twrp_F25Pro-eng
make vendorbootimage
```

## Flashing

```
fastboot flash vendor_boot vendor_boot.img
```

Reboot to recovery (Vol+ at boot / `adb reboot recovery`).
To revert: flash back `vendor_boot_a.bin` from the stock backup.

```
#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
```
