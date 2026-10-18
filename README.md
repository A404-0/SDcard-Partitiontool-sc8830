# Android SD-Card Boot Partition Tool

This repository contains a shell script for automatic GPT partitioning and formatting of an external MicroSD card. The script is designed to create the necessary partitions for porting and booting Android (e.g., LineageOS) directly from a memory card on legacy devices (such as the Samsung Galaxy Tab E SM-T561).

## Features

* **Auto-size Detection:** Automatically detects the SD card capacity (16GB, 32GB, 64GB+) and applies the appropriate sizes for the system partitions.
* **GPT Partitioning:** Uses `sgdisk` to create a modern and reliable GUID Partition Table.
* **Universal Formatting:** Partitions are formatted to `ext4` using the `make_ext4fs` utility, ensuring compatibility with older TWRP versions.
* **Partition Structure:**
   `ext_system` — System partition (Android OS).
   `ext_data` — User app data.
   `ext_cache` — System cache.
   `ext_media` — Remaining space for media files (in FAT32/vfat format), mounted as standard external storage (`/external_sd`).

## Requirements

* 16 Gb Sdcard and higher

## Usage (via TWRP)

1. Download the script and place it on the device's internal storage (**not** the SD card, as it will be formatted).
2. Insert the MicroSD card into the device.
3. Boot into TWRP Recovery.
4. Go to **Install**.
5. Choose archive and flash it

**Warning:** This script will completely ERASE ALL DATA on your MicroSD card.

## Disclaimer

Use this script at your own risk. The author is not responsible for bricked devices, lost data, or damaged SD cards.
