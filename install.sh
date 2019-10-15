
# see here for info on "new paths for toolchains":
# https://developer.android.com/ndk/guides/other_build_systems

# also useful ndk details:
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md


#----------------------------------------------------

BUILD_DIR=$(pwd)/build
BUILD_DIR_OUT=${BUILD_DIR}/out
mkdir --parents ${BUILD_DIR_OUT}


BUILD_DIR_OUT_TMP=${BUILD_DIR_OUT}/tmp
#mkdir --parents ${BUILD_DIR_OUT_TMP}

PREFIX_DIR=${BUILD_DIR_OUT}/prefix



str0="libboost_system.so.1.71.0"
str1="libboost_system.so.1.71"
str2="libboost_system.so.1.71.0.12"
str3="libboost_system.so.10.71.0989"


# fullname
# "^libboost_(.*)\.so(.[[:digit:]]+){3}$"
# echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 
# libboost_system.so.1.71.0

# # basename
# "^libboost_(.*)\.so(?=(.[[:digit:]]+){3}$)" 
# echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(?=(.[[:digit:]]+){3}$)" 
# "libboost_system.so"


Re0="^libboost_(.*)\.so"
Re1="(.[[:digit:]]+){3}$" 
#Re1="(.[0-9]+){3}$"


#echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 
echo "-----------------------------"
echo "0: " 
echo $str0 | grep -P ${Re0}${Re1}
echo $str0 | grep -Po ${Re0}"(?="${Re1}")"

echo "1: " 
echo $str1 | grep -P ${Re0}${Re1}
echo $str2 | grep -Po ${Re0}"(?="${Re1}")"

echo "2: " 
echo $str2 | grep -P ${Re0}${Re1}
echo $str2 | grep -Po ${Re0}"(?="${Re1}")"

echo "3: " 
echo $str3 | grep -P ${Re0}${Re1}
echo $str3 | grep -Po ${Re0}"(?="${Re1}")"


echo "Those names not matching - should be deleted"
echo "0v: " 
echo $str0 | grep -P -v ${Re0}${Re1}

echo "1v: " 
echo $str1 | grep -P -v ${Re0}${Re1}
echo "2v: " 

echo $str2 | grep -P -v ${Re0}${Re1}

echo "3v: " 
echo $str3 | grep -P -v ${Re0}${Re1}





# todo do a second step install where versioned libraries are copied (without version numbers) to a different dir structure (with single "include/" and "libs/armeabi-v7a/")
# also need to run patchelf to remove the versioning from the libs soname
# > patchelf --set-soname libboost_chrono.so ./libboost_chrono.so





#echo "libboost_system.so.1.71.0" | grep "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 

#echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 
