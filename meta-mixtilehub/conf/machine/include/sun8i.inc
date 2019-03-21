require conf/machine/include/tune-cortexa7.inc

SOC_FAMILY ??= ""
include conf/machine/include/soc-family.inc

# Sub-architecture support
MACHINE_SOCARCH_SUFFIX ?= ""

PREFERRED_PROVIDER_virtual/xserver = "xserver-xorg"
XSERVER = "xserver-xorg \
           xserver-xorg-module-exa \ 
           xf86-video-armsoc \
	   xf86-input-evdev \
           xf86-input-mouse \
           xf86-input-keyboard"

PREFERRED_PROVIDER_virtual/kernel = "linux-mixtilehub"
PREFERRED_PROVIDER_u-boot = "u-boot-mixtilehub"
PREFERRED_PROVIDER_virtual/bootloader = "u-boot-mixtilehub"

KERNEL_IMAGETYPE ?= "uImage"

IMAGE_FSTYPES += "ext4 tar.gz"

MACHINE_EXTRA_RRECOMMENDS = "kernel-modules"

UBOOT_LOCALVERSION = "-g${@d.getVar('SRCPV', True).partition('+')[2][0:7]}"

UBOOT_ENTRYPOINT ?= "0x40008000"
UBOOT_LOADADDRESS ?= "0x400080OB00"

SERIAL_CONSOLE ?= "115200 ttyS0"
MACHINE_FEATURES ?= "alsa apm keyboard rtc serial screen usbgadget usbhost vfat"

SOC_FAMILY = "sun8i"
