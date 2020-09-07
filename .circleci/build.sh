#!/usr/bin/env bash
git clone --depth=1 https://github.com/Nuub32User/ThunderBeast -b  master  folder
cd folder
git clone https://github.com/arter97/arm64-gcc --depth=1
git clone https://github.com/arter97/arm32-gcc --depth=1
git clone --depth=1 https://github.com/Nuub32User/AnyKernel3 AnyKernel
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
export CONFIG_PATH=$PWD/arch/arm64/configs/lavended_defconfig
PATH="$(pwd)/arm64-gcc/bin:$(pwd)/arm32-gcc/bin:${PATH}" \
export ARCH=arm64
export USE_CCACHE=1
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="Nuub32User"
# Send info about the build to Telegram Channel/Group (Depending upon what chat_id you've specified in CircleCI Environment Variables)
function sendinfo() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>Experimental Kernel</b>%0ABuild Status : SUCCESS%0ALast Commit Info - <code>$(git log --pretty=format:'"%h : %s"' -1)</code>" 
}
# Push kernel to Telegram Channel/Group
function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Enjoy Lyf Now"
}
# Compile the Defconfig (lavended_defconfig in my case)
function compile() {
   make O=out ARCH=arm64 lavended_defconfig
     PATH="$(pwd)/arm64-gcc/bin:$(pwd)/arm32-gcc/bin:${PATH}" \
       make -j$(nproc --all) O=out \
                             ARCH=arm64 \
                             CROSS_COMPILE=aarch64-elf- \
                             CROSS_COMPILE_ARM32=arm-eabi-
   cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping (Using Anykernel Repo)
function zipping() {
    cd AnyKernel || exit 1
    zip -r9 ThunderBeast-Kernel-${TANGGAL}.zip *
    cd .. 
}
sendinfo
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
push

