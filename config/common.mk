PRODUCT_BRAND ?= mokee

# Odex support for official releases 
ifdef MK_RELEASE
WITH_DEXPREOPT := true
endif

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

MOKEEHELPER_EMBEDDED := true
MOKEEHELPER_PACKAGE_PREFIX := com.android.settings.mokee.mokeehelper

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/mk/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/mk/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/mk/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Copy over the changelog to the device
PRODUCT_COPY_FILES += \
    vendor/mk/CHANGELOG.mkdn:system/etc/CHANGELOG-MK.txt

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/mk/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/mk/prebuilt/common/bin/50-mk.sh:system/addon.d/50-mk.sh \
    vendor/mk/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/mk/prebuilt/common/bin/sysinit:system/bin/sysinit

# userinit support
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# SELinux filesystem labels
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/etc/init.d/50selinuxrelabel:system/etc/init.d/50selinuxrelabel

# MK-specific init file
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/etc/init.local.rc:root/init.mk.rc

# MoKee prebuilts
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/ota/verifier:system/bin/verifier \
    vendor/mk/prebuilt/common/lib/libbdpush_V1_0.so:system/lib/libbdpush_V1_0.so \
    vendor/mk/prebuilt/common/app/GooglePinyinIME.apk:system/app/GooglePinyinIME.apk \
    vendor/mk/prebuilt/common/lib/libgnustl_shared.so:system/lib/libgnustl_shared.so \
    vendor/mk/prebuilt/common/lib/libhwr.so:system/lib/libhwr.so \
    vendor/mk/prebuilt/common/lib/libjni_delight.so:system/lib/libjni_delight.so \
    vendor/mk/prebuilt/common/lib/libjni_googlepinyinime_latinime_5.so:system/lib/libjni_googlepinyinime_latinime_5.so \
    vendor/mk/prebuilt/common/lib/libjni_hmm_shared_engine.so:system/lib/libjni_hmm_shared_engine.so \
    vendor/mk/prebuilt/common/lib/libpinyin_data_bundle.so:system/lib/libpinyin_data_bundle.so

# MoKee prebuilts
PRODUCT_COPY_FILES += \
    vendor/mk/prebuilt/common/app/RootExplorer.apk:system/app/RootExplorer.apk \
    vendor/mk/prebuilt/common/app/Sweep2Wake.apk:system/app/Sweep2Wake.apk

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/mk/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/mk/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is MK!
PRODUCT_COPY_FILES += \
    vendor/mk/config/permissions/com.mokee.android.xml:system/etc/permissions/com.mokee.android.xml

# T-Mobile theme engine
include vendor/mk/config/themes_common.mk

# Required MK packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt

# Optional MK packages
PRODUCT_PACKAGES += \
    VoicePlus \
    Basic \
    libemoji

# Custom MK packages

# MoKee PhoneLoc Database
PRODUCT_COPY_FILES +=  \
    vendor/mk/prebuilt/common/media/mokee-phoneloc.dat:system/media/mokee-phoneloc.dat

PRODUCT_PACKAGES += \
    Launcher3 \
    MoKeeLauncher \
    DSPManager \
    libcyanogen-dsp \
    libscreenrecorder \
    audio_effects.conf \
    Apollo \
    LockClock \
    MoKeeHelper \
    MoKeeScreenRecorder \
    MoKeeSetupWizard

# MK Hardware Abstraction Framework
PRODUCT_PACKAGES += \
    org.mokee.hardware \
    org.mokee.hardware.xml

# Extra tools in MK
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# These packages are excluded from user builds
ifneq ($(TARGET_BUILD_VARIANT),user)

PRODUCT_PACKAGES += \
    procmem \
    procrank \
    Superuser \
    su

# Terminal Emulator
PRODUCT_COPY_FILES +=  \
    vendor/mk/proprietary/Term.apk:system/app/Term.apk \
    vendor/mk/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=1
else

PRODUCT_PROPERTY_OVERRIDES += \
    persist.sys.root_access=0

endif

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/mk/overlay/common

PRODUCT_VERSION_MAJOR = 44
PRODUCT_VERSION_MINOR = 2
PRODUCT_VERSION_MAINTENANCE = 0

# Set MK_BUILDTYPE
ifneq ($(filter mokee mokee-0x02,$(shell hostname)),)

MK_BUILDTYPE := EXPERIMENTAL
    ifdef MK_NIGHTLY
        MK_BUILDTYPE := NIGHTLY
    endif
    ifdef MK_EXPERIMENTAL
        MK_BUILDTYPE := EXPERIMENTAL
    endif
    ifdef MK_RELEASE
        MK_BUILDTYPE := RELEASE
    endif
endif

ifdef MK_BUILDTYPE
    ifdef MK_EXTRAVERSION
        # Force build type to EXPERIMENTAL
        MK_BUILDTYPE := EXPERIMENTAL
        # Remove leading dash from MK_EXTRAVERSION
        MK_EXTRAVERSION := $(shell echo $(MK_EXTRAVERSION) | sed 's/-//')
        # Add leading dash to MK_EXTRAVERSION
        MK_EXTRAVERSION := -$(MK_EXTRAVERSION)
    endif
else
    # If MK_BUILDTYPE is not defined, set to UNOFFICIAL
    MK_BUILDTYPE := UNOFFICIAL
    MK_EXTRAVERSION :=
endif

ifeq ($(MK_BUILDTYPE), RELEASE)
    MK_VERSION := MK$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(MK_BUILD)-$(shell date +%y%m%d)-RELEASE
else
    MK_VERSION := MK$(PRODUCT_VERSION_MAJOR).$(PRODUCT_VERSION_MINOR)-$(MK_BUILD)-$(shell date +%Y%m%d%H%M)-$(MK_BUILDTYPE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
  ro.mk.support=bbs.mfunz.com \
  ro.mk.version=$(MK_VERSION) \
  ro.modversion=$(MK_VERSION)

-include vendor/cm-priv/keys/keys.mk

-include $(WORKSPACE)/build-env/image-auto-bits.mk

-include vendor/cyngn/product.mk
