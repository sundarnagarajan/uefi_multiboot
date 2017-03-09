
# Variables that can be set

# Directory used for building - will be created if required
BUILD_DIR="$HOME/build"

# Directory name under /media to mount bootable medium - will be created
MOUNT_DIR=Multiboot

# USB device to WRITE - all contents will be destroyed
# Double-check
# Should be a DEVICE (e.g. /dev/sdk) and NOT a PARTITION (e.g. /dev/sdk1)
USBDEV=/dev/sda

# New VFAT filesystemlabel (UPPERCASE, max 11 chars)
LABEL=MULTIBOOT

# Number of threads (for make)
NUM_THREADS=4

# ------------------------------------------------------------------------
# Shouldn't have to change anything below this
# ------------------------------------------------------------------------

BUILD_DIR=$(readlink -f ${BUILD_DIR})

make_dir()
{
	mkdir -p "$1"
	if [ $? -ne 0 ]; then
		echo "Error creating $1"
		exit 1
	fi
}

