#!/bin/bash

if [[ "${1}" != "skip" ]] ; then
	./build_clean.sh
	./build_kernel.sh "$@" || exit 1
	./build_recovery.sh skip || exit 1
fi

VERSION="$(cat version)-$(date +%F | sed s@-@@g)"

if [ -e boot.img ] ; then
	rm arter97-kernel-$VERSION.zip 2>/dev/null
	# cp boot.img arter97-kernel-$VERSION.img

	# Pack AnyKernel3
	rm -rf kernelzip
	mkdir kernelzip
	echo "
kernel.string=arter97 kernel $(cat version) @ xda-developers
do.devicecheck=1
do.modules=0
do.cleanup=1
do.cleanuponabort=0
device.name1=OnePlus3
device.name2=OnePlus3T
block=/dev/block/bootdevice/by-name/boot
is_slot_device=0
ramdisk_compression=gz
supported.versions=9,9.0
" > kernelzip/props
	cp -rp ~/android/anykernel/* kernelzip/
	cd kernelzip/
	7z a -mx9 arter97-kernel-$VERSION-tmp.zip *
	7z a -mx0 arter97-kernel-$VERSION-tmp.zip ../arch/arm64/boot/Image.gz-dtb
	zipalign -v 4 arter97-kernel-$VERSION-tmp.zip ../arter97-kernel-$VERSION.zip
	rm arter97-kernel-$VERSION-tmp.zip
	cd ..
	ls -al arter97-kernel-$VERSION.zip
fi

if [ -e recovery.img ] ; then
	rm arter97-recovery-$VERSION.zip 2>/dev/null
	cp recovery.img arter97-recovery-$VERSION.img
fi
