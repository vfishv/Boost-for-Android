

#include "jc_jni_env.h"
#include "jc_jni_man.h"
#include "jc_utils.h"


//-----------------------------------------------
JcJniEnv::JcJniEnv(JNIEnv *Env)
    :_Env(Env)
{
   attach(JcJniMan::jvm());
}
//------------------------------------------
JcJniEnv::~JcJniEnv()
{
    detach(JcJniMan::jvm());
}
//------------------------------------------
JNIEnv * JcJniEnv::attach(JavaVM * Jvm)
{
    if(!Jvm)
        Jvm = JcJniMan::jvm();

    if(!Jvm)
        return nullptr;

    if(!_Env)
    {
        JcUtils::logThread("JcJniEnv::attach - before ");
        jint ret = Jvm->AttachCurrentThread(&_Env, nullptr);
        JcUtils::logThread("JcJniEnv::attach - after  ");
      // bool ok = false;
        bool ok = (ret ==JNI_OK);
        if(!ok)
           int halt =1;
    }
    //return _Env;
    return nullptr;

}
//------------------------------------------
bool JcJniEnv::detach(JavaVM * Jvm)
{
    if(!Jvm)
        Jvm = JcJniMan::jvm();

    if(!Jvm || !env())
        return false;


    JcUtils::logThread("JcJniEnv::detach - before ");

    Jvm->DetachCurrentThread();

    JcUtils::logThread("JcJniEnv::detach - after  ");

    _Env = nullptr;

    return true;
}