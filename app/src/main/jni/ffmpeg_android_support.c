#include <stdio.h>
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libavfilter/avfilter.h"

#ifdef ANDROID
#include <jni.h>
#include <android/log.h>
#define LOGE(format,...) __android_log_print(ANDROID_LOG_ERROR,"myndk",format,##__VA_ARGS__)
#else
#define LOGE(format,...) printf("(>_<)"format "\n",##__VA_ARGS__)
#endif
JNIEXPORT jstring Java_com_march_fas_FFmpegSupport_ffmpegHello(JNIEnv *env,jobject obj)
{
    char info[40000] ={0};
    av_register_all();
    AVCodec *c_temp = av_codec_next(NULL);
    while(c_temp != NULL){
        if(c_temp->decode!=NULL){
            sprintf(info,"%s[Dec]",info);
        }else{
            sprintf(info,"%s[Enc]",info);
        }
        switch(c_temp->type){
           case AVMEDIA_TYPE_VIDEO:
            sprintf(info,"%s[Video]",info);
            break;
           case AVMEDIA_TYPE_AUDIO:
            sprintf(info,"%s[AUDIO]",info);
            break;
           default:
            sprintf(info,"%s[Other]",info);
            break;
        }
        sprintf(info,"%s[%10s]\n",info,c_temp->name);
        c_temp=c_temp->next;
        LOGE("chendong hello world");
    }
    return (*env)->NewStringUTF(env,info);
}