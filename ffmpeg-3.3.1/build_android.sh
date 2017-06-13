# build_andorid.sh

#!/bin/bash
#设置编译中临时文件目录，不然会报错 unable to create temporary file
export TMPDIR=/Users/march/Downloads/ffmpeg-3.3.1/ffmpegtemp

# NDK的路径，根据自己的安装位置进行设置
NDK=/Users/march/AndroidRes/sdk/ndk-bundle

# 编译针对的平台，可以根据自己的需求进行设置
# 这里选择最低支持android-14, arm架构，生成的so库是放在
# libs/armeabi文件夹下的，若针对x86架构，要选择arch-x86
SYSROOT=$NDK/platforms/android-14/arch-arm

# 工具链的路径，根据编译的平台不同而不同
# arm-linux-androideabi-4.9与上面设置的PLATFORM对应，4.9为工具的版本号，
# 根据自己安装的NDK版本来确定，一般使用最新的版本
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

function build_one
{
    ./configure \
    --prefix=$PREFIX \
    --disable-shared \
    --enable-static \
    --enable-jni \
    --enable-mediacodec \
    --enable-neon \
    --enable-hwaccel=h264_vaapi \
    --enable-hwaccel=h264_dxva2 \
    --enable-hwaccel=mpeg4_vaapi \
    --enable-hwaccels \
    --enable-asm \
    --disable-doc \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-avdevice \
    --disable-doc \
    --disable-symver \
    --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
    --target-os=linux \
    --arch=arm \
    --enable-cross-compile \
    --sysroot=$SYSROOT \
    --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS" \
    $ADDITIONAL_CONFIGURE_FLAG
    make clean
    make -j4
    make install

    $TOOLCHAIN/bin/arm-linux-androideabi-ld \
    -rpath-link=$SYSROOT/usr/lib \
    -L$SYSROOT/usr/lib \
    -L$PREFIX/lib \
    -soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $PREFIX/libffmpeg.so \
        libavcodec/libavcodec.a \
        libavfilter/libavfilter.a \
        libswresample/libswresample.a \
        libavformat/libavformat.a \
        libavutil/libavutil.a \
        libswscale/libswscale.a \
        -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
        $TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a
}
CPU=armv7-a
OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
PREFIX=./android/$CPU
ADDITIONAL_CONFIGURE_FLAG=--enable-neon
build_one

# CPU=armv
# PREFIX=$(pwd)/android/$CPU
# ADDI_CFLAGS="-marm"
# build_one

#arm v6
#CPU=armv6
#OPTIMIZE_CFLAGS="-marm -march=$CPU"
#PREFIX=./android/$CPU
#ADDITIONAL_CONFIGURE_FLAG=
#build_one

#arm v7vfpv3
# CPU=armv7-a
# OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
# PREFIX=./android/$CPU
# ADDITIONAL_CONFIGURE_FLAG=
# build_one

#arm v7n
#CPU=armv7-a
#OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8"
#PREFIX=./android/$CPU
#ADDITIONAL_CONFIGURE_FLAG=--enable-neon
#build_one

#arm v6+vfp
#CPU=armv6
#OPTIMIZE_CFLAGS="-DCMP_HAVE_VFP -mfloat-abi=softfp -mfpu=vfp -marm -march=$CPU"
#PREFIX=./android/${CPU}_vfp
#ADDITIONAL_CONFIGURE_FLAG=
#build_one