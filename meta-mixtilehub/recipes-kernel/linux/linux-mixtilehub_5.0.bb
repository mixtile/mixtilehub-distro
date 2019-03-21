require linux-mixtilehub.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/${PN}pc-${PV}:"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

COMPATIBLE_MACHINE = "^mixtilehub$"

SRCREV = "1c163f4c7b3f621efff9b28a47abb36f7378d783"

SRC_URI = " \
  git://github.com/torvalds/linux.git;protocol=git;branch=master \
  file://defconfig \
  file://0001-mixtilehub.patch \
"
