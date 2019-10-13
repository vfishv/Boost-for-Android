# Copyright (c) 2019 Declan Moran (www.silverglint.com)

# Extract boost (src) archive to a directory of the form "major.minor.patch" 
# so that the dir name ~  boost version (eg "1.69.0")
#---------------------------------------------------------------------------------
# Example script. Modify the variables below as appropriate for your local setup.
#---------------------------------------------------------------------------------





# Specify the path to boost source code dir 
#BOOST_SRC_DIR=/home/declan/Documents/zone/low/Boost-for-Android/src
#BOOST_SRC_DIR=/home/docker-share/boost-src
BOOST_SRC_DIR=/home/bfa/down/boost_src

#------------------------------------------------------------------------------------------
# Specify the version of boost youre building
#BOOST_VERSION=1.69.0
BOOST_VERSION=1.69.0

#------------------------------------------------------------------------------------------
# Specify path to the (Google) Ndk  (by default  downloded to "..sdk/ndk-bundle" by android studio)
#export ANDROID_NDK_ROOT=/home/android/android-ndk-r19c
export ANDROID_NDK_ROOT=/home/bfa/down/ndk/19c

# see here for info on "new paths for toolchains":
# https://developer.android.com/ndk/guides/other_build_systems

# also useful ndk details:s 
# https://android.googlesource.com/platform/ndk/+/master/docs/BuildSystemMaintainers.md
#------------------------------------------------------------------------------------------
# Modify if desired
# log file where build messages will be stored
logFile=build_out.txt
rm $logFile

#------------------------------------------------------------------------------------------
# the build script writes some extra info to this file if its defined (but will be in "split" across different dirs)
#export NDK_LOGFILE=ndk_log_out.txt



# The options --stdlibs, --abis and --linkage can be one or more of the listed possible values. If you specify more than one, then separate individual values by a comma
#------------------------------------------------------------------------------------------
# which compiler to use       // gnu-4.9 removed as of ndk 16
STD_LIBS="llvm"
  

# which abis (~ architecture + instruction set) to build for     
# possible values:  {armeabi-v7a,arm64-v8a,x86,x86_64}
ABIS="armeabi-v7a"
#ABIS="armeabi-v7a,arm64-v8a,x86,x86_64"
#ABIS="x86_64"

# whether to build shared or static libraries (or both)          
# possible values:   {shared, static}
 LINKAGE="shared"               
#LINKAGE="shared,static"


#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Build Boost  (the actual call) - dont modify
#---------------------------------------------

./build_tools/build-boost.sh --version=$BOOST_VERSION --stdlibs=$STD_LIBS --abis=$ABIS  --ndk-dir=$ANDROID_NDK_ROOT --linkage=$LINKAGE --verbose $BOOST_SRC_DIR  2>&1 | tee -a $logFile

# mine:
#     echo "........Running b2 with: NUM_JOBS = "$NUM_JOBS" address-model = "$BJAMADDRMODEL" architecture = "$BJAMARCH" abi  = "$BJAMABI "WITHOUT  = "$WITHOUT "  PREFIX = "$PREFIX " BUILD_DIR  = "$BUILD_DIR  "

#........Running b2 with: NUM_JOBS = 12, address-model = 32, architecture = arm, abi  = aapcs, WITHOUT  =  --without-python   PREFIX = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost/armeabi-v7a/llvm/install  BUILD_DIR  = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost

#........Running b2 with: NUM_JOBS = 12, address-model = 64, architecture = arm, abi  = aapcs, WITHOUT  =  --without-python   PREFIX = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost/arm64-v8a/llvm/install  BUILD_DIR  = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost

#........Running b2 with: NUM_JOBS = 12, address-model = 32, architecture = x86, abi  = sysv, WITHOUT  =  --without-python   PREFIX = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost/x86/llvm/install  BUILD_DIR  = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost

#........Running b2 with: NUM_JOBS = 12, address-model = 64, architecture = x86, abi  = sysv, WITHOUT  =  --without-python   PREFIX = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost/x86_64/llvm/install  BUILD_DIR  = /home/bfa/build_tools/../build_tmp/tmp/build-17419/build-boost


# NB:   address-model   = 32 | 64, 
#       architecture    = arm | x86, 
#       abi             = aapcs | sysv,



# wundke:
# echo "........Running bjam with: NCPU = "$NCPU" target-os = "$TARGET_OS" toolset = "$TOOLSET_ARCH" cflag = "$cflag" cflag = "$cflag" cxxflags  = "$cxxflags " WITHOUT_LIBRARIES  = "$WITHOUT_LIBRARIES  " ARCH  = "$ARCH " LIBRARIES  =

# different to wundke:
#         binary-format=elf \
#         address-model=$BJAMADDRMODEL \
#         architecture=$BJAMARCH \
#         abi=$BJAMABI \
#         --user-config=user-config.jam \
#         --layout=system \

# wundke call to bjam:
# echo "........Running bjam with: NCPU = "$NCPU" target-os = "$TARGET_OS" toolset = "$TOOLSET_ARCH" cflag = "$cflag" cxxflags  = "$cxxflags " WITHOUT_LIBRARIES  = "$WITHOUT_LIBRARIES  " ARCH  = "$ARCH " LIBRARIES  = "$LIBRARIES " 

# ........Running bjam with: NCPU = 6 target-os = android, toolset  = clang-arm64v8a,     ARCH  = arm64-v8a       cflag =  cxxflags  =   WITHOUT_LIBRARIES  = --without-python   LIBRARIES  =   LIBRARIES_BROKEN   = 
# ........Running bjam with: NCPU = 6 target-os = android, toolset  = clang-armeabiv7a,   ARCH  = armeabi-v7a     cflag =  cxxflags  =   WITHOUT_LIBRARIES  = --without-python   LIBRARIES  =   LIBRARIES_BROKEN   = 
# ........Running bjam with: NCPU = 6 target-os = android, toolset  = clang-x86,          ARCH  = x86             cflag =  cxxflags  =   WITHOUT_LIBRARIES  = --without-python   LIBRARIES  =   LIBRARIES_BROKEN   = 
# ........Running bjam with: NCPU = 6 target-os = android, toolset  = clang-x8664,        ARCH  = x86_64          cflag =  cxxflags  =   WITHOUT_LIBRARIES  = --without-python   LIBRARIES  =   LIBRARIES_BROKEN   = 

# NB:   target-os = android (but android not mentioned as option in boost doc)
#   toolset  = clang-armeabiv7a,
#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Build example app (the actual call) - dont modify
#  (could alternately do this from android studio)
#--------------------------------------------------
# 
#     cd example_app
#     # adapt local.properties. ndk.dir, booost.dir should match above. sdk.dir should match dockerfile
#     # ----------------------
#     
#     PROPS_FILE=local.properties
#     LOC_PROPS_FILE_OLD=${LOC_PROPS_FILE}_old
# 
#     if [ -f $LOC_PROPS_FILE_OLD ]; then rm -f $LOC_PROPS_FILE_OLD; fi
#     mv $LOC_PROPS_FILE $LOC_PROPS_FILE_OLD
# 
#     echo "sdk.dir="/home/android                   >> $LOC_PROPS_FILE
#     echo "ndk.dir="$ANDROID_NDK_ROOT               >> $LOC_PROPS_FILE
#     echo "boost.dir=/home/bfa/build/boost/$BOOST_VERSION  >> $LOC_PROPS_FILE
# 
# 
#     # build
#     #-------
#     cd example_app
#     ./gradlew assembleDebug

