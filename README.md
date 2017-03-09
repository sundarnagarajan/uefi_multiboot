# uefi_multiboot
Create UEFI-compatible boot drive supporting multiple ISO images  


## You will need
- Machine running Linux (Ubuntu) - to create UEFI-compatible USB drive
- Disposable USB drive - everything will be deleted

## Notes
- These scripts currently create a UEFI-ONLY bootdrive. This cannot be
	be used on a non-UEFI system

- Making these boot drives compatible with non-UEFI only requires
	performing 'grub-install' with the right command line parameters and
	setup (mounts etc).

# Steps

## Install required packages
- Run 'sudo install_reqs.sh'

## Edit config.sh
- Insert the USB drive you wish to use
- Identify which device it is - use i'lsblk' or 'sudo blkid' etc.
- DOUBLE CHECK the device name and update USBDEV variable
- Set BUILD_DIR and oher variables at the top

## Run build_bootable_drive.sh
This script will call format_create_drive.sh
Running format_create_drive.sh requires sudo, and you will be
	prompted for your user password

## Add ISOs
- Once you have run build_bootable_drive.sh, re-insert and mount
	your new bootable drive
- Add your ISO files to top-level 'iso' directory, creating it if it
	doesn't exist
- Edit boot/grub/grub.cfg to reference your ISO files
	- If you are using Ubuntu ISOs (different flavors), just
		setting isofile variable for each one shouldbe enough
	- For other types of Linux ISOs, the initrd variable may also be
			different, and the command line may also differ
		TODO: Create script that can mount and inspect ISO files and
			create grub.cfg
- Don't forget to set the menuentry titles in grub.cfg

- Unmount bootable drive


# Concepts

## GUID Patition Table (versus 'legacy' or 'DOS' partition table
Making a UEFI-compatible boot disk REQUIRES creating a GUID partition
table. To my knowledge, it is IMPOSSIBLE to make a UEFI-compatible
boot disk with a 'legacy' or 'DOS' partition table

## EFI System Partition
The SYSTEM BOOTLOADER (or 'EFI Applications') need to be on a partition
of a SPECIAL PARTITION TYPE. In ADDITION, this partition needs to be
formatted as type 'vfat' (FAT32 in Microsoft-language).

In Linux, creating and manipulating GPT partitions requires 'gdisk'. You
CANNOT use the traditional 'fdisk' to create ot manipulate GPT partitions.

Using gdisk, the partition type for the EFI System Partition must be 'EF00'

## EFI System Partition layout
TYPICALLY the EFI system partition is mounted on /boot/efi
This is not REQUIRED - can pass the loation to grub-install with the 
--efi-directory= parameter

WITHIN the EFI System partition, the layout MUST be as follows:

	├── EFI                      - top of EFI System Patition
	│   └── BOOT                 - directory
	│       ├── bootia32.efi     - 32-bit EFI application
	│       └── bootx64.efi      - 64-bit EFI application
	└── HDD-Ubuntu               - directory (named EFI target)
	    ├── grubia32.efi         - 32-bit EFI application
	    └── grubx64.efi          - 64-bit EFI application


# Links
-  How to Create a EFI/UEFI GRUB2 Multiboot USB drive to boot ISO images
	https://ubuntuforums.org/showthread.php?t=2276498

   I started with this forum post and modified:
	- List of files required
	- grub.cfg
	- Added compilation of grub from source

- Roderick Smith's page on UEFI:
	http://www.rodsbooks.com/linux-uefi/

- ARCH Linux GRUB page - useful as a reference:
	https://wiki.archlinux.org/index.php/GRUB#GRUB_standalone
