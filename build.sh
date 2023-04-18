#!/bin/bash

# cd To An Absolute Path
cd /tmp/rom

MANIFEST: "https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni"
MANIFEST_BRANCH: "twrp-7.1"
DEVICE: "kanas"
DT_LINK: "https://github.com/MarvelMathesh/omni_device_samsung_kanas"
DT_PATH: "device/samsung/kanas"
TARGET: "recoveryimage"
BUILD_TYPE: "eng"


# sync source
repo init -u $MANIFEST -b $MANIFEST_BRANCH --depth=1 --groups=all,-notdefault,-device,-darwin,-x86,-mips
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --force-sync -j$(nproc --all)
git clone $DT_LINK --depth=1 --single-branch $DT_PATH
$COMMAND #use if needed ;)

# Compile
export CCACHE_DIR=/tmp/ccache
export CCACHE_EXEC=$(which ccache)
export USE_CCACHE=1
ccache -M 20G
ccache -o compression=true
ccache -z

. build/envsetup.sh && lunch omni_$DEVICE-$BUILD_TYPE
$COMMAND2 #use if needed ;)
make $TARGET -j8 2>&1 | tee build.log

ls -a $(pwd)/out/target/product/$DEVICE/ # show /out contents
ZIP=$(find $(pwd)/out/target/product/$DEVICE/ -maxdepth 1 -name "*$DEVICE*.zip" | perl -e 'print sort { length($b) <=> length($a) } <>' | head -n 1)
ZIPNAME=$(basename $ZIP)
ZIPSIZE=$(du -sh $ZIP |  awk '{print $1}')
echo "$ZIP"

# space after build
df -hlT /
