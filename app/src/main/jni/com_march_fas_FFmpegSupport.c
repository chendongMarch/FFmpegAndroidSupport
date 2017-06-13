#include "logjni.h"
#include "com_march_fas_FFmpegSupport.h"

#include <stdlib.h>
#include <stdbool.h>

int main(int argc, char **argv);

JNIEXPORT jint JNICALL Java_com_march_fas_FFmpegSupport_ffmpegRun
(JNIEnv *env, jobject obj, jint argc, jobjectArray args) {
    int i = 0;
    char **argv = NULL;
    jstring *strr = NULL;

    if (args != NULL) {
        argv = (char **) malloc(sizeof(char *) * argc);
        strr = (jstring *) malloc(sizeof(jstring) * argc);

        for (i = 0; i < argc; ++i) {
            strr[i] = (jstring)(*env)->GetObjectArrayElement(env, args, i);
            argv[i] = (char *)(*env)->GetStringUTFChars(env, strr[i], 0);
            LOGD("args: %s", argv[i]);
        }
    }

    LOGD("Run ffmpeg");
    int result = main(argc, argv);
    LOGD("ffmpeg result %d", result);

    for (i = 0; i < argc; ++i) {
        (*env)->ReleaseStringUTFChars(env, strr[i], argv[i]);
    }
    free(argv);
    free(strr);
    return result;
}
