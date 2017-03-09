#!/bin/bash
if [ $(id -u) -ne 0 ]; then
	echo "This script must be run as root"
	exit 1
fi

PROG_DIR=$(readlink -e $(dirname $0))
. ${PROG_DIR}/config.sh

EFI_PARTITION=${USBDEV}1
MOUNT_DIR="/media/${MOUNT_DIR}"

create_and_mount_vfat()
{
	echo "Contents of this device will be erased: $USBDEV"
	echo "Press CTRL-C to abort RETURN to continue"
	read a
	sudo sgdisk --zap-all ${USBDEV}
	# Update kernel's view of the devices partitions (lack of them)
	sudo partprobe
	# Create a single EFI partition covering the whole disk
	# TODO Create a partition of a given size,leaving space
	#      that can be used for other purposes
	sudo sgdisk --new=1:0:0 --typecode=1:ef00 ${USBDEV}
	# Update kernel's view of the devices partitions (newly created)
	sudo partprobe
	# Format EFI System Patrition as vfat
	sudo mkfs.vfat -F32 -n "${LABEL}" $EFI_PARTITION
	make_dir "${MOUNT_DIR}"
	sudo mount -t vfat $EFI_PARTITION ${MOUNT_DIR}
}



copy_drive_contents()
{
	if [ ! -d "$1"]; then
		echo "Not a directory: $1"
		exit 1
	fi
	echo "Copying from source_dir ${BUILD_DIR}/template/."
	cp -rv "${BUILD_DIR}/template/." "${MOUNT_DIR}/."
}



# ------------------------------------------------------------------------
# Actual action after this
# ------------------------------------------------------------------------

create_and_mount_vfat
copy_drive_contents

sudo umount  "${MOUNT_DIR}"
sudo rmdir "${MOUNT_DIR}"
