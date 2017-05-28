package com.march.fas;

/**
 * CreateAt : 2017/5/25
 * Describe :
 *
 * @author chendong
 */
public class FFmpegSupport {

    static {
        try {
            System.loadLibrary("avcodec-57");
            System.loadLibrary("avdevice-57");
            System.loadLibrary("avfilter-6");
            System.loadLibrary("avformat-57");
            System.loadLibrary("avutil-55");
            System.loadLibrary("postproc-54");
            System.loadLibrary("swresample-2");
            System.loadLibrary("swscale-4");

            System.loadLibrary("ffmpeg_support");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static native String ffmpegHello();
}
