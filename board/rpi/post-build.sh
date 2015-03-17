TARGETDIR=$1
BR_ROOT=$PWD

# Create /boot
install -d -m 0755 $TARGETDIR/boot

# Mount /boot
install -T -m 0644 $BR_ROOT/system/skeleton/etc/fstab $TARGETDIR/etc/fstab
echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> $TARGETDIR/etc/fstab
