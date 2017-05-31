package com.march.fas;

import android.util.Log;

/**
 * CreateAt : 2017/5/25
 * Describe :
 *
 * @author chendong
 */
public class FFmpegSupport {

    static {
        try {
            System.loadLibrary("avdevice-57");
            System.loadLibrary("avfilter-6");
            System.loadLibrary("avformat-57");
            System.loadLibrary("avutil-55");
            System.loadLibrary("avcodec-57");
            System.loadLibrary("postproc-54");
            System.loadLibrary("swresample-2");
            System.loadLibrary("swscale-4");

            System.loadLibrary("ffmpegjni");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public  static int ffmpegRunCommand(String command) {
        if (command.isEmpty()) {
            return 1;
        }
        String[] args = command.split(" ");
        for (int i = 0; i < args.length; i++) {
            Log.d("ffmpeg-jni", args[i]);
        }
        return ffmpegRun(args.length, args);
    }

    public  static int ffmpegRunCommand(String[] commands) {
        for (int i = 0; i < commands.length; i++) {
            Log.d("ffmpeg-jni", commands[i]);
        }
        return ffmpegRun(commands.length, commands);
    }

    // public static native String ffmpegHello();
    public static native int ffmpegRun(int argc, String[] args);
}
