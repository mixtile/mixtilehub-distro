#!/bin/bash
# Quit on error
set -e

# Make sure only root account can run this script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# run in script dir
SCRIPT_DIR="$(dirname "$0")"
cd "$SCRIPT_DIR"

# Usage discription
usage () {
   echo    ""
   echo    "Options:"
   echo    "    -d device"
   echo    "    -i image name [$(find $SCRIPT_DIR/meta-mixtilehub/recipes-core/images/ -name *.bb -type f -printf "%f\n" | cut -f 1 -d '.' | xargs echo)]"
   echo    ""
   echo    "Others:"
   echo    "    -h = This help menu"
}

# Option parsing
while getopts ":hd:i:" opt; do
  case "$opt" in
    d)
      DEVICE="$OPTARG"
      ;;
    i)
      IMAGE="$OPTARG"
      ;;
    h)
      usage
      exit 0
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done


if [ -z "$DEVICE" ]; then
  echo "No devices" 1>&2
  usage
  exit 1
fi

IMG_PATH="$SCRIPT_DIR/build/tmp-glibc/deploy/images/mixtilehub"

BOOTLOADER_FILE="$IMG_PATH/u-boot-sunxi-with-spl.bin"
BOOTSCR_FILE="$IMG_PATH/boot.scr"
UIMAGE_FILE="$IMG_PATH/uImage"
DTB_FILE="$IMG_PATH/sun8i-h3-mixtilehub.dtb"
ROOTFS_FILE="$IMG_PATH/$IMAGE-mixtilehub.tar.gz"

BOOT_PART="$SCRIPT_DIR/p1"
ROOTFS_PART="$SCRIPT_DIR/p2"


if [ ! -e "$BOOTSCR_FILE" ] || [ ! -e "$UIMAGE_FILE" ] || [ ! -e "$DTB_FILE" ] || [ ! -e "$ROOTFS_FILE" ] || [ ! -e "$BOOTLOADER_FILE" ]; then
  echo "Invalid image path" 1>&2
  if [ ! -e "$BOOTSCR_FILE" ]; then
    echo "Can't find '$BOOTSCR_FILE'" 1>&2
  fi
  if [ ! -e "$UIMAGE_FILE" ]; then
    echo "Can't find '$UIMAGE_FILE'" 1>&2
  fi
  if [ ! -e "$DTB_FILE" ]; then
    echo "Can't find '$DTB_FILE'" 1>&2
  fi
  if [ ! -e "$ROOTFS_FILE" ]; then
    echo "Can't find '$ROOTFS_FILE'" 1>&2
  fi
  if [ ! -e "$BOOTLOADER_FILE" ]; then
    echo "Can't find '$BOOTLOADER_FILE'" 1>&2
  fi
  usage
  exit 1
fi

cleanup() {
  echo "Cleaning up..."
  cd "$SCRIPT_DIR"
  rm -rf "$BOOT_PART"
  rm -rf "$ROOTFS_PART"
}

exit_script() {
  echo "Unmounting partitions"
  timeout 5m umount "$DEVICE"? &> /dev/null
  cleanup
  if [ "$1" -ne 0 ]; then
    echo "Fail :(" 1>&2
  else
    echo "Success :)"
  fi
}

trap 'exit_script $?' TERM EXIT INT

echo "Creating partition table..."
timeout 1m umount "$DEVICE"? || echo "Continue..."
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk "${DEVICE}" > /dev/null
  o # New MSDOS partition table
  n # new partition
    # default
    # default
  4096
  45055
  t # partition type
  c # win 95 fat32
  a # bootable
  n # new partition
    # default
    # default
  45056
    # default
  t # partition type
  2 # partition 2
  83 # Linux
  w # write the partition table
EOF
echo -e "Done.\n"

echo "Creating partitions..."
echo "BOOT partition..."
timeout 5m mkfs.vfat -n "mixtilehub" -S 512 "${DEVICE}1" > /dev/null
echo "Rootfs partition..."
timeout 5m mkfs.ext4 -L "rootfs" "${DEVICE}2" > /dev/null
echo -e "Done.\n"

echo "Mounting partitions..."
rm -rf "$BOOT_PART"
rm -rf "$ROOTFS_PART"
mkdir "$BOOT_PART"
mkdir "$ROOTFS_PART"
timeout 1m mount "${DEVICE}1" "$BOOT_PART"
timeout 1m mount "${DEVICE}2" "$ROOTFS_PART"
echo -e "Done.\n"

echo "Installing boot partition..."
rm -rf "${BOOT_PART:?}/"*
cp "$BOOTSCR_FILE" "$BOOT_PART"
cp "$UIMAGE_FILE" "$BOOT_PART"
cp "$DTB_FILE" "$BOOT_PART/sun8i-h3-mixtilehub.dtb"

echo "Extracting rootfs (could take a while)..."
rm -rf "${ROOTFS_PART:?}/"*
timeout 5m tar -xf "$ROOTFS_FILE" -C "$ROOTFS_PART"
timeout 10m sync
  
echo "Writing bootloader..."
timeout 5m dd if="$BOOTLOADER_FILE" of="$DEVICE" bs=1024 seek=8 conv=notrunc

echo -e "Done.\n"
