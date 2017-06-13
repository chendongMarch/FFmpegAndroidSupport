# build_andorid.sh

#!/bin/bash
#设置编译中临时文件目录，不然会报错 unable to create temporary file
export TMPDIR=/Users/march/Downloads/ffmpeg-3.3.1/ffmpegtemp

# NDK的路径，根据自己的安装位置进行设置
ANDROID_NDK_HOME=/Users/march/AndroidRes/sdk/ndk-bundle

# 编译针对的平台，可以根据自己的需求进行设置
# 这里选择最低支持android-14, arm架构，生成的so库是放在
# libs/armeabi文件夹下的，若针对x86架构，要选择arch-x86
SYSROOT=$NDK/platforms/android-14/arch-arm

# 工具链的路径，根据编译的平台不同而不同
# arm-linux-androideabi-4.9与上面设置的PLATFORM对应，4.9为工具的版本号，
# 根据自己安装的NDK版本来确定，一般使用最新的版本
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

#!/bin/bash -e
#
# build_android.sh
# Copyright (c) 2012 Jacek Marchwicki
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -x

if [ "$ANDROID_NDK_HOME" = "" ]; then
    echo ANDROID_NDK_HOME variable not set, exiting
    echo "Use: export ANDROID_NDK_HOME=/your/path/to/android-ndk"
    exit 1
fi

