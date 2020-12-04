#!/bin/bash
# Kernel Build Script based on MoroKernel build script

export ARCH=arm64
export SUBARCH=arm64
export BUILD_CROSS_COMPILE=~/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE=$BUILD_CROSS_COMPILE
export BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
export ANDROID_MAJOR_VERSION=o
export ANDROID_VERSION=80000
export PLATFORM_VERSION=8.0.0
	
RDIR=$(pwd)
OUTDIR=$RDIR/arch/$ARCH/boot
DTSDIR=$RDIR/arch/$ARCH/boot/dts
DTBDIR=$OUTDIR/dtb
DTCTOOL=$RDIR/scripts/dtc/dtc
INCDIR=$RDIR/include
PAGE_SIZE=2048
DTB_PADDING=0

DEFCONFIG=nethunter_defconfig
DEFCONFIG_S7FLAT=herolte_defconfig
DEFCONFIG_S7EDGE=hero2lte_defconfig



OS=twOreo
ANDROID=8
MODEL=G930

#chosen defconfig:
DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT


export KBUILD_BUILD_VERSION="1"

#Build kernel
cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
cat $RDIR/arch/$ARCH/configs/$DEVICE_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig

make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE tmp_defconfig || exit -1
make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
echo ""
rm -f $RDIR/arch/$ARCH/configs/tmp_defconfig


#Build DTB
cp $DTSDIR/exynos8890-herolte_stock.dtsi $DTSDIR/exynos8890-herolte_common.dtsi


case $MODEL in
	G930)
		DTSFILES="exynos8890-herolte_eur_open_04 exynos8890-herolte_eur_open_08
				exynos8890-herolte_eur_open_09 exynos8890-herolte_eur_open_10"
		;;
	G935)
		DTSFILES="exynos8890-hero2lte_eur_open_04 exynos8890-hero2lte_eur_open_08"
		;;
	*)

		echo "Unknown device: $MODEL"
		exit 1
		;;

esac
	mkdir -p $OUTDIR $DTBDIR
	cd $DTBDIR || {
		echo "Unable to cd to $DTBDIR!"
		exit 1
	}
	rm -f ./*
	echo "Processing dts files."
	for dts in $DTSFILES; do
		echo "=> Processing: ${dts}.dts"
		${CROSS_COMPILE}cpp -nostdinc -undef -x assembler-with-cpp -I "$INCDIR" "$DTSDIR/${dts}.dts" > "${dts}.dts"
		echo "=> Generating: ${dts}.dtb"
		$DTCTOOL -p $DTB_PADDING -i "$DTSDIR" -O dtb -o "${dts}.dtb" "${dts}.dts"
	done
	echo "Generating dtb.img."
	$RDIR/scripts/dtbtool_exynos/dtbtool -o "$OUTDIR/dtb.img" -d "$DTBDIR/" -s $PAGE_SIZE
	echo "Done."
	
	rm -f $DTSDIR/exynos8890-herolte_common.dtsi




#Building Ramdisk

		
cd $RDIR/build
mkdir temp 2>/dev/null
cp -rf aik/. temp

cp -rf ramdisk/ramdisk/. temp/ramdisk
cp -rf ramdisk/split_img/. temp/split_img

rm -f temp/split_img/boot.img-zImage
	rm -f temp/split_img/boot.img-dt
	mv $RDIR/arch/$ARCH/boot/Image temp/split_img/boot.img-zImage
	mv $RDIR/arch/$ARCH/boot/dtb.img temp/split_img/boot.img-dt
	cd temp

./repackimg.sh

echo SEANDROIDENFORCE >> image-new.img
mkdir $RDIR/build/kernel-temp 2>/dev/null
mkdir -p $RDIR/build/$MODEL/modules
mkdir -p $RDIR/build/$MODEL/firmware
find $RDIR/ -name '*.ko'  -not -path "$RDIR/build/*" -exec cp --parents -f '{}' $RDIR/build/$MODEL/modules  \;
find $RDIR/ -name '*.fw'  -not -path "$RDIR/build/*" -exec cp --parents -f '{}' $RDIR/build/$MODEL/firmware \;
find $RDIR/ -name '*.ko'  -not -path "$RDIR/build/*" -exec rm -f {} +
find $RDIR/ -name '*.fw'  -not -path "$RDIR/build/*" -exec rm -f {} +
mv -f $RDIR/build/$MODEL/modules/home/svirusx/Nethunter-s7-kernel-WirusMOD-AiO/* $RDIR/build/$MODEL/modules
rm -rf $RDIR/build/$MODEL/modules/home
mv -f $RDIR/build/$MODEL/firmware/home/svirusx/Nethunter-s7-kernel-WirusMOD-AiO/* $RDIR/build/$MODEL/firmware
rm -rf $RDIR/build/$MODEL/firmware/home
mv image-new.img $RDIR/build/$MODEL/$MODEL-boot.img
rm -rf $RDIR/build/temp

echo "END"

























