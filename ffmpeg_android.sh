#!/bin/bash

NDK_ROOT=${HOME}/Documents/android_ndks/android-ndk-r17c
ANDROID_API=android-21

LIBRARY_TARGET_ABI="$1"

if [ "$LIBRARY_TARGET_ABI" == "armeabi-v7a" ]
then
    CONFIGURE_AARCH=arm
    SYSROOT=${NDK_ROOT}/platforms/${ANDROID_API}/arch-arm
    PREBUILT=${NDK_ROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64
    CROSS_PREFIX=${PREBUILT}/bin/arm-linux-androideabi-
    ARM_INCLUDE=${NDK_ROOT}/sysroot/usr/include
    ARM_LIB=${NDK_ROOT}/platforms/${ANDROID_API}/arch-arm/usr/lib
    SYSTEM=${NDK_ROOT}/sysroot/usr/include/arm-linux-androideabi
    CFLAGS="-mfloat-abi=softfp -marm -march=armv7-a"
elif [ "$LIBRARY_TARGET_ABI" == "arm64-v8a" ]
then
    CONFIGURE_AARCH=aarch64
    SYSROOT=${NDK_ROOT}/platforms/${ANDROID_API}/arch-arm64
    PREBUILT=${NDK_ROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
    CROSS_PREFIX=${PREBUILT}/bin/aarch64-linux-android-
    ARM_INCLUDE=${NDK_ROOT}/sysroot/usr/include
    ARM_LIB=${NDK_ROOT}/platforms/${ANDROID_API}/arch-arm64/usr/lib
    SYSTEM=${NDK_ROOT}/sysroot/usr/include/aarch64-linux-android
    CFLAGS=-march=armv8-a
elif [ "$LIBRARY_TARGET_ABI" == "x86" ]
then
    CONFIGURE_AARCH=x86
    SYSROOT=${NDK_ROOT}/platforms/${ANDROID_API}/arch-x86
    PREBUILT=${NDK_ROOT}/toolchains/x86-4.9/prebuilt/linux-x86_64
    CROSS_PREFIX=${PREBUILT}/bin/i686-linux-android-
    ARM_INCLUDE=${NDK_ROOT}/sysroot/usr/include
    ARM_LIB=${NDK_ROOT}/platforms/${ANDROID_API}/arch-x86/usr/lib
    SYSTEM=${NDK_ROOT}/sysroot/usr/include/i686-linux-android
    CFLAGS="-march=i686 -mtune=intel -mssse3 -mfpmath=sse -m32"
elif [ "$LIBRARY_TARGET_ABI" == "x86_64" ]
then
    CONFIGURE_AARCH=x86_64
    SYSROOT=${NDK_ROOT}/platforms/${ANDROID_API}/arch-x86_64
    PREBUILT=${NDK_ROOT}/toolchains/x86_64-4.9/prebuilt/linux-x86_64
    CROSS_PREFIX=${PREBUILT}/bin/x86_64-linux-android-
    ARM_LIB=${NDK_ROOT}/platforms/${ANDROID_API}/arch-x86_64/usr/lib64
    SYSTEM=${NDK_ROOT}/sysroot/usr/include/x86_64-linux-android
    CFLAGS="-march=x86-64 -mtune=intel -m64 -funroll-loops -ffast-math"
else
    echo "Unsupported target ABI: $LIBRARY_TARGET_ABI"
    exit 1
fi

# pathes to libs
export OPENH264_INCLUDE="${HOME}/Documents/openh264/builded/${LIBRARY_TARGET_ABI}/include"
export OPENH264_LIBRARY="${HOME}/Documents/openh264/builded/${LIBRARY_TARGET_ABI}/lib"

export MP3_INCLUDE="${HOME}/Documents/mp3lame/lame-3.100/include"
export MP3_LIBRARY="${HOME}/Documents/mp3lame/lame-3.100/libs/${LIBRARY_TARGET_ABI}"

export OPENSSL_INCLUDE="${HOME}/Documents/openssl/builded/${LIBRARY_TARGET_ABI}/include"
export OPENSSL_LIBRARY="${HOME}/Documents/openssl/builded/${LIBRARY_TARGET_ABI}/lib"

#output dir
PREFIX=$(pwd)/../build/${LIBRARY_TARGET_ABI}

export PKG_CONFIG_PATH="$(pwd)/pkg_config"

ARM_INCLUDE=${NDK_ROOT}/sysroot/usr/include

./configure \
 --pkg-config=${PKG_CONFIG_PATH} \
 --arch=${CONFIGURE_AARCH} \
 --target-os=android \
 --enable-cross-compile \
 --cross-prefix=${CROSS_PREFIX} \
 --prefix=${PREFIX} \
 --sysroot=${SYSROOT} \
 --enable-shared \
 --disable-static \
 --enable-runtime-cpudetect \
 --enable-hardcoded-tables \
 --enable-small \
 --disable-programs \
 --disable-asm \
 --disable-debug \
 --enable-pthreads \
 --enable-openssl \
 --enable-jni \
 --enable-mediacodec \
 --enable-libopenh264 \
 --enable-encoder=libopenh264 \
 --enable-libmp3lame \
 --enable-encoder=libmp3lame \
 --enable-decoder=h264_mediacodec,hevc_mediacodec,mpeg2_mediacodec,mpeg4_mediacodec,vp8_mediacodec,vp9_mediacodec,h264 \
 --enable-hwaccel=h264_mediacodec,hevc_mediacodec,mpeg2_mediacodec,mpeg4_mediacodec,vp8_mediacodec,vp9_mediacodec \
 --enable-parser=h264 \
 --enable-demuxer=h264,mov \
 --enable-protocol=concat,file,rtmp,rtmps \
 --extra-cflags="-I${ARM_INCLUDE} -I${OPENH264_INCLUDE} -I${MP3_INCLUDE} -I${OPENSSL_INCLUDE} -DANDROID -O3 -fPIC -fasm -isystem ${SYSTEM} ${CFLAGS}" \
 --extra-ldflags="-L${ARM_LIB} -L${OPENH264_LIBRARY} -L${MP3_LIBRARY} -L${OPENSSL_LIBRARY} -lz -lc -lm -ldl -llog -lmp3lame -lopenh264 -lssl -lcrypto" \
 --cxx=${CROSS_PREFIX}g++ \
 --extra-libs="-lgcc"

function build_one
{
make clean all
make -j$(nproc)
make install
}
#build_one