# Get the newest arm-linux-androideabi version
if [ -z "$COMPILATOR_VERSION" ]; then
    DIRECTORIES=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-*
    for i in $DIRECTORIES; do
        PROPOSED_NAME=${i#*$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-}
        if [[ $PROPOSED_NAME =~ ^[0-9\.]+$ ]] ; then
            echo "Available compilator version: $PROPOSED_NAME"
            COMPILATOR_VERSION=$PROPOSED_NAME
        fi
    done
fi

if [ -z "$COMPILATOR_VERSION" ]; then
    echo "Could not find compilator"
    exit 1
fi

if [ ! -d $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION ]; then
    echo $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION does not exist
    exit 1
fi
echo "Using compilator version: $COMPILATOR_VERSION"

OS_ARCH=`basename $ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/*`
echo "Using architecture: $OS_ARCH"


function setup_paths
{
    export PLATFORM=$ANDROID_NDK_HOME/platforms/$PLATFORM_VERSION/arch-$ARCH/
    if [ ! -d $PLATFORM ]; then
        echo $PLATFORM does not exist
        exit 1
    fi
    echo "Using platform: $PLATFORM"
    export PATH=${PATH}:$PREBUILT/bin/
    export CROSS_COMPILE=$PREBUILT/bin/$EABIARCH-
    export CFLAGS=$OPTIMIZE_CFLAGS
    export CPPFLAGS="$CFLAGS"
    export CFLAGS="$CFLAGS"
    export CXXFLAGS="$CFLAGS"
    export CXX="${CROSS_COMPILE}g++ --sysroot=$PLATFORM"
    export AS="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
    export CC="${CROSS_COMPILE}gcc --sysroot=$PLATFORM"
    export PKG_CONFIG="${CROSS_COMPILE}pkg-config"
    export LD="${CROSS_COMPILE}ld"
    export NM="${CROSS_COMPILE}nm"
    export STRIP="${CROSS_COMPILE}strip"
    export RANLIB="${CROSS_COMPILE}ranlib"
    export AR="${CROSS_COMPILE}ar"
    export LDFLAGS="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog"
    export PKG_CONFIG_LIBDIR=$PREFIX/lib/pkgconfig/
    export PKG_CONFIG_PATH=$PREFIX/lib/pkgconfig/

    if [ ! -f "${CROSS_COMPILE}gcc" ]; then
        echo "Gcc does not exists in path: ${CROSS_COMPILE}gcc"
        exit 1;
    fi

    if [ ! -f "${PKG_CONFIG}" ]; then
        echo "Pkg config does not exists in path: ${PKG_CONFIG} - Probably BUG in NDK but..."
        set +e
        SYS_PKG_CONFIG=$(which pkg-config)
        if [ "$?" -ne 0 ]; then
            echo "This system does not contain system pkg-config, so we can do anything"
            exit 1
        fi
        set -e
        cat > $PKG_CONFIG << EOF
#!/bin/bash
pkg-config \$*
EOF
        chmod u+x $PKG_CONFIG
        echo "Because we have local pkg-config we will create it in ${PKG_CONFIG} directory using ${SYS_PKG_CONFIG}"
    fi
}

function build_x264
{
    echo "Starting build x264 for $ARCH"
    cd x264
    ./configure --prefix=$PREFIX --host=$ARCH-linux --enable-static $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j4 install
    make clean
    cd ..
    echo "FINISHED x264 for $ARCH"
}

function build_amr
{
    echo "Starting build amr for $ARCH"
    cd vo-amrwbenc
    ./configure \
        --prefix=$PREFIX \
        --host=$ARCH-linux \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-pic \
        $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j4 install
    make clean
    cd ..
    echo "FINISHED amr for $ARCH"
}

function build_aac
{
    echo "Starting build aac for $ARCH"
    cd vo-aacenc
    ./configure \
        --prefix=$PREFIX \
        --host=$ARCH-linux \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-pic \
        $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j4 install
    make clean
    cd ..
    echo "FINISHED aac for $ARCH"
}
function build_freetype2
{
    echo "Starting build freetype2 for $ARCH"
    cd freetype2
    ./configure \
        --prefix=$PREFIX \
        --host=$ARCH-linux \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-pic \
        $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j4 install
    make clean
    cd ..
    echo "FINISHED freetype2 for $ARCH"
}
function build_ass
{
    echo "Starting build ass for $ARCH"
    cd libass
    ./configure \
        --prefix=$PREFIX \
        --host=$ARCH-linux \
        --disable-fontconfig \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-pic \
        $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make V=1 -j4 install
    make clean
    cd ..
    echo "FINISHED ass for $ARCH"
}
function build_fribidi
{
    echo "Starting build fribidi for $ARCH"
    cd fribidi
    ./configure \
        --prefix=$PREFIX \
        --host=$ARCH-linux \
        --disable-bin \
        --disable-dependency-tracking \
        --disable-shared \
        --enable-static \
        --with-pic \
        $ADDITIONAL_CONFIGURE_FLAG

    make clean
    make -j4 install
    make clean
    cd ..
    echo "FINISHED fribidi for $ARCH"
}
function build_ffmpeg
{
    echo "Starting build ffmpeg for $ARCH"
    cd ffmpeg
    ./configure --target-os=linux \
        --prefix=$PREFIX \
        --enable-cross-compile \
        --extra-libs="-lgcc" \
        --arch=$ARCH \
        --cc=$CC \
        --cross-prefix=$CROSS_COMPILE \
        --nm=$NM \
        --sysroot=$PLATFORM \
        --extra-cflags=" -O3 -fpic -DANDROID -DHAVE_SYS_UIO_H=1 -Dipv6mr_interface=ipv6mr_ifindex -fasm -Wno-psabi -fno-short-enums  -fno-strict-aliasing -finline-limit=300 $OPTIMIZE_CFLAGS " \
        --disable-shared \
        --enable-static \
        --enable-runtime-cpudetect \
        --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib  -nostdlib -lc -lm -ldl -llog -L$PREFIX/lib" \
        --extra-cflags="-I$PREFIX/include" \
        --disable-everything \
        --enable-pthreads \
        --enable-libass \
        --enable-libvo-aacenc \
        --enable-libvo-amrwbenc \
        --enable-hwaccel=h264_vaapi \
        --enable-hwaccel=h264_vaapi \
        --enable-hwaccel=h264_dxva2 \
        --enable-hwaccel=mpeg4_vaapi \
        --enable-demuxer=mov \
        --enable-demuxer=h264 \
        --enable-demuxer=mpegvideo \
        --enable-demuxer=h263 \
        --enable-demuxer=mpegps \
        --enable-demuxer=mjpeg \
        --enable-demuxer=rtsp \
        --enable-demuxer=rtp \
        --enable-demuxer=hls \
        --enable-demuxer=matroska \
        --enable-muxer=rtsp \
        --enable-muxer=mp4 \
        --enable-muxer=mov \
        --enable-muxer=mjpeg \
        --enable-muxer=matroska \
        --enable-protocol=crypto \
        --enable-protocol=jni \
        --enable-protocol=file \
        --enable-protocol=rtp \
        --enable-protocol=tcp \
        --enable-protocol=udp \
        --enable-protocol=applehttp \
        --enable-protocol=hls \
        --enable-protocol=http \
        --enable-decoder=xsub \
        --enable-decoder=jacosub \
        --enable-decoder=dvdsub \
        --enable-decoder=dvbsub \
        --enable-decoder=subviewer \
        --enable-decoder=rawvideo \
        --enable-encoder=rawvideo \
        --enable-decoder=mjpeg \
        --enable-encoder=mjpeg \
        --enable-decoder=h263 \
        --enable-decoder=mpeg4 \
        --enable-encoder=mpeg4 \
        --enable-decoder=h264 \
        --enable-encoder=h264 \
        --enable-decoder=aac \
        --enable-encoder=aac \
        --enable-parser=h264 \
        --enable-encoder=mp2 \
        --enable-decoder=mp2 \
        --enable-encoder=libvo_amrwbenc \
        --enable-decoder=amrwb \
        --enable-muxer=mp2 \
        --enable-bsfs \
        --enable-decoders \
        --enable-encoders \
        --enable-parsers \
        --enable-hwaccels \
        --enable-muxers \
        --enable-avformat \
        --enable-avcodec \
        --enable-avresample \
        --enable-zlib \
        --disable-doc \
        --disable-ffplay \
        --disable-ffmpeg \
        --disable-ffplay \
        --disable-ffprobe \
        --disable-ffserver \
        --disable-avfilter \
        --disable-avdevice \
        --enable-nonfree \
        --enable-version3 \
        --enable-memalign-hack \
        --enable-asm \
        $ADDITIONAL_CONFIGURE_FLAG
    make clean
    make -j4 install
    make clean

    cd ..
    echo "FINISHED ffmpeg for $ARCH"
}

function build_one {
    echo "Starting build one for $ARCH"
    cd ffmpeg
    ${LD} -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -L$PREFIX/lib  -soname $SONAME -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $OUT_LIBRARY -lavcodec -lavformat -lavresample -lavutil -lswresample -lass -lfreetype -lfribidi -lswscale -lvo-aacenc -lvo-amrwbenc -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker -zmuldefs $PREBUILT/lib/gcc/$EABIARCH/$COMPILATOR_VERSION/libgcc.a
    cd ..
    echo "FINISHED one for $ARCH"
}

#arm v5
EABIARCH=arm-linux-androideabi
ARCH=arm
CPU=armv5
OPTIMIZE_CFLAGS="-marm -march=$CPU"
PREFIX=$(pwd)/ffmpeg-build/armeabi
OUT_LIBRARY=$PREFIX/libffmpeg.so
ADDITIONAL_CONFIGURE_FLAG=
SONAME=libffmpeg.so
PREBUILT=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
PLATFORM_VERSION=android-5
setup_paths
build_amr
build_aac
build_fribidi
build_freetype2
build_ass
build_ffmpeg
build_one

# #x86
# EABIARCH=i686-linux-android
# ARCH=x86
# OPTIMIZE_CFLAGS="-m32"
# PREFIX=$(pwd)/ffmpeg-build/x86
# OUT_LIBRARY=$PREFIX/libffmpeg.so
# ADDITIONAL_CONFIGURE_FLAG=--disable-asm
# SONAME=libffmpeg.so
# PREBUILT=$ANDROID_NDK_HOME/toolchains/x86-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
# PLATFORM_VERSION=android-9
# setup_paths
# build_amr
# build_aac
# build_fribidi
# build_freetype2
# build_ass
# build_ffmpeg
# build_one

# #mips
# EABIARCH=mipsel-linux-android
# ARCH=mips
# OPTIMIZE_CFLAGS="-EL -march=mips32 -mips32 -mhard-float"
# PREFIX=$(pwd)/ffmpeg-build/mips
# OUT_LIBRARY=$PREFIX/libffmpeg.so
# ADDITIONAL_CONFIGURE_FLAG="--disable-mips32r2"
# SONAME=libffmpeg.so
# PREBUILT=$ANDROID_NDK_HOME/toolchains/mipsel-linux-android-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
# PLATFORM_VERSION=android-9
# setup_paths
# build_amr
# build_aac
# build_fribidi
# build_freetype2
# build_ass
# build_ffmpeg
# build_one

# #arm v7vfpv3
# EABIARCH=arm-linux-androideabi
# ARCH=arm
# CPU=armv7-a
# OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=vfpv3-d16 -marm -march=$CPU "
# PREFIX=$(pwd)/ffmpeg-build/armeabi-v7a
# OUT_LIBRARY=$PREFIX/libffmpeg.so
# ADDITIONAL_CONFIGURE_FLAG=
# SONAME=libffmpeg.so
# PREBUILT=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
# PLATFORM_VERSION=android-5
# setup_paths
# build_amr
# build_aac
# build_fribidi
# build_freetype2
# build_ass
# build_ffmpeg
# build_one

# #arm v7 + neon (neon also include vfpv3-32)
# EABIARCH=arm-linux-androideabi
# ARCH=arm
# CPU=armv7-a
# OPTIMIZE_CFLAGS="-mfloat-abi=softfp -mfpu=neon -marm -march=$CPU -mtune=cortex-a8 -mthumb -D__thumb__ "
# PREFIX=$(pwd)/ffmpeg-build/armeabi-v7a-neon
# OUT_LIBRARY=../ffmpeg-build/armeabi-v7a/libffmpeg-neon.so
# ADDITIONAL_CONFIGURE_FLAG=--enable-neon
# SONAME=libffmpeg-neon.so
# PREBUILT=$ANDROID_NDK_HOME/toolchains/arm-linux-androideabi-$COMPILATOR_VERSION/prebuilt/$OS_ARCH
# PLATFORM_VERSION=android-9
# setup_paths
# build_amr
# build_aac
# build_fribidi
# build_freetype2
# build_ass
# build_ffmpeg
# build_one


echo "BUILD SUCCESS"