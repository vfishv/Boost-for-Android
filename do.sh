
export BOOST_DIR=$(pwd)/down/boost_src/boost_1_71_0/


export NDK_DIR=/home/declan/zone/low/Boost-for-Android/down/ndk/20

#export ARCHLIST="arm64-v8a" 
export ARCHLIST="arm64-v8a armeabi-v7a x86 x86_64"

#exporet LINKAGE_LIST="shared"
export LINKAGE_LIST="shared static" # can be "shared" or "static" or "shared static" (both)

./build.sh
