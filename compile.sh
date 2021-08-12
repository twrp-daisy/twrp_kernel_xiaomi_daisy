#!/bin/sh

# Setup the build environment
git clone --depth=1 https://github.com/akhilnarang/scripts environment
cd environment && bash setup/android_build_env.sh && cd ..

# Clone the toolchain and AnyKernel3
git clone https://github.com/mvaisakh/gcc-arm64 toolchain
cd toolchain && git reset --hard 3c40809e66c86ed5d02dcf256fabbf4e03aa4e7f && cd ..
git clone --depth=1 https://github.com/Couchpotato-sauce/AnyKernel3 AnyKernel3 # TEMP

# Export some environment variables
export ARCH=arm64
export SUB_ARCH=arm64
export CROSS_COMPILE=$(pwd)/toolchain/bin/aarch64-elf-

# Cleanup out directory
make O=out clean && make O=out mrproper

# Compile the kernel
make O=out sakura_defconfig
make O=out -j$(nproc --all)

# Finish up
FILE="out/arch/arm64/boot/Image.gz-dtb"
if [ -f "$FILE" ]; then
    if [ -f "/drone/src/$FILE" ]; then
        curl --connect-timeout 10 -T "$FILE" https://oshi.at
        curl --connect-timeout 10 --upload-file "$FILE" https://transfer.sh
        echo " "
    elif [ ! -f "/drone/src/$FILE" ] && [ $(whoami) = "node" ]; then
        exit 1
    fi
fi