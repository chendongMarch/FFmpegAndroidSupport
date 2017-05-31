package com.march.fas;

import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Toast;

import java.io.File;
import java.util.concurrent.Callable;

import bolts.Continuation;
import bolts.Task;

/**
 * CreateAt : 2017/5/25
 * Describe :
 *
 * @author chendong
 */
public class MainActivity extends AppCompatActivity {

    FFmpegSupport mFFmpegSupport;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mFFmpegSupport = new FFmpegSupport();
        setContentView(R.layout.activity_main);
//        FFmpegSupport.ffmpegHello();
        findViewById(R.id.tv).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                Task.callInBackground(new Callable<Object>() {
                    @Override
                    public Object call() throws Exception {
                        String inVideoPath = new File(Environment.getExternalStorageDirectory(), "in.mp4").getAbsolutePath();
                        String markPath = new File(Environment.getExternalStorageDirectory(), "mark.png").getAbsolutePath();
                        String outVideoPath = new File(Environment.getExternalStorageDirectory(), "out.mp4").getAbsolutePath();
                        String[] commands = new String[10];
                        commands[0] = "ffmpeg";
                        commands[1] = "-i";
                        commands[2] = inVideoPath;
                        commands[3] = "-i";
                        commands[4] = markPath;
                        commands[5] = "-filter_complex";
                        commands[6] = "overlay=100:100";
                        commands[7] = "-codec:a";
                        commands[8] = "copy";
                        commands[9] = outVideoPath;

                        FFmpegSupport.ffmpegRunCommand(getWatermarkCmd(inVideoPath, markPath, outVideoPath));
                        return null;
                    }
                }).continueWith(new Continuation<Object, Object>() {
                    @Override
                    public Object then(Task<Object> task) throws Exception {
                        if (task.getError() != null) {
                            task.getError().printStackTrace();
                        }
                        Toast.makeText(MainActivity.this, "完成", Toast.LENGTH_SHORT).show();
                        return null;
                    }
                }, Task.UI_THREAD_EXECUTOR);

            }
        });
    }


    private String[] getWatermarkCmd(String in, String mark, String out) {
        String[] cmds = new String[]{
                "ffmpeg",
                "-i",
                in,
                "-vf",
                "movie=" + mark + " [logo]; [in][logo] overlay=10:10 [out]",
                out};
        return cmds;
    }
}
