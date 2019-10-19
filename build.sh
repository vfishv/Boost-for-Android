
# see here for info on "new paths for toolchains":
# https://developer.android.com/ndk/guides/other_build_systems

# also useful ndk details:
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md

SAVED_PATH=$PATH 
export PATH=$(pwd)/bin:$SAVED_PATH

#----------------------------------------------------


BUILD_DIR=$(pwd)/build
mkdir --parents ${BUILD_DIR}


BUILD_DIR_TMP=${BUILD_DIR}/tmp

PREFIX_DIR=${BUILD_DIR}/install
mkdir --parents ${PREFIX_DIR}
 
LIBS_DIR=${PREFIX_DIR}/libs
INCLUDE_DIR=${PREFIX_DIR}/include

WITHOUT_LIBRARIES=--without-python
WITH_LIBRARIES="--with-chrono --with-system"


#----------------------------------------------------------------------------------
# map ARCH to toolset name (following "using clang :") used in user-config.jam
toolset_for_abi_name() {


    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "arm64v8a"
        ;;
        armeabi-v7a)    echo "armeabiv7a"
        ;;
        x86)            echo "x86"
        ;;
        x86_64)         echo "x8664"
        ;;
        
    esac
}
#----------------------------------------------------------------------------------
abi_for_abi_name() {


    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "aapcs"
        ;;
        armeabi-v7a)    echo "aapcs"
        ;;
        x86)            echo "sysv"
        ;;
        x86_64)         echo "sysv"
        ;;
        
    esac
    
}
#----------------------------------------------------------------------------------
arch_for_abi_name() {

    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "arm"
        ;;
        armeabi-v7a)    echo "arm"
        ;;
        x86)            echo "x86"
        ;;
        x86_64)         echo "x86"
        ;;
        
    esac
    
}

#----------------------------------------------------------------------------------
address_model_for_abi_name() {

    local abi_name=$1
    
    case "$abi_name" in
        arm64-v8a)      echo "64"
        ;;
        armeabi-v7a)    echo "32"
        ;;
        x86)            echo "32"
        ;;
        x86_64)         echo "64"
        ;;
        
    esac
    
}
#----------------------------------------------------------------------------------
# write the ndk version to a header file for future reference and programmatic querying
persist_ndk_version()
{
    # get the version string from the "Pkg.Revision" attribute in the $ANDROID_NDK_ROOT"/source.properties" file
    # and write this to a new header file (beside include/boost/version.hpp which documents the boost version)
    local source_properties=${NDK_DIR}/source.properties
    
    local dir_path=${PREFIX_DIR}/include/boost
    mkdir --parents $dir_path
    local headerFile=${dir_path}/version_ndk.hpp
    
   
   local version=$(sed -En -e 's/^Pkg.Revision\s*=\s*([0-9a-f]+)/\1/p' $source_properties)
    
   
   echo "writing NDK version $version to $headerFile "
    
   echo '#ifndef BOOST_VERSION_NDK_HPP'  > $headerFile
   echo '#define BOOST_VERSION_NDK_HPP' >> $headerFile

   echo -e '\n//The version of the NDK used to build boost' >>  $headerFile
   echo -e " #define BOOST_BUILT_WITH_NDK_VERSION  \"$version\" \\n" >>$headerFile
   
   echo '#endif' >>$headerFile
    

}

#----------------------------------------------------------------------------------
fix_version_suffices() {

# 1) remove files that are symbolic links 
# 2)  remove version suffix on (remaining):
#   a) file names and 
#   b) in the "soname" of the elf header
 

    Re0="^libboost_(.*)\.so"
    Re1="(.[[:digit:]]+){3}$" 
    #Re1="(.[0-9]+){3}$"

    #echo "+++++++++++++++++++++++++++"
    for DIR_NAME in $ABI_NAMES; do
    
        DIR_PATH=$LIBS_DIR/$DIR_NAME
      #  echo ""
       # echo "DIR_PATH = " $DIR_PATH
        FILE_NAMES=$(ls $DIR_PATH)
       # echo "$FILE_NAMES"
        
       # echo ""
       # echo "should delete:"
       # echo "--------------"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo $FILE_NAME |  grep -Pv  ${Re0}${Re1})
       #     echo "checking file " $Del_File
            if [ ! -z "$File" ]  && ! [[ $File == cmake* ]] && ! [[ $File == *.a ]]
            then 
       #         echo $File
                rm $DIR_PATH/$File
                
            fi    
        done    
        
        #echo ""
        #echo "should NOT delete:"
        #echo "------------------"
        for FILE_NAME in $FILE_NAMES; do
            File=$(echo $FILE_NAME |  grep -P  ${Re0}${Re1})
            
            if [ ! -z "$File" ] 
            then 
                NEW_NAME=$(echo $FILE_NAME | grep -Po ${Re0}"(?="${Re1}")")
            # echo $File " ->" $NEW_NAME
                mv $DIR_PATH/$File $DIR_PATH/$NEW_NAME
                # patchelf --set-soname $NEW_NAME $DIR_PATH/$NEW_NAME
            fi 
            
        done 
    done
}


#----------------------------------------------------------------------------------
#----------------------------------------------------------------------------------


USER_CONFIG_FILE=$(pwd)/user-config.jam

cd $BOOST_DIR

#-------------------------------------------
# Bootstrap
# ---------
if [ ! -f ${BOOST_DIR}/b2 ]
then
  # Make the initial bootstrap
  echo "Performing boost bootstrap"

  ./bootstrap.sh # 2>&1 | tee -a bootstrap.log
fi
  
#-------------------------------------------  

# use as many cores as available (for build)
num_cores=$(grep -c ^processor /proc/cpuinfo)
echo " cores available = " $num_cores 




#------------------------------------------- 
                



for LINKAGE in $LINKAGES; do

    for ABI_NAME in $ABI_NAMES; do
    
        toolset_name="$(toolset_for_abi_name $ABI_NAME)"
        abi="$(abi_for_abi_name $ABI_NAME)"
        address_model="$(address_model_for_abi_name $ABI_NAME)"
        arch_for_abi="$(arch_for_abi_name $ABI_NAME)"
        
        {
            ./b2 -q -j$num_cores    \
                toolset=clang-$toolset_name     \
                binary-format=elf \
                address-model=$address_model \
                architecture=$arch_for_abi \
                abi=$abi    \
                link=$LINKAGE                  \
                threading=multi              \
                target-os=android           \
                --user-config=$USER_CONFIG_FILE \
                --ignore-site-config         \
                --layout=system           \
                $WITH_LIBRARIES           \
                --build-dir=${BUILD_DIR_TMP}/$ABI_NAME \
                --includedir=${INCLUDE_DIR} \
                --libdir=${LIBS_DIR}/$ABI_NAME \
                install 2>&1                 \
                || { echo "Error: Failed to build boost for $ABI_NAME!";}
        } | tee -a ${BUILD_DIR}/build.log
        
    done # for ARCH in $ARCHLIST
    
done # for LINKAGE in $LINKAGE_LIST

#------------------------------------------- 


persist_ndk_version

fix_version_suffices

echo "built boost to "  ${PREFIX_DIR}


export PATH=$SAVED_PATH



