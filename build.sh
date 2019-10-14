
# see here for info on "new paths for toolchains":
# https://developer.android.com/ndk/guides/other_build_systems

# also useful ndk details:
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md


#----------------------------------------------------

BUILD_DIR=$(pwd)/build
mkdir --parents $BUILD_DIR

PREFIX_DIR=${BUILD_DIR}/install

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
#-----------------------------------------
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
            ./b2 -d+2 -q  -j$num_cores    \
                binary-format=elf \
                address-model=$address_model \
                architecture=$arch_for_abi \
                abi=$abi    \
                toolset=clang-$toolset_name     \
                link=$LINKAGE                  \
                threading=multi              \
                target-os=android           \
                --ignore-site-config         \
                --user-config=$USER_CONFIG_FILE \
                --layout=system           \
                $WITH_LIBRARIES           \
                --build-dir=${BUILD_DIR}/tmp/$ABI_NAME \
                --prefix=${PREFIX_DIR}/$ABI_NAME \
                install 2>&1                 \
                || { echo "Error: Failed to build boost for $ARCH!";}
        } | tee -a ${BUILD_DIR}/build.log
        
    done # for ARCH in $ARCHLIST
    
done # for LINKAGE in $LINKAGE_LIST



persist_ndk_version

echo "built boost to "  ${PREFIX_DIR}

