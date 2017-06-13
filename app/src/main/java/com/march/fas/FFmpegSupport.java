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
        return ffmpegRunCommand(args);
    }

    static int ffmpegRunCommand(String[] commands) {
        for (String command : commands) {
            Log.d("ffmpeg-jni", command);
        }
        return ffmpegRun(commands.length, commands);
    }

    public static native int ffmpegRun(int argc, String[] args);
}
