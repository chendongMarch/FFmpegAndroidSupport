package com.march.fas;

import android.os.AsyncTask;
import android.os.Bundle;
import android.os.Environment;
import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;
import android.util.Log;
import android.view.View;

import java.io.File;
import java.util.Locale;

/**
 * CreateAt : 2017/5/25
 * Describe :
 *
 * @author chendong
 */
public class MainActivity extends AppCompatActivity {
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
//        FFmpegSupport.ffmpegHello();

        findViewById(R.id.tv).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Log.e("chendong", "开始");


//
                new AsyncTask<Void, Void, Void>() {

                    @Override
                    protected Void doInBackground(Void... params) {
                        try {
                            String inVideoPath = new File(Environment.getExternalStorageDirectory(), "in.mp4").getAbsolutePath();
                            String outAudioPath = new File(Environment.getExternalStorageDirectory(), "out.mp3").getAbsolutePath();
                            String cmdline = String.format(Locale.CHINA, "ffmpeg -i %s -acodec copy -vn %s", inVideoPath, outAudioPath);
                            String[] argv = cmdline.split(" ");
                            int length = argv.length;
                            String ffmpegRun = FFmpegSupport.ffmpegRun(length, argv);
                            Log.e("chendong", ffmpegRun);
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                        return null;
                    }

                    @Override
                    protected void onPostExecute(Void aVoid) {
                        super.onPostExecute(aVoid);
                        Log.e("chendong", "结束");

                    }
                }.execute();
            }
        });
    }
}
