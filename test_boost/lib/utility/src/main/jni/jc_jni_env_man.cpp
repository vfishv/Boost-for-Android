//
// Created by declan on 02/05/17.
//

#include "jc_jni_env_man.h"
#include "jc_jni_env.h"
#include "jc_jni_man.h"
#include "jc_utils.h"


//----------------------------------------------------
boost::thread_specific_ptr<JcJniEnv> JcJniEnvMan::_JcEnvPtr;
//-----------------------------------------------

bool JcJniEnvMan::ensureThreadDetached()
{
    JcUtils::logThread("JcJniEnvMan::ensureThreadDetached() ");
    JcJniEnv * JcEnv = _JcEnvPtr.get();
    if(JcEnv)
    {
        JcEnv->detach();
        JcUtils::logThread("....JcEnv->detach()...");
    }


}
//-----------------------------------------------
JNIEnv *JcJniEnvMan::getEnv()
{

    JavaVM * Jvm = JcJniMan::jvm();

    if(!Jvm)
        return nullptr;

    JNIEnv *Ret = nullptr;
    void ** Env_vp = reinterpret_cast<void **>(&Ret);
    int res = Jvm->GetEnv(Env_vp, JcJniMan::jniVersion());

    // only need JcEnv in JNI_EDETACHED case, but have to declare it outside switch
    JcJniEnv * JcEnv = nullptr;

    // jint ver = Ret->GetVersion();

    switch(res)
    {

        case(JNI_OK) :
            // in a thread started by java .. no need to attach (explicitly)
            break;

        case (JNI_EDETACHED):
            // in a cpp thread which hasn't been attached to jvm .. try doing so now
            // save in a thread_local var, the dtr of which will call detach (just before) cpp thread exits
            JcEnv = _JcEnvPtr.get();
            if(!JcEnv)
            {
                JcEnv = new JcJniEnv();
                _JcEnvPtr.reset(JcEnv);

                 Ret = JcEnv->env();
            }

            break;

        case (JNI_EVERSION):
            JcUtils::logIt("JcJniMan::getEnv() -> Jvm->GetEnv() .. wrong JNI version requested");
            // could try calling again with earlier version
            break;

    }
    return Ret;
}
