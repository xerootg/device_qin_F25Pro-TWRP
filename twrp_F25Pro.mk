#
# Copyright (C) 2024 The Android Open Source Project
# Copyright (C) 2024 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)

# Installs gsi keys into ramdisk, to boot a developer GSI with verified boot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/gsi_keys.mk)

# Inherit some common TWRP stuff.
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit from F25Pro device
$(call inherit-product, device/qin/F25Pro/device.mk)

PRODUCT_DEVICE := F25Pro
PRODUCT_NAME := twrp_F25Pro
PRODUCT_BRAND := QIN
PRODUCT_MODEL := Qin F25 Pro
PRODUCT_MANUFACTURER := DUOQIN

PRODUCT_GMS_CLIENTID_BASE := android-duoqin
