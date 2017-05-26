

# FFmpeg Support

## 配置NDK环境
打开`~/.bash_profile`文件，添加`ndk`的环境变量，最后别忘了`source .bash_profile`更新配置

```bash
#android
export ANDROID_HOME=/Users/march/AndroidRes/sdk

# sdk
export PATH=$ANDROID_HOME/platform-tools:$PATH
export PATH=$ANDROID_HOME/tools:$PATH

# ndk
export NDK_HOME=$ANDROID_HOME/ndk-bundle
export PATH=$NDK_ROOT:$PATH
```



## 修改`ffmpeg-3.3.1/configure`
这个主要是生成的lib包的包名规范成以libxxx.so的形式。 否则生成的so文件在android下是无法加载的，替换过程一定要谨慎，不然编译出来的都无用了。

```bash
# 找到下面几行替换一下
SLIBNAME_WITH_MAJOR='$(SLIBNAME).$(LIBMAJOR)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_VERSION)'
SLIB_INSTALL_LINKS='$(SLIBNAME_WITH_MAJOR)$(SLIBNAME)'

# 替换后的结果
SLIBNAME_WITH_MAJOR='$(SLIBPREF)$(FULLNAME)-$(LIBMAJOR)$(SLIBSUF)'
LIB_INSTALL_EXTRA_CMD='$$(RANLIB)"$(LIBDIR)/$(LIBNAME)"'
SLIB_INSTALL_NAME='$(SLIBNAME_WITH_MAJOR)'
SLIB_INSTALL_LINKS='$(SLIBNAME)'
```


## 新增`ffmpeg-3.3.1/build_android.sh`脚本
NDK后面的路径换成自己的路径

```bash
#!/bin/sh
NDK=/Users/march/AndroidRes/sdk/ndk-bundle
SYSROOT=$NDK/platforms/android-23/arch-arm
TOOLCHAIN=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64
function build_one
{
./configure \
--prefix=$PREFIX \
--enable-shared \
--disable-static \
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
make
make install
}
CPU=arm
PREFIX=$(pwd)/android/$CPU
ADDI_CFLAGS="-marm"
build_one
```


## 编译
执行`build_android.sh`脚本，如果没有权限可以使用`chomd +x`增加执行权限。
然后等一段时间，你会发现在FFmpeg中出现了一个名为android的文件夹。

```bash
android
	arm
	lib
```


## 编写`Android.mk`
```bash
LOCAL_PATH :=$(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE := avcodec
LOCAL_SRC_FILES := libavcodec-57.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avfilter
LOCAL_SRC_FILES := libavfilter-6.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avformat
LOCAL_SRC_FILES := libavformat-57.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := avutil
LOCAL_SRC_FILES := libavutil-55.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swresample
LOCAL_SRC_FILES := libswresample-2.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swscale
LOCAL_SRC_FILES := libswscale-4.so
include $(PREBUILT_SHARED_LIBRARY)

#Program
include $(CLEAR_VARS)
LOCAL_MODULE :=sffhelloworld
LOCAL_SRC_FILES := simplest_ffmpeg_helloworld.c
LOCAL_C_INCLUDES += $(LOCAL_PATH)/include
LOCAL_LDLIBS := -llog -lz
LOCAL_SHARED_LIBRARIES := avcodec avfilter avformat avutil swresample swscale
include $(BUILD_SHARED_LIBRARY)
```


## 编写`Application.mk`
```bash
APP_ABI := armeabi armeabi-v7a
```


## 编译生成so
local.properties 配置ndk目录,通常是默认配置好的。
然后进入到terminal，cd到jni目录，执行ndk-build,(一般情况下ndk的目录应该在local.properties由系统自动创建了，如果没有收到呢添加)

```
ndk.dir=/Users/march/AndroidRes/sdk/ndk-bundle
sdk.dir=/Users/march/AndroidRes/sdk
```
