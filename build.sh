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


#chosen defconfig:
DEVICE_DEFCONFIG=$DEFCONFIG_S7FLAT
MODEL=G930	#OR G935


export KBUILD_BUILD_VERSION="1"

#Build kernel
cp -f $RDIR/arch/$ARCH/configs/$DEFCONFIG $RDIR/arch/$ARCH/configs/tmp_defconfig
cat $RDIR/arch/$ARCH/configs/$DEVICE_DEFCONFIG >> $RDIR/arch/$ARCH/configs/tmp_defconfig

make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE tmp_defconfig || exit -1
make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE || exit -1
echo ""
rm -f $RDIR/arch/$ARCH/configs/tmp_defconfig

mkdir -p $RDIR/build/$MODEL/modules
mkdir -p $RDIR/build/$MODEL/firmware
mv $RDIR/arch/$ARCH/boot/Image $RDIR/build/$MODEL/
find $RDIR/ -name '*.ko'  -not -path "$RDIR/build/*" -exec cp --parents -f '{}' $RDIR/build/$MODEL/modules  \;
find $RDIR/ -name '*.fw'  -not -path "$RDIR/build/*" -exec cp --parents -f '{}' $RDIR/build/$MODEL/firmware \;
find $RDIR/ -name '*.ko'  -not -path "$RDIR/build/*" -exec rm -f {} +
find $RDIR/ -name '*.fw'  -not -path "$RDIR/build/*" -exec rm -f {} +
mv -f $RDIR/build/$MODEL/modules/home/svirusx/Nethunter-s7-kernel-StockOreo/* $RDIR/build/$MODEL/modules
rm -rf $RDIR/build/$MODEL/modules/home
mv -f $RDIR/build/$MODEL/firmware/home/svirusx/Nethunter-s7-kernel-StockOreo/* $RDIR/build/$MODEL/firmware
rm -rf $RDIR/build/$MODEL/firmware/home

echo "END"

























