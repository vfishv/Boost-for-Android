#pragma once

#include <jni.h>


//-------------------------------------------------
// Wrapper for JNIEnv *
// JcJniEnv() ensures attached and ~JcJniEnv() ensures detached
class JcJniEnv
{
public:
    JcJniEnv(JNIEnv *Env = nullptr);
    ~JcJniEnv();

    JNIEnv * attach(JavaVM * Jvm = nullptr);
    bool detach(JavaVM * Jvm = nullptr);

    JNIEnv * env(){ return _Env;}

private:
    JNIEnv * _Env = nullptr;


};



