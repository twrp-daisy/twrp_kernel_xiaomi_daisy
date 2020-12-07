#!/bin/sh

# Copyright (C) 2020 Lacia chan / Lyceris chan <ghostdrain@outlook.com>
# Copyright (C) 2018 Harsh 'MSF Jarvis' Shandilya
# Copyright (C) 2018 Akhil Narang
# SPDX-License-Identifier: GPL-3.0-only

# Setup the compile environment
FILE="environment/README.mkdn"
if [ ! -f "$FILE" ]; then
    git clone --depth=1 https://github.com/akhilnarang/scripts environment
    cd environment
    sh ./setup/android_build_env.sh
    cd ..
fi

# Pull the latest proton-clang from kdrag0n's repo
FILE2="proton-clang/README.md"
if [ ! -f "$FILE2" ]; then
    git clone --depth=1 https://github.com/kdrag0n/proton-clang
fi

BUILD_START=$(date +"%s")
PATH="$(pwd)/proton-clang/bin:$PATH"

export PATH

# Clean up out
rm -rf out/*

# Compile the kernel
make O=out ARCH=arm64 daisy_defconfig

make -j$(nproc --all) \
O=out \
ARCH=arm64 \
CC=clang \
CXX=clang++ \
AR=llvm-ar \
AS=llvm-as \
NM=llvm-nm \
LD=ld.lld \
STRIP=llvm-strip \
OBJCOPY=llvm-objcopy \
OBJDUMP=llvm-objdump\
OBJSIZE=llvm-size \
READELF=llvm-readelf \
HOSTCC=clang \
HOSTCXX=clang++ \
HOSTAR=llvm-ar \
HOSTAS=llvm-as \
HOSTNM=llvm-nm \
HOSTLD=ld.lld \
CROSS_COMPILE=aarch64-linux-gnu- \
CROSS_COMPILE_ARM32=arm-linux-gnueabi-

# Calculate how long compiling compiling the kernel took
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))

FILE="$(pwd)/out/arch/arm64/boot/Image.gz-dtb"
if [ -f "$FILE" ]; then
    echo "The kernel has successfully been compiled. Time elapsed: "$(($DIFF / 60))" minute(s) and "$(($DIFF % 60))" seconds"
fi
