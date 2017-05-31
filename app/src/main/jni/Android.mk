LOCAL_PATH:= $(call my-dir)

include $(CLEAR_VARS)
LOCAL_MODULE:= avcodec-prebuilt-armeabi
LOCAL_SRC_FILES:= prebuilt/armeabi/libavcodec-57.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= avdevice-prebuilt-armeabi
LOCAL_SRC_FILES:= prebuilt/armeabi/libavdevice-57.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= avfilter-prebuilt-armeabi
LOCAL_SRC_FILES:= prebuilt/armeabi/libavfilter-6.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE:= avformat-prebuilt-armeabi
LOCAL_SRC_FILES:= prebuilt/armeabi/libavformat-57.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE :=  avutil-prebuilt-armeabi
LOCAL_SRC_FILES := prebuilt/armeabi/libavutil-55.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swresample-prebuilt-armeabi
LOCAL_SRC_FILES := prebuilt/armeabi/libswresample-2.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := swscale-prebuilt-armeabi
LOCAL_SRC_FILES := prebuilt/armeabi/libswscale-4.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := postproc-prebuilt-armeabi
LOCAL_SRC_FILES := prebuilt/armeabi/libpostproc-54.so
include $(PREBUILT_SHARED_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := libffmpegjni

LOCAL_ARM_MODE := arm

LOCAL_SRC_FILES := com_march_fas_FFmpegSupport.c \
                   ffmpeg.c \
                   cmdutils.c \
                   ffmpeg_opt.c \
                   ffmpeg_filter.c

LOCAL_LDLIBS := -L$(SYSROOT)/usr/lib -llog -lz

LOCAL_SHARED_LIBRARIES:= avcodec-prebuilt-armeabi \
                         avdevice-prebuilt-armeabi \
                         avfilter-prebuilt-armeabi \
                         avformat-prebuilt-armeabi \
                         avutil-prebuilt-armeabi \
                         swresample-prebuilt-armeabi \
                         swscale-prebuilt-armeabi \
                         postproc-prebuilt-armeabi

LOCAL_C_INCLUDES += -L$(SYSROOT)/usr/include
LOCAL_C_INCLUDES += /Users/march/Downloads/ffmpeg-3.3.1

LOCAL_CFLAGS := -DUSE_ARM_CONFIG

include $(BUILD_SHARED_LIBRARY)