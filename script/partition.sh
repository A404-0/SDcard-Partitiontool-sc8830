#!/sbin/sh

SDCARD="/dev/block/mmcblk1"
EXT_SYSTEM="${SDCARD}p1"
EXT_DATA="${SDCARD}p2"
EXT_CACHE="${SDCARD}p3"
EXT_MEDIA="${SDCARD}p4"

if [ ! -b "$SDCARD" ]; then
    echo "Error: SD card ($SDCARD) not found."
    exit 1
fi

echo "Detecting SD card size..."
SECTORS=$(cat /sys/block/mmcblk1/size 2>/dev/null)
if [ -z "$SECTORS" ]; then
    echo "Warning: Could not read size. Defaulting to 16GB profile."
    GB=15
else
    BYTES=$((SECTORS * 512))
    GB=$((BYTES / 1000000000))
fi
echo "Detected total size: ~${GB} GB"

if [ "$GB" -lt 24 ]; then
    echo "Profile selected: 16GB Card"
    SIZE_SYSTEM="+3500M"
    SIZE_DATA="+5000M"
    SIZE_CACHE="+500M"
elif [ "$GB" -lt 48 ]; then
    echo "Profile selected: 32GB Card"
    SIZE_SYSTEM="+4000M"
    SIZE_DATA="+12000M"
    SIZE_CACHE="+1000M"
else
    echo "Profile selected: 64GB+ Card"
    SIZE_SYSTEM="+5000M"
    SIZE_DATA="+24000M"
    SIZE_CACHE="+1000M"
fi

echo "Unmounting SD card partitions if mounted..."
umount ${SDCARD}* 2>/dev/null

echo "Partitioning the SD card (GPT)..."

sgdisk --zap-all $SDCARD
sgdisk --new=1:0:$SIZE_SYSTEM --change-name=1:ext_system $SDCARD
sgdisk --new=2:0:$SIZE_DATA --change-name=2:ext_data $SDCARD
sgdisk --new=3:0:$SIZE_CACHE --change-name=3:ext_cache $SDCARD
sgdisk --new=4:0:0 --change-name=4:ext_media --typecode=4:0700 $SDCARD

echo "Synchronizing partition table..."
partprobe $SDCARD 2>/dev/null || blockdev --rereadpt $SDCARD 2>/dev/null || sync
sleep 3

echo "Formatting partitions using make_ext4fs..."
make_ext4fs -L ext_system $EXT_SYSTEM
make_ext4fs -L ext_data $EXT_DATA
make_ext4fs -L ext_cache $EXT_CACHE

echo "Formatting media partition..."
if command -v mkfs.fat >/dev/null 2>&1; then
    mkfs.fat -n EXT_MEDIA -F 32 $EXT_MEDIA
else
    mkdosfs -n EXT_MEDIA -F 32 $EXT_MEDIA
fi

echo "=== Done! ==="
echo "Partitions successfully created in GPT format."
