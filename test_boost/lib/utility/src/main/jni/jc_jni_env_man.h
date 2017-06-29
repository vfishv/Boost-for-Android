#pragma once

#include <jni.h>

#include <boost/thread/tss.hpp>

class JcJniEnv;

/// Env ~ java thread
//-----------------------------------------------
// Wrapper for calls to getEnv()
// returns current Env if there is one (ie on main/java thread)

// otherwise creates a new JNIEnv* and attaches it to a new Java thread
// doing so enables c++ to call Java fns from this thread.
// boost::thread_specific_ptr and JcJniEnv  are instrumental in this bookkeeping
// thread_specific_ptr ensures ~JcJniEnv() gets called, and ~JcJniEnv() ensures cleanup happens
class JcJniEnvMan
{

public:
    static JNIEnv *getEnv();
    static bool ensureThreadDetached();

private:
//----------------------------------------------------
// Each thread needs to work with its own copy of JNIEnv
// JcJniEnv wraps JniEnv, with its dtr calling detach() on the JniEnv
// JcJniEnvPtr is a thread specific copy of (ptr to) JcJniEnv, which calls delete on JcJniEnv (thereby calling its dtr -> detach) when thread terminates
// delete is also called when _JcEnvPtr::reset is called
    static boost::thread_specific_ptr<JcJniEnv> _JcEnvPtr;

};



