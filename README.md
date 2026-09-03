# TWRP device tree for Qin F25 Pro (F25Pro)

Ported from the Lenovo TB330FU (mt6768) tree. The F25 Pro ships DUOQIN's
F22Pro firmware (`ro.product.device=F22Pro`, board `4313RO_P0`): an
Android 14 system (SDK 34) on an Android 12-era vendor (VNDK 31),
kernel 5.10.209, MediaTek Helio G85 (mt6768), eMMC.

CI builds and releases a `vendor_boot.img` on every push
(see the Releases page).

## Feature matrix

| Feature | Status |
| --- | --- |
| FBE decrypt (metadata + user 0, default password) | working |
| Touch, display, correct colors | working |
| Backup / restore (byte-exact round-trip verified) | working |
| MTP (FunctionFS; kernel has no legacy f_mtp) | working |
| adb + adb sideload | working |
| Magisk zip install (apk renamed to .zip) | working |
| Vibration / haptics | working |
| Slot switching | intentionally blocked (see A/B notes) |
| CPU temperature display | disabled (thermal driver is a vendor module not loaded in recovery) |
| External SD / USB-OTG | untested |

## Layout

Stock uses boot header v4 with recovery-in-vendor_boot:

- `boot`: kernel + generic ramdisk (leave alone — Magisk lives here)
- `vendor_boot`: dtb + recovery ramdisk — **TWRP is flashed here**

Kernel and dtb under `prebuilt/` are extracted from the stock
`boot_a` / `vendor_boot_a`.

## A/B notes — read before touching slots

This device is A/B, but **slot B is empty from the factory** (`super_b`
is zero bytes). Booting slot B means no vendor/system and a bootloop
until the bootloader's retry counter falls back to A.

The stock boot-control HAL's boot-region switch is UFS-only code and
always fails on this eMMC device — but stock ordering flipped the misc
bootctrl metadata *before* failing, so a slot switch from TWRP would
strand the device on B anyway. This tree reorders the HAL
(`bootctrl/BootControl.cpp`) so the switch fails *before* misc is
touched: selecting slot B in TWRP now reports an error and changes
nothing. A `bootctl` CLI is included in the recovery shell for
inspecting A/B state.

## Decryption

FBE (aes-256-xts / aes-256-cts:v2) with metadata encryption; metadata
lives on the `md_udc` partition (per stock `fstab.mt6768`). Keyblobs are
bound to the ROM's os_version/patch level, which is why the build must
be based on twrp-14.1 and pin the security-patch values in
`BoardConfig.mk` — a mismatch fails with keymaster error -38/-33.

This ROM uses **software keymaster** (generic
`android.hardware.keymaster@4.1-service`, no TEE) and SoftGatekeeper,
both bundled from the ROM vendor image and started from
`init.recovery.mt6768.rc`.

## Building

Use the **twrp-14.1** minimal manifest, clone this tree to
`device/qin/F25Pro`, apply the bootable/recovery patch, then build:

```
git -C bootable/recovery apply device/qin/F25Pro/patches/bootable-recovery-twrp-14.1.patch
source build/envsetup.sh
lunch twrp_F25Pro-ap2a-eng
make vendorbootimage
```

The patch fixes android-14.1 TWRP source against android-14.1 AOSP:
renamed AIDL NDK libs, the removed vold fscrypt_policy union, new
libvold link dependencies, removed FDE cryptfs API, hwservicemanager's
move to system_ext, missing keystore2/keymint NDK libs in the ramdisk,
and an argument-order bug that broke metadata decrypt
(`fscrypt_mount_metadata_encrypted` zoned_device).

## Flashing

```
fastboot flash vendor_boot_a vendor_boot.img
```

Reboot to recovery (Vol+ at boot / `adb reboot recovery`).
To revert: flash the stock ROM's `vendor_boot.img`.
