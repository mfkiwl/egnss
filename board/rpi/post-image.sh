#!/bin/sh

# Take built image and rpi firmware and create bootable image.
IMAGEDIR=$1
ROOTFS=$IMAGEDIR/rootfs.tar
BOOTDIR=$IMAGEDIR/boot
ROOTDIR=$IMAGEDIR/root

mkdir -p $BOOTDIR
mkdir -p $ROOTDIR

# 64M for the boot partition
BOOTSIZE="67108864"
BOOTM="64M"

# Estimate the root partition size
ROOTSIZE="`du -b $ROOTFS | cut -f 1 | awk '{print $1 * 2}'`"

make_img () {
    IMG=$1
    SIZE=$2
    DIR=$3
    FS=$4

    echo Making $IMG of size $SIZE

    # Make image here - use quick fallocate if possible
    if [ command -v fallocate >/dev/null 2>&1 ]; then
        fallocate -l $SIZE "$IMG"
    else
        dd if=/dev/zero of="$IMG" bs=1MB count=$SIZE iflag=count_bytes
    fi

    echo Making $FS filesystem on $IMG
    mkfs -t $FS $IMG
}

# Name of boot image
BOOTIMG="$IMAGEDIR/boot.img"
make_img "$BOOTIMG" $BOOTSIZE "$BOOTDIR" vfat

# Mount it, and write firmware
echo Mounting $BOOTIMG to $BOOTDIR
sudo mount -o loop $BOOTIMG $BOOTDIR

sudo cp $IMAGEDIR/zImage $BOOTDIR/kernel.img
sudo cp $IMAGEDIR/rpi-firmware/bootcode.bin $BOOTDIR
sudo cp $IMAGEDIR/rpi-firmware/start.elf $BOOTDIR
sudo cp $IMAGEDIR/rpi-firmware/fixup.dat $BOOTDIR
sudo cp $IMAGEDIR/rpi-firmware/cmdline.txt $BOOTDIR

echo Unmounting $BOOTDIR
sudo umount $BOOTDIR

#OK, now make to the root filesystem
# Name of root image
ROOTIMG="$IMAGEDIR/root.img"
make_img "$ROOTIMG" $ROOTSIZE "$ROOTDIR" ext4

# Mount it and unpack the root filesystem
echo Mounting $ROOTIMG to $ROOTDIR
sudo mount -o loop $ROOTIMG $ROOTDIR
sudo tar -xf $IMAGEDIR/rootfs.tar -C $ROOTDIR

echo Unmounting $ROOTDIR
sudo umount $ROOTDIR

# Name of the image to build
IMAGE="$IMAGEDIR/egnss_rpi_3.19.y_$( date +%Y%m%d ).img"
echo Making $IMAGE of size $IMAGESIZE

# Make 1 MB for the MBR and partition table
dd if=/dev/zero of=$IMAGE bs=1M count=1

# Concatenate
cat $BOOTIMG >> $IMAGE
cat $ROOTIMG >> $IMAGE

echo Partioning $IMAGE
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

fdisk -l "$IMAGE"

# DONE
rmdir $BOOTDIR $ROOTDIR
echo "Image $IMAGE ready"
