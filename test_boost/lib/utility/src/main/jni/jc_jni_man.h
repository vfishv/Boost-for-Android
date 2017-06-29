#pragma once


#include <jni.h>
#include <string>
#include <memory>
#include <string>

#include <boost/thread/tss.hpp>
#include <jc_img_data.h>

class JcJniEnv;

//-------------------------
class JcJniMan
{

public:

    // First Jni Method called .. at startup.. initialize Jvm etc
    static jint onLoad(JavaVM *Jvm);

    static int jniVersion(){ return JNI_VERSION_1_6;}

    // get a Java class from c++ (Thread Safe - even if called in thread created by c++)
    static jclass findClass(const char* name);

    // Unlike the JNIEnv pointer, the JavaVM pointer remains valid across multiple threads so it can be cached in a global variable.
    static JavaVM * jvm(){ return _Jvm;}

    static JNIEnv *getEnv();

    static void checkException();
    //static bool testJvm();

    static bool uiShowText(std::string text, JNIEnv *Env = 0);
    static bool uiShowImg(JcImgData imgData,JNIEnv *Env = 0);
    static bool uiShowImg(jlong cvMatRowPtr, jint rows, jint cols, JNIEnv *Env = 0);
    
    static bool ensureThreadDetached();

private:
    static JavaVM * _Jvm;
    static jobject _ClassLoader;
    static jmethodID _FindClassMethod;

};


