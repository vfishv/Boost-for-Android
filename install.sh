# 
# # see here for info on "new paths for toolchains":
# # https://developer.android.com/ndk/guides/other_build_systems
# 
# # also useful ndk details:
# # https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md
# 
# 
# #----------------------------------------------------
# 
# # BUILD_DIR=$(pwd)/build
# # BUILD_DIR_OUT=${BUILD_DIR}/out
# # mkdir --parents ${BUILD_DIR_OUT}
# # 
# # 
# # BUILD_DIR_OUT_TMP=${BUILD_DIR_OUT}/tmp
# # #mkdir --parents ${BUILD_DIR_OUT_TMP}
# 
 PREFIX_DIR=$(pwd)/build/install
 mkdir --parents ${PREFIX_DIR}
# 
# 
# 
# str0="libboost_system.so.1.71.0"
# str1="libboost_system.so.1.71"
# str2="libboost_system.so.1.71.0.12"
# str3="libboost_system.so.10.71.0989"


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

# 
# #echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 
# echo "-----------------------------"
# echo "0: " 
# echo $str0 | grep -P ${Re0}${Re1}
# echo $str0 | grep -Po ${Re0}"(?="${Re1}")"
# 
# echo "1: " 
# echo $str1 | grep -P ${Re0}${Re1}
# echo $str2 | grep -Po ${Re0}"(?="${Re1}")"
# 
# echo "2: " 
# echo $str2 | grep -P ${Re0}${Re1}
# echo $str2 | grep -Po ${Re0}"(?="${Re1}")"
# 
# echo "3: " 
# echo $str3 | grep -P ${Re0}${Re1}
# echo $str3 | grep -Po ${Re0}"(?="${Re1}")"
# 
# echo "-----------------------------"
# echo "Those names not matching - should be deleted"
# echo "0v: " 
# echo $str0 | grep -P -v ${Re0}${Re1}
# 
# echo "1v: " 
# echo $str1 | grep -P -v ${Re0}${Re1}
# echo "2v: " 
# 
# echo $str2 | grep -P -v ${Re0}${Re1}
# 
# echo "3v: " 
# echo $str3 | grep -P -v ${Re0}${Re1}




#----------------------------------------------------------------------------------
fix_version_suffices() {

# 1) remove files that are symbolic links 
# 2)  remove version suffix on (remaining):
#   a) file names and 
#   b) in the "soname" of the elf header
 



    #echo "+++++++++++++++++++++++++++"
    for DIR_NAME in $ABI_NAMES; do
    
        DIR_PATH=$PREFIX_DIR/$DIR_NAME
       # echo ""
       # echo "DIR_PATH = " $DIR_PATH
        FILE_NAMES=$(ls $DIR_PATH)
      #  echo "$FILE_NAMES"
        
       # echo ""
       # echo "should delete:"
       # echo "--------------"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo $FILE_NAME |  grep -Pv  ${Re0}${Re1})
            echo "checking file " $Del_File
            if [ ! -z "$File" ]  && ! [[ $File == cmake* ]]
            then 
        #        echo $File
                rm $DIR_PATH/$File
                
            fi    
        done    
        
       # echo ""
       # echo "should NOT delete:"
       # echo "------------------"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo $FILE_NAME |  grep -P  ${Re0}${Re1})
            
            if [ ! -z "$File" ] 
            then 
                NEW_NAME=$(echo $FILE_NAME | grep -Po ${Re0}"(?="${Re1}")")
         #       echo $File " ->" $NEW_NAME
                mv $DIR_PATH/$File $DIR_PATH/$NEW_NAME
                patchelf --set-soname $NEW_NAME $DIR_PATH/$NEW_NAME
            fi 
           # $NEW_NAME= $(echo $FILE_NAME | grep -Po ${Re0}"(?="${Re1}")"
            
        done 
        
    done
}


# todo do a second step install where versioned libraries are copied (without version numbers) to a different dir structure (with single "include/" and "libs/armeabi-v7a/")
# also need to run patchelf to remove the versioning from the libs soname
# > patchelf --set-soname libboost_chrono.so ./libboost_chrono.so

# check with 
# > readelf -a ./libboost_system.so | grep soname






#echo "libboost_system.so.1.71.0" | grep "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 

#echo "libboost_system.so.1.71.0" | grep -Po "^libboost_(.*)\.so(.[[:digit:]]+){3}$" 
