# Copyright (c) 2019 Declan Moran (www.silverglint.com)

# Extract boost (src) archive to a directory of the form "major.minor.patch" 
# such that eg ...../1.71.0/bootstrap.sh, etc



#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Modify the variables below as appropriate for your local setup.
#----------------------------------------------------------------



# Specify the path to boost source code dir 
#BOOST_SRC_DIR=/home/declan/Documents/zone/low/Boost-for-Android/src
BOOST_SRC_DIR=/home/declan/zone/low/boost/Boost-for-Android/down/boost

#------------------------------------------------------------------------------------------
# Specify the version of boost youre building
BOOST_VERSION=1.71.0

#------------------------------------------------------------------------------------------
# Specify path to the (Google) Ndk  (by default  downloded to "..sdk/ndk-bundle" by android studio)
export ANDROID_NDK_ROOT=/home/declan/zone/low/boost/Boost-for-Android/down/ndk/20

#------------------------------------------------------------------------------------------
# Modify  (optional)
# log file where build messages will be stored
logFile=build_log.txt



# which abis (~ architecture + instruction set) to build for     
# possible values:  {armeabi-v7a,arm64-v8a,x86,x86_64}

ABIS="armeabi-v7a,arm64-v8a,x86,x86_64"
#ABIS="arm64-v8a"
  
# can be "shared" or "static" or "shared,static" (both)
# LINKAGE="shared"               
LINKAGE="shared,static"





#--------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------
# Do -NOT- modify  below here. 
#-----------------------------

# empty logFile 
if [ -f "$logFile" ]  
then 
    rm $logFile
fi          
          
./build_tools/build-boost.sh --version=$BOOST_VERSION  --abis=$ABIS  --ndk-dir=$ANDROID_NDK_ROOT --linkage=$LINKAGE --verbose $BOOST_SRC_DIR  2>&1 | tee -a $logFile




