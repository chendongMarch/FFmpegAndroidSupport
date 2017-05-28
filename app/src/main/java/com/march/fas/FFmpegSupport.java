package com.march.fas;

import android.util.Log;

/**
 * CreateAt : 2017/5/25
 * Describe :
 *
 * @author chendong
 */
public class FFmpegSupport {

//    static {
//        try {
//            System.loadLibrary("avutil-55");
//            System.loadLibrary("swresample-2");
//            System.loadLibrary("avcodec-57");
//            System.loadLibrary("avformat-57");
//            System.loadLibrary("swscale-4");
//            System.loadLibrary("avfilter-6");
//            System.loadLibrary("ffmpeg_support");
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }
//
//    public  static native String ffmpegHello();
    public  static native String ffmpegRun(int length,String[] cmd);


    static {
        try {
            System.loadLibrary("avutil-54");
            System.loadLibrary("swresample-1");
            System.loadLibrary("avcodec-56");
            System.loadLibrary("avformat-56");
            System.loadLibrary("swscale-3");
            System.loadLibrary("postproc-53");
            System.loadLibrary("avfilter-5");
            System.loadLibrary("avdevice-56");
            System.loadLibrary("ffmpeg_support");
        } catch (Exception e) {
            Log.e("chendong",e.getMessage() );
            e.printStackTrace();
        }
    }
}
