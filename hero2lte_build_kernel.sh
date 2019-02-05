#!/bin/bash
# Kernel Build Script

MODEL=hero2lte
VARIANT=xx
ARCH=arm64

BUILD_CROSS_COMPILE=~/aarch64-linux-android-4.9/bin/aarch64-linux-android-
BUILD_JOB_NUMBER=`grep processor /proc/cpuinfo|wc -l`
DEFCONFIG="arch/arm64/configs/build_defconfig"
rm -f $DEFCONFIG
cp -f arch/arm64/configs/nethunter_defconfig $DEFCONFIG

# Default Python version is 2.7
mkdir -p bin
ln -sf /usr/bin/python2.7 ./bin/python
export PATH=$(pwd)/bin:$PATH
case $MODEL in
herolte)
cat arch/arm64/configs/herolte_defconfig >> $DEFCONFIG
;;
hero2lte)
cat arch/arm64/configs/hero2lte_defconfig >> $DEFCONFIG
;;
esac

make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE ../../../$DEFCONFIG
make -j$BUILD_JOB_NUMBER ARCH=$ARCH CROSS_COMPILE=$BUILD_CROSS_COMPILE

rm -f $DEFCONFIG

