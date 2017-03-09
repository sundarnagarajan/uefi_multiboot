#!/bin/bash
PROG_DIR=$(readlink -e $(dirname $0))

. ${PROG_DIR}/config.sh

# ------------------------------------------------------------------------
# Git repo locations
# ------------------------------------------------------------------------

# grub2 git repository
GIT_REPO="git://git.savannah.gnu.org/grub.git"

build_efi(){
	make_dir "${BUILD_DIR}/efi"
	cd "${BUILD_DIR}"

	# Clone grub2 git repository
	git clone --depth 1 ${GIT_REPO}

	# Build bootia32.efi and bootx64.efi
	cd grub
	./autogen.sh
	./configure --target=i386 --with-platform=efi
	make -j${NUM_THREADS}
	cd grub-core
	# This last step - which is critical - is from this page:
	# https://github.com/jfwells/linux-asus-t100ta/tree/master/boot

	../grub-mkimage -d . -o bootia32.efi -O i386-efi -p /boot/grub ntfs hfs appleldr boot cat efi_gop efi_uga elf fat hfsplus iso9660 linux keylayouts memdisk minicmd part_apple ext2 extcmd xfs xnu part_bsd part_gpt search search_fs_file chain btrfs loadbios loadenv lvm minix minix2 reiserfs memrw mmap msdospart scsi loopback normal configfile gzio all_video efi_gop efi_uga gfxterm gettext echo boot chain eval

	cp bootia32.efi ${BUILD_DIR}/efi
	cd ../
	./configure --target=x86_64 --with-platform=efi
	make -j${NUM_THREADS}
	cd grub-core
	../grub-mkimage -d . -o bootx64.efi -O x86_64-efi -p /boot/grub ntfs hfs appleldr boot cat efi_gop efi_uga elf fat hfsplus iso9660 linux keylayouts memdisk minicmd part_apple ext2 extcmd xfs xnu part_bsd part_gpt search search_fs_file chain btrfs loadbios loadenv lvm minix minix2 reiserfs memrw mmap msdospart scsi loopback normal configfile gzio all_video efi_gop efi_uga gfxterm gettext echo boot chain eval
	cp bootx64.efi ${BUILD_DIR}/efi
}

build_bootable_template()
{
	make_dir "${BUILD_DIR}/template"
	cd "${BUILD_DIR}"
	cp -rv ${PROG_DIR}/template "${BUILD_DIR}/"
	cd "${BUILD_DIR}/template/EFI/BOOT"
	# Copy bootia32.efi and bootx64.efi that we compiled
	\rm -f bootia32.efi bootx64.efi
	cp ${BUILD_DIR}/efi/bootia32.efi .
	cp ${BUILD_DIR}/efi/bootx64.efi .
}

# ------------------------------------------------------------------------
# Actual action after this
# ------------------------------------------------------------------------
build_efi
build_bootable_template

echo "Executing ${PROG_DIR}/format_create_drive.sh"
echo "Enter user password when prompted for sudo"

sudo ${PROG_DIR}/format_create_drive.sh
