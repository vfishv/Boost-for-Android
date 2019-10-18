str="COMMAND: aarch64-linux-android21-clang++ -o /home/libboost_system.so -Wl,-soname -Wl,libboost_system.so.1.71.0 -shared -Wl,--start-group /home/error_code.o -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden"



str_full="COMMAND: aarch64-linux-android21-clang++ -o /home/declan/zone/low/Boost-for-Android/build/tmp/arm64-v8a/boost/bin.v2/libs/system/build/clang-linux-arm64v8a/release/target-os-android/threading-multi/visibility-hidden/libboost_system.so.1.71.0 -Wl,-soname -Wl,libboost_system.so.1.71.0 -shared -Wl,--start-group /home/declan/zone/low/Boost-for-Android/build/tmp/arm64-v8a/boost/bin.v2/libs/system/build/clang-linux-arm64v8a/release/target-os-android/threading-multi/visibility-hidden/error_code.o -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden"






echo "tst.."
  two="${str_full//.so.1.71.0____/.so}"
echo "two -$two"
      
      
PARAMS="${@//.so.1.71.0/.so}"
    
echo "#- PARAMS: aarch64-linux-android21-clang++ $PARAMS"      
