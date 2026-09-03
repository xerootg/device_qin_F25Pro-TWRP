#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/qin/F25Pro

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true

# A/B
AB_OTA_UPDATER := true
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot \
    dtbo \
    system \
    system_ext \
    product \
    vendor \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor

# Architecture
TARGET_ARCH := arm64
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := arm64-v8a
TARGET_CPU_ABI2 :=
TARGET_CPU_VARIANT := generic
TARGET_CPU_VARIANT_RUNTIME := cortex-a53

TARGET_2ND_ARCH := arm
TARGET_2ND_ARCH_VARIANT := armv7-a-neon
TARGET_2ND_CPU_ABI := armeabi-v7a
TARGET_2ND_CPU_ABI2 := armeabi
TARGET_2ND_CPU_VARIANT := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a53

# APEX
OVERRIDE_TARGET_FLATTEN_APEX := true

# Bootloader
TARGET_BOOTLOADER_BOARD_NAME := F22Pro
TARGET_NO_BOOTLOADER := true

# Kernel
BOARD_BOOT_HEADER_VERSION := 4
BOARD_BOOTIMG_HEADER_VERSION := $(BOARD_BOOT_HEADER_VERSION)
BOARD_KERNEL_BASE := 0x40078000
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2
BOARD_KERNEL_PAGESIZE := 4096
BOARD_RAMDISK_OFFSET := 0x07c08000
BOARD_KERNEL_TAGS_OFFSET := 0x0bc08000
BOARD_DTB_OFFSET := 0x0bc08000
BOARD_KERNEL_IMAGE_NAME := Image
BOARD_RAMDISK_USE_LZ4 := true
BOARD_INCLUDE_DTB_IN_BOOTIMG := true

BOARD_MKBOOTIMG_ARGS += --ramdisk_offset $(BOARD_RAMDISK_OFFSET)
BOARD_MKBOOTIMG_ARGS += --tags_offset $(BOARD_KERNEL_TAGS_OFFSET)
BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOTIMG_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS += --pagesize $(BOARD_KERNEL_PAGESIZE)
BOARD_MKBOOTIMG_ARGS += --dtb_offset $(BOARD_DTB_OFFSET)

# Kernel - prebuilt (extracted from stock boot_a / vendor_boot_a)
TARGET_NO_KERNEL := false
TARGET_FORCE_PREBUILT_KERNEL := true
ifeq ($(TARGET_FORCE_PREBUILT_KERNEL),true)
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/kernel
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
endif

# Verified Boot
BOARD_AVB_ENABLE := true
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION := 1
BOARD_AVB_VBMETA_VENDOR := vendor
BOARD_AVB_VBMETA_VENDOR_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION := 2
BOARD_AVB_RECOVERY_KEY_PATH := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_RECOVERY_ALGORITHM := SHA256_RSA2048
BOARD_AVB_RECOVERY_ROLLBACK_INDEX := $(PLATFORM_SECURITY_PATCH_TIMESTAMP)
BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION := 3

# System as root
BOARD_SUPPRESS_SECURE_ERASE := true

# Partitions
BOARD_FLASH_BLOCK_SIZE := 262144 # (BOARD_KERNEL_PAGESIZE * 64)
BOARD_BOOTIMAGE_PARTITION_SIZE := 33554432
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_DTBOIMG_PARTITION_SIZE := 8388608
BOARD_SUPER_PARTITION_SIZE := 8589934592
BOARD_SUPER_PARTITION_GROUPS := main
BOARD_MAIN_PARTITION_LIST := system system_ext vendor product
BOARD_MAIN_SIZE := 8585740288

# File systems
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_SYSTEMIMAGE_PARTITION_TYPE := ext4
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

# Workaround for copying error vendor files to recovery ramdisk
TARGET_COPY_OUT_PRODUCT := product
TARGET_COPY_OUT_VENDOR := vendor
TARGET_COPY_OUT_SYSTEM_EXT = system_ext

# SELinux: twrp-14.1's bootable/recovery no longer ships the TWRP
# permissive-recovery policy (twrp.te); without it the A14 policy keeps
# recovery/init/logd enforcing and every TWRP service dies on avc
# denials. recovery_only() keeps this out of normal-boot policy.
BOARD_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy

# Platform
TARGET_BOARD_PLATFORM := mt6768
PRODUCT_PLATFORM := mt6768

# Recovery: stock layout is recovery-in-vendor_boot (boot header v4),
# so TWRP is built into vendor_boot and flashed to the vendor_boot partition.
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_NO_RECOVERY := true
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_USES_METADATA_PARTITION := true
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# system prop
TARGET_SYSTEM_PROP := $(DEVICE_PATH)/system.prop

# Match the running ROM exactly - soft keymaster binds keyblobs to
# os_version/patchlevel, and mismatched values break decrypt with
# KM error -38 (INVALID_ARGUMENT) during keyblob upgrade. The os_version
# half (14) comes from the twrp-14.1 manifest itself.
PLATFORM_SECURITY_PATCH := 2025-05-05
VENDOR_SECURITY_PATCH := 2025-10-05

# TWRP configuration
TW_THEME := portrait_mdpi
TARGET_SCREEN_DENSITY := 240
TW_EXTRA_LANGUAGES := false
TW_SCREEN_BLANK_ON_BOOT := false
TW_INCLUDE_REPACKTOOLS := true
TARGET_USES_MKE2FS := true
TW_FRAMERATE := 60
TW_BRIGHTNESS_PATH := /sys/class/leds/lcd-backlight/brightness
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 128
TW_EXCLUDE_TZDATA := true
TW_EXCLUDE_NANO := true
TW_INCLUDE_DUMLOCK := false
TW_NO_BATT_PERCENT := false
TW_NO_CPU_TEMP := true
TW_NO_DOWNLOAD_MODE := true
TW_NO_FASTBOOT_BOOT := true
TW_INCLUDE_NTFS_3G := false
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_SUPER_SU := true
TW_USE_TOOLBOX := true
TW_USE_FSCRYPT_POLICY := 2

# Storage
RECOVERY_SDCARD_ON_DATA := true
TW_USE_EXTERNAL_STORAGE := true

# Device
TW_DEVICE_VERSION := Qin_F25Pro

# Logging (needed to debug keystore2/decrypt; keep - cheap and useful)
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true

BOARD_USES_MTK_HARDWARE := true

# Decryption
TW_INCLUDE_CRYPTO := true
TW_INCLUDE_CRYPTO_FBE := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_PREPARE_DATA_MEDIA_EARLY := true

# Dynamic partition tools (lptools for super manipulation)
TW_INCLUDE_LPTOOLS := true

# bootctl CLI in recovery for A/B state inspection
TW_RECOVERY_ADDITIONAL_RELINK_BINARY_FILES += $(TARGET_OUT_EXECUTABLES)/bootctl

# Slot B is factory-empty (super_b is zero bytes); activating it strands
# the device until the bootloader retry counter falls back to A. Blocks
# Set_Active_Slot("B") in the patched bootable/recovery.
TW_FORBID_SLOT_B := true
