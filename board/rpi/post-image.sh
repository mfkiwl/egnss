#!/bin/bash

# Colours
NC='\e[0m'
INFO='\e[0;36m'
WARN='\e[0;33m'
ERROR='\e[0;31m'

# Take built image and rpi firmware and create bootable image.
IMAGEDIR=$1
ROOTFS=$IMAGEDIR/rootfs.ext4
BOOTDIR=$IMAGEDIR/boot
ROOTDIR=$IMAGEDIR/root

mkdir -p $BOOTDIR
mkdir -p $ROOTDIR

# Name of boot image
BOOTIMG="$IMAGEDIR/boot.img"

# 64M for the boot partition
BOOTSIZE="67108864"
BOOTM="64M"

# Root image already made
ROOTIMG="$ROOTFS"

echo -e ${INFO}Making $BOOTIMG of size $BOOTSIZE${NC}
# Allocate enough for the boot part
$HOST_DIR/usr/bin/fallocate -l $BOOTSIZE "$BOOTIMG"

if [ $? -eq 0 ]; then
    echo -e ${INFO}Making vfat filesystem on $IMG${NC}
    $HOST_DIR/usr/sbin/mkfs.vfat "$BOOTIMG"
fi

if [ $? -eq 0 ]; then
	echo -e ${INFO}Mounting $IMG to $DIR${NC}
    if [ command -v guestmount >/dev/null 2>&1 ]; then
	    guestmount -a "$BOOTIMG" -i --pid-file guestmount.pid "$BOOTDIR"
    else
	    # Fall back to using loop
	    echo -e ${WARN}guestmount not found. Use loop device.${NC}
	    sudo mount -o loop,umask=0  "$BOOTIMG" "$BOOTDIR"
	    sudo chmod -R a+rwx "$BOOTDIR"
	    sleep 1
    fi
fi

if [ $? -ne 0 ]; then
    echo -e ${ERROR}Failed to make image. Exiting.${NC}
    exit 1
fi

# Write firmware
cp $IMAGEDIR/zImage $BOOTDIR/kernel.img
cp $IMAGEDIR/rpi-firmware/bootcode.bin $BOOTDIR
cp $IMAGEDIR/rpi-firmware/start.elf $BOOTDIR
cp $IMAGEDIR/rpi-firmware/fixup.dat $BOOTDIR
cp $IMAGEDIR/rpi-firmware/cmdline.txt $BOOTDIR

# Set the desired config.txt
#  - low gpu mem (video not required)
#  - medium-level overclocking
printf "%s\n" \
"gpu_mem=16" \
"arm_freq=900" \
"core_freq=333" \
"sdram_freq=450" \
"over_voltage=2" > $BOOTDIR/config.txt

sync
if [ command -v guestunmount >/dev/null 2>&1 ]; then
	pid="$(cat guestmount.pid)"
	guestunmount "$BOOTDIR"

	count=10
	while kill -o "$pid" 2>/dev/null && [ $count -gt 0]; do
	    sleep 1
	    ((count--))
	done
	if [ $count -eq 0 ]; then
	    echo -e "${ERROR}timed out waiting for guestmount${NC}"
	    return 1
	fi
else
	sudo umount "$BOOTDIR"
fi
if [ $? -ne 0 ]; then
    echo -e ${ERROR} Failed to unmount image. Exiting. ${NC}
    exit 1
fi

# Name of the image to build
IMAGE="$IMAGEDIR/egnss_rpi_3.19.y_$( date +%Y%m%d ).img"
echo -e ${INFO}Making $IMAGE${NC}

# Make 1 MB for the MBR and partition table
dd if=/dev/zero of=$IMAGE bs=1M count=1
if [ $? -ne 0 ]; then
    echo -e ${ERROR}Failed to write MBR.${NC}
    exit 1
fi

# Concatenate, first parition is boot, then root
# Everything is aligned to 1M
cat $BOOTIMG >> $IMAGE
cat $ROOTIMG >> $IMAGE

echo -e ${INFO}Partioning $IMAGE${NC}
fdisk "$IMAGE" << EOF
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
fdisk -l "$IMAGE"

# DONE
rmdir $BOOTDIR $ROOTDIR
echo -e "${INFO}Image $IMAGE ready${NC}"
