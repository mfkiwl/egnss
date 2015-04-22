#!/bin/bash

# Colours
NC='\e[0m'
INFO='\e[0;36m'
WARN='\e[0;33m'
ERROR='\e[0;31m'


# Take built image and rpi firmware and create bootable image.
IMAGEDIR=$1
ROOTFS=$IMAGEDIR/rootfs.ext4

# Name of boot image
BOOTIMG="$IMAGEDIR/boot.img"

# 64M for the boot partition
BOOTSIZE="67108864"
BOOTM="64M"

# Root image already made
ROOTIMG="$ROOTFS"

echo -e ${INFO} "Making $BOOTIMG of size $BOOTSIZE" ${NC}
# Allocate enough for the boot part
rm -rf "$BOOTIMG"
$HOST_DIR/usr/bin/fallocate -l $BOOTSIZE "$BOOTIMG"

if [ $? -eq 0 ]; then
    echo -e "${INFO}Making vfat filesystem on $BOOTIMG ${NC}"
    $HOST_DIR/usr/sbin/mkfs.vfat "$BOOTIMG"
fi

if [ $? -eq 0 ]; then
    # Set the desired config.txt
    #  - low gpu mem (video not required)
    #  - medium-level overclocking
    #printf "%s\n" \
    #"gpu_mem=16" \
    #"arm_freq=900" \
    #"core_freq=333" \
    #"sdram_freq=450" \
    #"over_voltage=2" \
    #""> $IMAGEDIR/rpi-firmware/config.txt

    # Write firmware
    $HOST_DIR/usr/bin/mcopy -i $BOOTIMG $IMAGEDIR/zImage ::kernel.img
    #$HOST_DIR/usr/bin/mcopy -i $BOOTIMG $IMAGEDIR/rpi-firmware/config.txt ::
    $HOST_DIR/usr/bin/mcopy -i $BOOTIMG \
        $IMAGEDIR/rpi-firmware/bootcode.bin \
        $IMAGEDIR/rpi-firmware/start.elf \
        $IMAGEDIR/rpi-firmware/fixup.dat \
        $IMAGEDIR/rpi-firmware/cmdline.txt ::
fi

if [ $? -ne 0 ]; then
    echo -e ${ERROR}Failed to make boot image. Exiting.${NC}
    exit 1
fi

# Name of the image to build
IMAGE="$IMAGEDIR/egnss_rpi_3.19.y_$( date +%Y%m%d ).img"
echo -e ${INFO}Making $IMAGE of size $IMAGESIZE${NC}

# Make 1 MB for the MBR and partition table
rm -rf "$IMAGE"
$HOST_DIR/usr/bin/fallocate -l 1M "$IMAGE"
if [ $? -ne 0 ]; then
    echo -e ${ERROR}Failed to write MBR.${NC}
    exit 1
fi

# Concatenate, first parition is boot, then root
# Everything is aligned to 1M
cat $BOOTIMG >> $IMAGE
cat $ROOTIMG >> $IMAGE

# Write a parition table which matches the layout of the file
echo -e ${INFO}Partioning $IMAGE${NC}
$HOST_DIR/usr/sbin/fdisk "$IMAGE" << EOF
n
p
1

+$BOOTM
t
c
n
p
2


w
EOF

if [ $? -ne 0 ]; then
    echo -e ${ERROR} Failed to make partitions. Exiting. ${NC}
    exit 1
fi

# Print partition information
$HOST_DIR/usr/sbin/fdisk -l "$IMAGE"

# DONE
echo -e "${INFO}Image $IMAGE ready${NC}"
