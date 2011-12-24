#!/bin/bash
#
# create_boot.img.sh
#
#
# 2011 nubecoder
# http://www.nubecoder.com/
#

#defines
KERNEL_PATH="$PWD/zImage"
RECOVERY_INITRD="$PWD/initramfs_cwm"
#default to cm
KERNEL_INITRD="$PWD/initramfs_cm"

#function
function PACKAGE_BOOTIMG()
{
	if [ "$1" = "" ] || [ "$2" = "" ]  || [ "$3" = "" ] ; then
		ERROR_MSG="Error: PACKAGE_BOOTIMG - Missing args!"
		return 1
	fi
	if [ ! -f "$1" ] ; then
		ERROR_MSG="Error: PACKAGE_BOOTIMG - zImage does not exist!"
		return 2
	else
		local KERNEL_INITRD="$2"
		local RECOVERY_INITRD="$3"
		echo "create ramdisk.img"
		mkbootfs $KERNEL_INITRD | minigzip > ramdisk-kernel.img
		echo "create ramdisk-recovery.img"
		mkbootfs $RECOVERY_INITRD > ramdisk-recovery.cpio
		minigzip < ramdisk-recovery.cpio > ramdisk-recovery.img
		if [ -f boot.img ] ; then
			echo "removing old boot.img"
			rm -f boot.img
		fi
		echo "create boot.img"
		./mkshbootimg.py boot.img zImage ramdisk-kernel.img ramdisk-recovery.img
		echo "cleaning up temp files:"
		echo "* rm -f ramdisk-kernel.img"
		rm -f ramdisk-kernel.img
		echo "* rm -f ramdisk-recovery.cpio"
		rm -f ramdisk-recovery.cpio
		echo "* rm -f ramdisk-recovery.img"
		rm -f ramdisk-recovery.img
	fi
	return 0
}

#main
if [ "$1" = "tw" ]; then
	KERNEL_INITRD="$PWD/initramfs_tw"
elif [ "$1" = "cm" ]; then
	KERNEL_INITRD="$PWD/initramfs_cm7"
else
	echo "usage: $0 <tw|cm>"
	exit
fi

PACKAGE_BOOTIMG "$KERNEL_PATH" "$KERNEL_INITRD" "$RECOVERY_INITRD"
if [ $? != 0 ] ; then
	echo "$ERROR_MSG"
else
	echo "boot.img created successfully"
fi
exit

