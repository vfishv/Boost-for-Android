

#include <chrono>
#include "jc_jni_man.h"
#include "jc_utils_jni.h"
#include "jc_utils.h"
#include "jc_jni_env.h"
#include "jc_jni_env_man.h"

using std::string;

//-------------------------------------------------
//-------------------------------------------------
JavaVM * JcJniMan::_Jvm = nullptr;
jobject JcJniMan::_ClassLoader = nullptr;
jmethodID JcJniMan::_FindClassMethod=nullptr;
//-------------------------------------------------
//-------------------------------------------------

jint JcJniMan::onLoad(JavaVM *Jvm)
{
    _Jvm = Jvm;

    auto env = getEnv();

    // Needed for FindClass
    // http://yangyingchao.github.io/Android-JNI-FindClass-Error/
    // Solution 2 (Solution 1 doesnt seem t work), with addition of "NewGlobalRef" below

    auto NmClass = env->FindClass("com/jenetric/livestage/JcNativeMan");
    jclass NmClassClass = env->GetObjectClass(NmClass);
    auto classLoaderClass = env->FindClass("java/lang/ClassLoader");
    auto getClassLoaderMethod = env->GetMethodID(NmClassClass, "getClassLoader", "()Ljava/lang/ClassLoader;");

    // Strictly speaking would need to call DeleteLocalRef(_ClassLoader), to free when no longer needed
    // ..but will be needed till closing app (at which point it becomes superfluous), so wont bother
    _ClassLoader = env->NewGlobalRef(env->CallObjectMethod(NmClass, getClassLoaderMethod));

    _FindClassMethod = env->GetMethodID(classLoaderClass, "findClass",
                                        "(Ljava/lang/String;)Ljava/lang/Class;");

    return JNI_VERSION_1_6;
}

jclass JcJniMan::findClass(const char* name)
{
    JNIEnv * Env = getEnv();
    jstring methodName = JcUtils_Jni::jstr_from_cstr(Env, name);

    jobject Obj = Env->CallObjectMethod(_ClassLoader, _FindClassMethod, methodName);
    jclass Cls = static_cast<jclass>(Obj);

    Env->DeleteLocalRef(methodName);

    return Cls;
}

JNIEnv *JcJniMan::getEnv()
{
    return JcJniEnvMan::getEnv();
}

bool JcJniMan::ensureThreadDetached()
{
    JcJniEnvMan::ensureThreadDetached();
}

void JcJniMan::checkException()
{
    JNIEnv * Env = getEnv();
    if(!Env)
    {
        JcUtils::logIt("JcJniMan::checkException .. couldnt get Env");
        return;
    }
    if (Env->ExceptionCheck()) {
        Env->ExceptionDescribe();
    }
}

bool JcJniMan::uiShowText(std::string text, JNIEnv *Env)
{
    if(!Env) {
        Env = getEnv();
    }
    if(!Env) {
        return false;
    }
    jstring jstrText  = JcUtils_Jni::jstr_from_str(Env, text);
    jclass nativeManager = findClass("com/jenetric/livestage/JcNativeMan");

    jmethodID onTextReady = Env->GetStaticMethodID(nativeManager, "onTextReady", "(Ljava/lang/String;)V");
    if(!onTextReady) {
        return false;
    }
    Env->CallStaticVoidMethod(nativeManager, onTextReady, jstrText);

    Env->DeleteLocalRef(jstrText);
    Env->DeleteLocalRef(nativeManager);

    return true;
}

bool JcJniMan::uiShowImg(JcImgData imgData, JNIEnv *Env)
{
    if(!Env) {
        Env = getEnv();
    }
    if(!Env) {
        return false;
    }

    // findClass and GetStaticMethodID takes 0ms
    jclass nativeManager = findClass("com/jenetric/livestage/JcNativeMan");
    jmethodID onImageReady = Env->GetStaticMethodID (nativeManager, "onImageReady", "([III)V");
    if(!onImageReady) {
        return false;
    }

    auto timeStart = std::chrono::high_resolution_clock::now();
    jintArray  imgDataJintArray  = JcUtils_Jni::jintArr_from_uint32tVec(Env, imgData.data);
    auto timeEnd = std::chrono::high_resolution_clock::now();

    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(timeEnd - timeStart).count();
    std::string durationString  = std::to_string(duration) + "ms" ;
    JcJniMan::uiShowText("jintArr_from_uint32tVec took " + durationString);

    timeStart = std::chrono::high_resolution_clock::now();
    Env->CallStaticVoidMethod(nativeManager, onImageReady, imgDataJintArray, imgData.w, imgData.h);
    timeEnd = std::chrono::high_resolution_clock::now();
    duration = std::chrono::duration_cast<std::chrono::milliseconds>(timeEnd - timeStart).count();
    durationString  = std::to_string(duration) + "ms" ;
    JcJniMan::uiShowText("Call onImageReady took " + durationString);

    Env->DeleteLocalRef(nativeManager); // takes 0ms
    Env->DeleteLocalRef(imgDataJintArray); // takes 0ms

    return true;
}

bool JcJniMan::uiShowImg(jlong cvMatRowPtr, jint rows, jint cols, JNIEnv *Env)
{
    if(!Env) {
        Env = getEnv();
    }
    if(!Env) {
        return false;
    }
    jclass nativeManager = findClass("com/jenetric/livestage/JcNativeMan");
    jmethodID onImageReady = Env->GetStaticMethodID (nativeManager, "onImageReady", "([III)V");
    if(!onImageReady) {
        return false;
    }

    //jintArray  jia  = JcUtils_Jni::jintArr_from_uint32tVec(Env, Id.data);
//
//    Env->CallStaticVoidMethod(Cls, onImageReady, jia, Id.w, Id.h);
//
//    Env->DeleteLocalRef(Cls);
//    Env->DeleteLocalRef(jia);

    return true;
}