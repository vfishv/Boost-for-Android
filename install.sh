

NEEDED:
-------
 patchelf --remove-needed libboost_system.so.1.69.0 libboost_chrono.so 
 readelf -a libboost_chrono.so | grep NEEDED

 patchelf --add-needed libboost_system.so libboost_chrono.so 
 readelf -a libboost_chrono.so | grep NEEDED


SONAME:
-------
 readelf -a libboost_chrono.so | grep SONAME
 patchelf --set-soname libboost_system.so libboost_system.so
 patchelf --set-soname libboost_chrono.so libboost_chrono.so
 
 ----------------------------------------------------------
 
 arm64-v8a:
-----------
-----------



(1) Crystax_based:
    
Compile:
--------
 
 CXX PARAMS --1-- = -c -x c++ -fvisibility-inlines-hidden -fPIC -O3 -Wall -fvisibility=hidden -Wno-inline -DBOOST_ALL_NO_LIB=1 -DBOOST_SYSTEM_DYN_LINK=1 -DNDEBUG -I. -o 

 CXX PARAMS --2-- = -c -x c++ -fvisibility-inlines-hidden -fPIC -O3 -Wall -fvisibility=hidden -Wno-inline -DBOOST_ALL_NO_LIB=1  -DBOOST_SYSTEM_DYN_LINK=1 -DNDEBUG -I. -o   -fno-integrated-as   -I/include -Wno-long-long -fPIC  


 
Link:
----
 
 CXX PARAMS --1-- = -o -shared -Wl,--start-group  -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden  

 CXX PARAMS --2-- = -o -shared -Wl,--start-group  -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden  -fno-integrated-as -fPIC   -L/libs/arm64-v8a   -Wl,-soname -Wl,libboost_system.so   
 


(1) Jam_based:
    

 Compile:
 --------
-c -x c++ -fvisibility-inlines-hidden -fPIC -O3 -Wall -fvisibility=hidden -Wno-inline -fPIC -fno-integrated-as -DBOOST_ALL_NO_LIB=1 -DBOOST_SYSTEM_DYN_LINK=1 -DNDEBUG -I. -o 


-c -x c++ -fvisibility-inlines-hidden -fPIC -O3 -Wall -fvisibility=hidden -Wno-inline -fPIC -fno-integrated-as -DBOOST_ALL_NO_LIB=1 -DBOOST_SYSTEM_DYN_LINK=1 -DNDEBUG -I. -o 


-c -x c++ -fvisibility-inlines-hidden -fPIC -O3 -Wall -fvisibility=hidden -Wno-inline -fPIC -fno-integrated-as -Wextra -Wno-long-long -Wno-variadic-macros -pedantic -DBOOST_ALL_DYN_LINK=1 -DBOOST_ALL_NO_LIB=1 -DNDEBUG -I. 



Link:
----
 
-o  -Wl,-soname -Wl,libboost_system.so.1.71.0 -shared -Wl,--start-group  -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden

-o  -Wl,-soname -Wl,libboost_system.so.1.71.0 -shared -Wl,--start-group  -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden

-o  -Wl,-soname -Wl,libboost_chrono.so.1.71.0 -shared -Wl,--start-group  -Wl,-Bstatic -Wl,-Bdynamic -Wl,--end-group -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
