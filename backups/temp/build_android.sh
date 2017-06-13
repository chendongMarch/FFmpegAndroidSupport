#!/bin/bash
#设置编译中临时文件目录，不然会报错 unable to create temporary file
export TMPDIR=/Users/march/Downloads/ffmpeg-3.3-1.1/ffmpegtemp 

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
 

# 编译针对的平台，这里选择最低支持android-14, arm架构，生成的so库是放在libs/armeabi文件夹下的，若针对x86架构，要选择arch-x86
PLATFORM=$NDK/platforms/android-14/arch-arm
 
function build_one
{
./configure \
    --prefix=$PREFIX \
    --enable-neon \
    --enable-asm \
    --disable-shared \
    --enable-static \
    --disable-doc \
    --disable-ffmpeg \
    --disable-outdev=sdl \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --enable-avdevice \
    --enable-postproc \
    --enable-gpl \
    --disable-doc \
    --disable-symver \
    --disable-symver \
    --cross-prefix=$TOOLCHAIN/bin/arm-linux-androideabi- \
    --target-os=linux \
    --arch=arm \
    --enable-cross-compile \
    --sysroot=$PLATFORM \
    --extra-cflags="-Os -fpic $ADDI_CFLAGS" \
    --extra-ldflags="$ADDI_LDFLAGS" \

$ADDITIONAL_CONFIGURE_FLAG
sed -i '' 's/HAVE_LRINT 0/HAVE_LRINT 1/g' config.h
sed -i '' 's/HAVE_LRINTF 0/HAVE_LRINTF 1/g' config.h
sed -i '' 's/HAVE_ROUND 0/HAVE_ROUND 1/g' config.h
sed -i '' 's/HAVE_ROUNDF 0/HAVE_ROUNDF 1/g' config.h
sed -i '' 's/HAVE_TRUNC 0/HAVE_TRUNC 1/g' config.h
sed -i '' 's/HAVE_TRUNCF 0/HAVE_TRUNCF 1/g' config.h
sed -i '' 's/HAVE_CBRT 0/HAVE_CBRT 1/g' config.h
sed -i '' 's/HAVE_RINT 0/HAVE_RINT 1/g' config.h

make clean
make -j4
make install

$TOOLCHAIN/bin/arm-linux-androideabi-ld \
-rpath-link=$SYSROOT/usr/lib \
-L$SYSROOT/usr/lib \
-L$PREFIX/lib \
-soname libffmpeg.so -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
$PREFIX/libffmpeg.so \
    libavformat/libavformat.a \
    libavdevice/libavdevice.a \
    libpostproc/libpostproc.a \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
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