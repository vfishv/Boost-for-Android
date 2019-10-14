
export BOOST_DIR=$(pwd)/down/boost/1.71.0


export NDK_DIR=$(pwd)/down/ndk/20

#export ARCHLIST="arm64-v8a" 
export ARCHLIST="arm64-v8a armeabi-v7a x86 x86_64"

#exporet LINKAGE_LIST="shared"
export LINKAGE_LIST="shared static" # can be "shared" or "static" or "shared static" (both)

./build.sh
