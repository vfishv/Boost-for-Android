# Boost for Android


Modified original ([official](https://github.com/moritz-wundke/Boost-for-Android)  to allow modern boost versions (eg boost 1.64.0)

Also added a test app (see ./test-boost).
To use the test app make sure to set some paths in local.properties (see local.properties_example)


The build of boost 1.64.0 itself but can seem to link to simple test app  which can be opened with android studio, and uses gradle experimental).
Get "ld error incompatible target", which I cant seem to get rid of.



(Support for crystax has been dropped since that comes with prebuilt boost binaries and a dedicated build script if you want to customize.)

The file "configs/user-config-boost-1_64_0.jam" is copied during the build to "user-config.jam" and contains compiler and linker settings that will be passed to gcc.
