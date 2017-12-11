# Boost for Android


Builds the [Boost C++ Libraries](http://www.boost.org/) for the Android platform, with Google's Ndk.

Tested with **Boost 1.65.1**, together with both  **Google's Ndk 15c**  (current versions as of Sept 2017) <br>
and **Google's Ndk 16** (now shipping with Android Studio 3) 
*- please use the [ndk_16 branch](https://github.com/dec1/Boost-for-Android/tree/ndk_16) for this*

[Crystax](https://www.crystax.net/) is an excellent alternative to Google's Ndk. It ships with prebuilt boost binaries, and dedicated build scripts.
These binaries will however not work with Goolge's Ndk. If for some reason you can't or don't want to use Crystax then you can't use their boost binaries or build scripts.

This bash script is based on the Crystax build script but modified so that it will build boost with the Google Ndk.


Works with **gcc** and **clang** (llvm)
Creates binaries for multiple abis (**armeabi-v7a**, **x86**, mips etc).


*Tested with a development machine running OpenSuse Tumbleweed Linux.*

## Prerequisites

* *gcc* (required to configure boost, regardless of whether ndk's gcc or clang is used to build it. So install gcc with your os package manager or ensure the ndk version is on your path)

* You may need to have *libncurses.so.5* available on you development machine. Install via your os package manager (eg Yast) if necessary.


* Create a symbolic link *llvm-3.5* to *llvm* in the *toolchains* subdir of the ndk *(This is only necessary if you want to be able to build with clang)*

eg
```
cd path_to_ndk/toolchains
ln -s llvm llvm-3.5
```

## Usage

* Download and extract the boost source archive to a directory of the form *..../major.minor.patch* 
  eg */home/declan/Documents/zone/mid/lib/boost/1.65.1*
  
  *__Note__:* After the extarction *..../boost/1.65.1* should then be the direct parent dir of "bootstrap.sh", "boost-build.jam" etc

```
> ls /home/declan/Documents/zone/mid/lib/boost/1.65.1
boost  boost-build.jam  boostcpp.jam  boost.css  boost.png  ....
``` 


* Modify the paths (where the ndk is) and variables (which abis you want to build for, which compiler to use etc) in *doIt.sh*, and execute it.

* *__Note__:* If for some reason the build fails you may want to manually clear the */tmp/ndk-your_username* dir (which gets cleared automatically after a successful build).



## Test App 
Also included is test app which can be opened by Android Studio (see ./test-boost).
To use the test app make sure to adjust the paths in local.properties (see local.properties_example).
Note: The test app uses [Gradle Experimental](http://tools.android.com/tech-docs/new-build-system/gradle-experimental)


## *Header-only* Boost Libraries
Many of the boost libraries (eg. *algorithm*) can be used as "header only" ie do not require compilation . So you may get away with not building boost if you only
want to use these. To see which of the libraries do require building you can switch to the dir where you extracted the boost download and call:

```
> ./bootstrap.sh --show-libraries 
```

which for example with boost 1.65.1 produces the output:

```
The Boost libraries requiring separate building and installation are:
    - atomic
    - chrono
    - container
    - context
    - coroutine
    - date_time
    - exception
    - fiber
    - filesystem
    - graph
    - graph_parallel
    - iostreams
    - locale
    - log
    - math
    - metaparse
    - mpi
    - program_options
    - python
    - random
    - regex
    - serialization
    - signals
    - stacktrace
    - system
    - test
    - thread
    - timer
    - type_erasure
    - wave
```




