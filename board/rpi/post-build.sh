TARGETDIR=$1
BOOTDIR=$TARGETDIR/boot
BR_ROOT=$PWD

# Create /boot
install -d -m 0755 $BOOTDIR

# Mount /boot
install -T -m 0644 $BR_ROOT/system/skeleton/etc/fstab $TARGETDIR/etc/fstab
echo '/dev/mmcblk0p1 /boot vfat defaults 0 0' >> $TARGETDIR/etc/fstab

# Set the desired config.txt

#  low gpu mem (video not required)
#  medium-level overclocking
mkdir -p $BINARIES_DIR/rpi-firmware
printf "%s\n" \
"gpu_mem=16" \
"arm_freq=900" \
"core_freq=333" \
"sdram_freq=450" \
"over_voltage=2" > $BINARIES_DIR/rpi-firmware/config.txt
