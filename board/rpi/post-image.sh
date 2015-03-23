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

# 64M for the boot partition
BOOTSIZE="67108864"
BOOTM="64M"

# Estimate the root partition size
ROOTSIZE="`du -b $ROOTFS | cut -f 1 | awk '{print $1 * 2}'`"

unmount_img() {
    sync
    if [ command -v guestunmount >/dev/null 2>&1 ]; then
	pid="$(cat guestmount.pid)"
	guestunmount "$1"

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
	sudo umount "$1"
    fi
}

mount_img() {
    IMG=$1
    DIR=$2
    ARGS=$3

    if [ command -v guestmount >/dev/null 2>&1 ]; then
	guestmount -a "$IMG" -i --pid-file guestmount.pid "$DIR"
    else
	# Fall back to using loop
	echo -e ${WARN}guestmount not found. Use loop device.${NC}
	sudo mount -o loop,owner,dev,suid,user,$ARGS  "$IMG" "$DIR"
	sudo chmod -R a+rwx "$DIR"
	sleep 1
    fi
}

make_img () {
    IMG=$1
    SIZE=$2
    DIR=$3
    FS=$4
    MKFS_ARGS=$5
    MNT_ARGS=$6

    echo -e ${INFO}Making $IMG of size $SIZE${NC}

    # Make image here - use quick fallocate if possible
    $HOST_DIR/usr/bin/fallocate -l $SIZE "$IMG"

    if [ $? -eq 0 ]; then
	echo -e ${INFO}Making $FS filesystem on $IMG${NC}
	mkfs -t $FS $MKFS_ARGS "$IMG"
    fi

    if [ $? -eq 0 ]; then
	echo -e ${INFO}Mounting $IMG to $DIR${NC}
	mount_img "$IMG" "$DIR" "$MNT_ARGS"
    fi
}


# Name of boot image
BOOTIMG="$IMAGEDIR/boot.img"
make_img "$BOOTIMG" $BOOTSIZE "$BOOTDIR" vfat "" umask=0
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

unmount_img $BOOTDIR
if [ $? -ne 0 ]; then
    echo -e ${ERROR} Failed to unmount image. Exiting. ${NC}
    exit 1
fi

#OK, now make the root filesystem
ROOTIMG="$ROOTFS"

# Name of the image to build
IMAGE="$IMAGEDIR/egnss_rpi_3.19.y_$( date +%Y%m%d ).img"
echo -e ${INFO}Making $IMAGE of size $IMAGESIZE${NC}

# Make 1 MB for the MBR and partition table
dd if=/dev/zero of=$IMAGE bs=1M count=1
if [ $? -ne 0 ]; then
    echo -e ${ERROR} Failed to write MBR. ${NC}
    exit 1
fi

# Concatenate
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

fdisk -l "$IMAGE"

# DONE
rmdir $BOOTDIR $ROOTDIR
echo -e "${INFO}Image $IMAGE ready${NC}"
