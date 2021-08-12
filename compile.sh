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

# ZIP kernel function
zip_kernelimage() {
    rm -rf "$(pwd)"/AnyKernel3/Image.gz-dtb
    cp "$(pwd)"/out/arch/arm64/boot/Image.gz-dtb AnyKernel3
    rm -rf "$(pwd)"/AnyKernel3/*.zip
    BUILD_TIME=$(date +"%d%m%Y-%H%M")
    cd AnyKernel3 || exit
    KERNEL_NAME="Mystique-Kernel-POSP-"${BUILD_TIME}""
    zip -r9 "$KERNEL_NAME".zip ./*
    cd ..
}

# Finish up
FILE="out/arch/arm64/boot/Image.gz-dtb"
if [ -f "$FILE" ]; then
    zip_kernelimage
    echo "The kernel has successfully been compiled and can be found in $(pwd)/AnyKernel3/"$KERNEL_NAME".zip"
    FILE_CI="/drone/src/AnyKernel3/"$KERNEL_NAME".zip"
    if [ -f "$FILE_CI" ]; then
        curl --connect-timeout 10 -T "$FILE_CI" https://oshi.at
        curl --connect-timeout 10 --upload-file "$FILE_CI" https://transfer.sh
        echo " "
    elif [ ! -f "$FILE_CI" ] && [ $(whoami) = "node" ]; then
        exit 1
    fi
fi