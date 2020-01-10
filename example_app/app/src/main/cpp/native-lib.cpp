#include <jni.h>
#include <string>

#include <stdio.h>
#include <boost/filesystem.hpp>
using namespace boost::filesystem;


//#include <boost/chrono.hpp>
//#include <boost/lexical_cast.hpp>

// when building boost we persisted the NDK version used (BOOST_BUILT_WITH_NDK_VERSION) in this custom header file
//#include <boost/version_ndk.hpp>


using std::string;

#include <iostream>
using std::cout;

extern "C" JNIEXPORT jstring

JNICALL
Java_com_example_declan_myapplication_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {

    string Str = "Hello from C++ ";

    boost::filesystem::path path("/sdcard"); // random pathname

    /*
    boost::filesystem::path::iterator pathI = path.begin();
    Str +="\n";
    while (pathI != path.end())
    {
        Str += pathI->string();
        Str +="\n";
        std::cout << *pathI << std::endl;
        ++pathI;
    }
    */

    if (boost::filesystem::exists(path))
    {
        Str +="\n";
        boost::filesystem::directory_iterator end_iter;
        for (boost::filesystem::directory_iterator iter(path); iter != end_iter;++iter)
        {
            Str += iter->path().filename().string();
            //Str += iter->path().string();
            Str +="\n";
            if (boost::filesystem::is_directory(iter->status()))
            {
                //filenames.push_back(iter->path().string());
            }
        }
    }





    bool result = boost::filesystem::is_directory(path);
    printf("Path is a directory : %d\n", result);

    Str += result ? "true" : "false";

/*
    //-------------------------------------
    boost::chrono::system_clock::time_point p  = boost::chrono::system_clock::now();
    std::time_t t = boost::chrono::system_clock::to_time_t(p);

    char buffer[26];
    ctime_r(&t, buffer);

    //  std::string tst = std::to_string(3);

    int ver = BOOST_VERSION;
    int ver_maj = ver/100000;
    int ver_min = ver / 100 %1000;
    int ver_pat = ver %100;

    string Ver_Maj = boost::lexical_cast<string>(ver_maj);
    string Ver_Min = boost::lexical_cast<string>(ver_min);
    string Ver_Pat = boost::lexical_cast<string>(ver_pat);

    Str += "\n Boost version: " + Ver_Maj + "." + Ver_Min + "." + Ver_Pat + "\n";
    Str += "... built with NDK version: " + string(BOOST_BUILT_WITH_NDK_VERSION) + "\n";
    Str += "... says time is " + std::string(buffer) + "\n\n";
    //--------------------------------------------
*/

    return env->NewStringUTF(Str.c_str());

}
