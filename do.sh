
export BOOST_DIR=$(pwd)/../down/boost/1.71.0


export NDK_DIR=$(pwd)/../down/ndk/20

export ABI_NAMES="armeabi-v7a" 
#export ABI_NAMES="arm64-v8a armeabi-v7a x86 x86_64"

export LINKAGES="static"
#export LINKAGES="shared static" # can be "shared" or "static" or "shared static" (both)

./build.sh
