#!/bin/bash

# Original work Copyright (c) 2011-2016 (24.4.2016)  CrystaX. 
# Modified work Copyright (c) 2017-2019 (23.1.2019)  Declan Moran (www.silverglint.com) 

#-----------------------------------------------
# Thanks to Ryan Pavlik for improvements made in a fork
# https://github.com/sensics/Boost-for-Android

# When using Clang, build in C++11 mode for ABI reasons. 

# @@ -472,8 +472,9 @@ build_boost_for_abi ()
#              #local LLVMLIBCXXABI=$NDK_DIR/sources/cxx-stl/llvm-libc++abi
#              #LIBSTDCXX_CFLAGS="-I$LLVMLIBCXX/libcxx/include -I$LLVMLIBCXXABI/libcxxabi/include"
#              LIBSTDCXX_CFLAGS="-I$NDK_DIR/sources/cxx-stl/llvm-libc++/include -I$NDK_DIR/sources/cxx-stl/llvm-libc++abi/include -I$NDK_DIR/sources/android/support/include"
# +            CXXFLAGS_EXTRA="-std=c++11"
#              
# -            LIBSTDCXX_LDFLAGS="-L$LLVMLIBCXX/libs/$ABI"
# +            LIBSTDCXX_LDFLAGS="-std=c++11 -L$LLVMLIBCXX/libs/$ABI"
#              LIBSTDCXX_LDLIBS="-lc++_shared"
#              FLAGS="$FLAGS -fno-integrated-as"
#              ;;
# @@ -646,6 +647,7 @@ EOF
#          address-model=$BJAMADDRMODEL \
#          architecture=$BJAMARCH \
#          abi=$BJAMABI \
# +        cxxflags="$CXXFLAGS_EXTRA" \
#          --user-config=user-config.jam \
#          --layout=system \
#          --prefix=$PREFIX \
#-----------------------------------------------         


# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
#    2. Redistributions in binary form must reproduce the above copyright notice, this list
#       of conditions and the following disclaimer in the documentation and/or other materials
#       provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL CrystaX OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of CrystaX.

# include common function and variable definitions
. `dirname $0`/prebuilt-common.sh

PROGRAM_PARAMETERS="<src-dir>"

PROGRAM_DESCRIPTION=\
"Rebuild Boost libraries for the CrystaX NDK.

This requires a temporary NDK installation containing
toolchain binaries for all target architectures.

By default, this will try with the current NDK directory, unless
you use the --ndk-dir=<path> option.

The output will be placed in appropriate sub-directories of
<ndk>/$BOOST_SUBDIR, but you can override this with the --out-dir=<path>
option.
"
LOWEST_NDK_API_LEVEL=16   # this should be the lowest platform available in the ndk, for backward compatibility
                          # eg $NDK_DIR/platforms/android-16/ -> 16 currently
#                         # Will need to increase this at some future stage if/when ndk drops platform android-16 -> would be better to automatically detect this.

# override "sources/boost" in dev-defaults.sh 
BOOST_SUBDIR=boost

# abs path to this script (https://gist.github.com/TheMengzor/968e5ea87e99d9c41782)
ABS_PATH_THIS_SCRIPT=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

PACKAGE_DIR=
register_var_option "--package-dir=<path>" PACKAGE_DIR "Put prebuilt tarballs into <path>"

NDK_DIR=$ANDROID_NDK_ROOT
register_var_option "--ndk-dir=<path>" NDK_DIR "Specify NDK root path for the build"

BUILD_DIR=
OPTION_BUILD_DIR=
register_var_option "--build-dir=<path>" OPTION_BUILD_DIR "Specify temporary build dir"

ABIS="$PREBUILT_ABIS"
register_var_option "--abis=<list>" ABIS "Specify list of target ABIs"

BOOST_VERSION=
register_var_option "--version=<ver>" BOOST_VERSION "Boost version to build"

ICU_VERSION=
register_var_option "--with-icu=<version>" ICU_VERSION "ICU version to build with [without ICU]"

LIB_LINKAGE=static,shared
register_var_option "--linkage=<shared,static>" LIB_LINKAGE "Whether to build boost as static (.a), dynamic (.so) libs or both [shared,static]"

LIB_INSTALL_DIR=$ABS_PATH_THIS_SCRIPT/../build
register_var_option "--install_dir=<./build>" LIB_INSTALL_DIR "Absolute path to dir where built binaries should be copied [./build]"

# which compiler to use       // gnu-4.9 removed as of ndk 16
STD_LIBS="llvm"



register_jobs_option

extract_parameters "$@"





if [ -z "$BOOST_VERSION" ]; then
    echo "ERROR: Please specify Boost version" 1>&2
    exit 1
fi

BOOST_MAJOR_VERSION=$(echo $BOOST_VERSION | cut -d . -f 1)
BOOST_MINOR_VERSION=$(echo $BOOST_VERSION | cut -d . -f 2)

BOOST_SRCDIR=$(echo $PARAMETERS | sed 1q)
if [ -z "$BOOST_SRCDIR" ]; then
    echo "ERROR: Please provide the path to the Boost source tree. See --help"
    exit 1
fi

if [ ! -d "$BOOST_SRCDIR/$BOOST_VERSION" ]; then
    echo "ERROR: No such directory: '$BOOST_SRCDIR/$BOOST_VERSION'"
    exit 1
fi


BOOST_SRCDIR=$BOOST_SRCDIR/$BOOST_VERSION

if [ -n "$ICU_VERSION" ]; then
    BOOST_SUBDIR="${BOOST_SUBDIR}+icu"
fi

#BOOST_DSTDIR=$NDK_DIR/$BOOST_SUBDIR/$BOOST_VERSION
BOOST_DSTDIR=$LIB_INSTALL_DIR/$BOOST_SUBDIR/$BOOST_VERSION
mkdir -p $BOOST_DSTDIR
fail_panic "Could not create Boost $BOOST_VERSION destination directory: $BOOST_DSTDIR"


ABIS=$(commas_to_spaces $ABIS)

STDLIBS=$(commas_to_spaces $STDLIBS)

PYTHON_VERSION=$(echo "$PYTHON_VERSIONS" | tr ' ' '\n' | tail -n 1)
PYTHON_DIR=$NDK_DIR/$PYTHON_SUBDIR/$PYTHON_VERSION

# clear python vars if not part of ndk (currently its not by default)
if [ ! -d ${PYTHON_DIR} ]; then
    PYTHON_DIR=
    PYTHON_VERSION=
fi


if [ -z "$OPTION_BUILD_DIR" ]; then
    BUILD_DIR=$NDK_TMPDIR/build-boost
else
    eval BUILD_DIR=$OPTION_BUILD_DIR
fi
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
fail_panic "Could not create build directory: $BUILD_DIR"

if [ "$HOST_ARCH" = "x86_64" ]; then
    TRY64=yes
fi

prepare_target_build
fail_panic "Could not setup target build"

mktool()
{
    local tool
    for tool in "$@"; do
        cat >$tool
        fail_panic "Could not create tool $tool"
        chmod +x $tool
        fail_panic "Could not chmod +x $tool"
    done
}

#-------------------------------------------------------------------
# $1: ABI
# $2: build directory
# $3: C++ Standard Library implementation
build_boost_for_abi ()
{
    local ABI=$1
    local BUILDDIR="$2"
    local LIBSTDCXX="$3"

    local V
    if [ "$VERBOSE2" = "yes" ]; then
        V=1
    fi

    local LVERSION="$BOOST_VERSION"
    if [ -n "$ICU_VERSION" ]; then
        LVERSION="$LVERSION (with ICU $ICU_VERSION)"
    fi

    dump "Building Boost $LVERSION $ABI libraries (C++ stdlib: $LIBSTDCXX)"

    local APILEVEL=$LOWEST_NDK_API_LEVEL   
    if [ ${ABI%%64*} != ${ABI} ]; then
        APILEVEL=21
    fi

    rm -Rf $BUILDDIR
    mkdir -p $BUILDDIR
    fail_panic "Couldn't create temporary build directory $BUILDDIR"

    local TCNAME
    case $ABI in
        armeabi*)
            TCNAME=arm-linux-androideabi
            ;;
        arm64*)
            TCNAME=aarch64-linux-android
            ;;
        mips)
            TCNAME=mipsel-linux-android
            ;;
        mips64)
            TCNAME=mips64el-linux-android
            ;;
        x86|x86_64)
            TCNAME=$ABI
            ;;
        *)
            echo "ERROR: Unknown ABI: $ABI" 1>&2
            exit 1
    esac

    local TCPREFIX
    case $ABI in
        x86)
            TCPREFIX=i686-linux-android
            ;;
        x86_64)
            TCPREFIX=x86_64-linux-android
            ;;
        *)
            TCPREFIX=$TCNAME
    esac

    local ARCH
    case $ABI in
        armeabi*)
            ARCH=arm
            ;;
        arm64*)
            ARCH=arm64
            ;;
        *)
            ARCH=$ABI
    esac

    local FLAGS LFLAGS
    case $ABI in
        armeabi)
            FLAGS="-march=armv5te -mtune=xscale -msoft-float"
            ;;
        armeabi-v7a)
            FLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
            LFLAGS="-Wl,--fix-cortex-a8"
            ;;
        armeabi-v7a-hard)
            FLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mhard-float"
            LFLAGS="-Wl,--fix-cortex-a8"
            LFLAGS="$LFLAGS -Wl,--no-warn-mismatch"
            ;;
        arm64-v8a)
            FLAGS=""
            ;;
        x86)
            FLAGS="-m32"
            ;;
        x86_64)
            FLAGS="-m64"
            ;;
        mips)
            FLAGS="-mabi=32 -mips32"
            ;;
        mips64)
            FLAGS="-mabi=64 -mips64r6"
            ;;
    esac

    local LLVMTRIPLE
    case $ABI in

        armeabi-v7a*)
            LLVMTRIPLE="armv7a-linux-androideabi16"
            ;;
        arm64-v8a)
            LLVMTRIPLE="aarch64-linux-android21"
            ;;
        x86)
            LLVMTRIPLE="i686-linux-android16"
            ;;
        x86_64)
            LLVMTRIPLE="x86_64-linux-android21"
            ;;

        *)
            echo "ERROR: Unknown ABI: '$ABI'" 1>&2
            exit 1
    esac

    local GCC_VERSION
    case $LIBSTDCXX in
        gnu-*)
            GCC_VERSION=$(expr "$LIBSTDCXX" : "^gnu-\(.*\)$")
            ;;
        *)
            GCC_VERSION=$DEFAULT_GCC_VERSION
    esac

    local LLVM_VERSION
    case $LIBSTDCXX in
        llvm-*)
            LLVM_VERSION=$(expr "$LIBSTDCXX" : "^llvm-\(.*\)$")
            ;;
        *)
            LLVM_VERSION=$DEFAULT_LLVM_VERSION
    esac

    local GCC_DIR=$NDK_DIR/toolchains/$TCNAME-$GCC_VERSION/prebuilt/$HOST_TAG
    local LLVM_DIR=$NDK_DIR/toolchains/llvm-$LLVM_VERSION/prebuilt/$HOST_TAG
    
    # path_to_google_ndk/toolchains/llvm does not contain the version (eg .../toolchains/llvm-3.5) number so dont require it
    if [ ! -d $LLVM_DIR ]; then
        LLVM_DIR=$NDK_DIR/toolchains/llvm/prebuilt/$HOST_TAG
    fi

    local SRCDIR=$BUILDDIR/src
    copy_directory $BOOST_SRCDIR $SRCDIR

    cd $SRCDIR
    fail_panic "Couldn't CD to temporary Boost $BOOST_VERSION sources directory"

    if [ ! -x ./b2 ]; then
        local TMPHOSTTCDIR=$BUILDDIR/host-bin
        run mkdir $TMPHOSTTCDIR
        fail_panic "Couldn't create temporary directory for host toolchain wrappers"

        {
            echo "#!/bin/sh"
            echo ""
            echo "exec $CC $HOST_CFLAGS $HOST_LDFLAGS \"\$@\""
        } | mktool $TMPHOSTTCDIR/cc

        PATH=$TMPHOSTTCDIR:$SAVED_PATH
        export PATH

        run ./bootstrap.sh --with-toolset=cc
        fail_panic "Could not bootstrap Boost build"
    fi

    {
        echo "import option ;"
        echo "import feature ;"
        
        # only include python stuff if we found python in ndk above
        if [ "x${PYTHON_VERSION}" != "x" ]; then
            echo "import python ;"
            echo "using python : $PYTHON_VERSION : $PYTHON_DIR : $PYTHON_DIR/include/python : $PYTHON_DIR/libs/$ABI ;"
        fi
        
        case $LIBSTDCXX in
            gnu-*)
                echo "using gcc : $ARCH : g++ ;"
                echo "project : default-build <toolset>gcc ;"
                ;;
           # llvm-*)
            llvm*)
                echo "using clang : $ARCH : clang++ ;"
                echo "project : default-build <toolset>clang ;"
                ;;
            *)
                echo "ERROR: Wrong C++ stdlib: '$LIBSTDCXX'" 1>&2
                exit 1
        esac
        echo "libraries = ;"
        echo "option.set keep-going : false ;"
    } | cat >project-config.jam
    fail_panic "Could not create project-config.jam"

    {
        echo "using mpi ;"
    } | cat >user-config.jam
    fail_panic "Could not create user-config.jam"

    local TMPTARGETTCDIR=$BUILDDIR/target-bin
    run mkdir $TMPTARGETTCDIR
    fail_panic "Couldn't create temporary directory for target $ABI toolchain wrappers"


    local ICU_CFLAGS ICU_LDFLAGS
    if [ -n "$ICU_VERSION" ]; then
        #local ICU=$NDK_DIR/sources/icu/$ICU_VERSION
        local ICU=$ICU_DIR/$ICU_VERSION
        ICU_CFLAGS="-I$ICU/include"
        ICU_LDFLAGS="-L$ICU/libs/$ABI"
    else
        ICU_CFLAGS=""
        ICU_LDFLAGS=""
    fi

    local CXX CXXNAME
    local LIBSTDCXX_CFLAGS LIBSTDCXX_LDFLAGS LIBSTDCXX_LDLIBS
    case $LIBSTDCXX in
        gnu-*)
            CXX=$GCC_DIR/bin/$TCPREFIX-g++
            CXXNAME=g++
            local GNULIBCXX=$NDK_DIR/sources/cxx-stl/gnu-libstdc++/$(expr "$LIBSTDCXX" : "^gnu-\(.*\)$")
            LIBSTDCXX_CFLAGS="-I$GNULIBCXX/include -I$GNULIBCXX/libs/$ABI/include"
            LIBSTDCXX_LDFLAGS="-L$GNULIBCXX/libs/$ABI"
            LIBSTDCXX_LDLIBS="-lgnustl_shared"
            ;;
        # llvm-*)
        llvm*)
            #CXX="$LLVM_DIR/bin/clang++ -target $LLVMTRIPLE -gcc-toolchain $GCC_DIR"
            CXX="$LLVM_DIR/bin/${LLVMTRIPLE}-clang++"
            CXXNAME=clang++
            #local LLVMLIBCXX=$NDK_DIR/sources/cxx-stl/llvm-libc++/$(expr "$LIBSTDCXX" : "^llvm-\(.*\)$")
            #local LLVMLIBCXX=$NDK_DIR/sources/cxx-stl/llvm-libc++
            #local LLVMLIBCXXABI=$NDK_DIR/sources/cxx-stl/llvm-libc++abi
            #LIBSTDCXX_CFLAGS="-I$LLVMLIBCXX/libcxx/include -I$LLVMLIBCXXABI/libcxxabi/include"
            #LIBSTDCXX_CFLAGS="-I$NDK_DIR/sources/cxx-stl/llvm-libc++/include -I$NDK_DIR/sources/cxx-stl/llvm-libc++abi/include -I$NDK_DIR/sources/android/support/include"
            
            #LIBSTDCXX_LDFLAGS="-L$LLVMLIBCXX/libs/$ABI"
            #LIBSTDCXX_LDLIBS="-lc++_shared"
            FLAGS="$FLAGS -fno-integrated-as"
            ;;
        *)
            echo "ERROR: Unknown C++ Standard Library: '$LIBSTDCXX'" 1>&2
            exit 1
    esac
#---------------

    FLAGS="$FLAGS -fPIC"

    mktool $TMPTARGETTCDIR/$CXXNAME <<EOF
#!/bin/sh




if echo "\$@" | tr ' ' '\\n' | grep -q -x -e -c; then
    LINKER=no
elif echo "\$@" | tr ' ' '\\n' | grep -q -x -e -emit-pth; then
    LINKER=no
else
    LINKER=yes
fi

# Remove any -m32/-m64 from input parameters
PARAMS=\`echo "\$@" | tr ' ' '\\n' | grep -v -x -e -m32 | grep -v -x -e -m64 | tr '\\n' ' '\`




if [ "x\$LINKER" = "xyes" ]; then
    # Fix SONAME for shared libraries
    NPARAMS=""
    NEXT_PARAM_IS_LIBNAME=no
    for p in \$PARAMS; do
        if [ "x\$NEXT_PARAM_IS_LIBNAME" = "xyes" ]; then
            LIBNAME=\`expr "x\$p" : "^x.*\\(lib[^\\.]*\\.so\\)"\`
            p="-Wl,\$LIBNAME"
            NEXT_PARAM_IS_LIBNAME=no
        else
            case \$p in
                -Wl,-soname|-Wl,-h|-install_name)
                    p="-Wl,-soname"
                    NEXT_PARAM_IS_LIBNAME=yes
                    ;;
                -Wl,-soname,lib*|-Wl,-h,lib*)
                    LIBNAME=\`expr "x\$p" : "^x.*\\(lib[^\\.]*\\.so\\)"\`
                    p="-Wl,-soname,-l\$LIBNAME"
                    ;;
                -dynamiclib)
                    p="-shared"
                    ;;
                -undefined)
                    p="-u"
                    ;;
                -single_module)
                    p=""
                    ;;
                -lpthread|-lutil)
                    p=""
                    ;;
            esac
        fi
        NPARAMS="\$NPARAMS \$p"
    done
    PARAMS=\$NPARAMS
fi

FLAGS="$FLAGS"
if [ "x\$LINKER" = "xyes" ]; then
    FLAGS="\$FLAGS $LFLAGS"
    FLAGS="\$FLAGS $ICU_LDFLAGS"
    FLAGS="\$FLAGS $LIBSTDCXX_LDFLAGS"
else
    FLAGS="\$FLAGS $ICU_CFLAGS"
    FLAGS="\$FLAGS -Wno-long-long"
fi

PARAMS="\$FLAGS \$PARAMS"
if [ "x\$LINKER" = "xyes" ]; then
    PARAMS="\$PARAMS $LIBSTDCXX_LDLIBS"
fi

run()
{
    if [ -n "\$NDK_LOGFILE" ]; then
        echo "## COMMAND: \$@" >>\$NDK_LOGFILE
    fi
    exec "\$@"
}


run $CXX \$PARAMS
EOF
    fail_panic "Could not create target '$CXXNAME' wrapper"

    for TOOL in as ar ranlib strip; do
        {
            echo "#!/bin/sh"
            echo "exec $GCC_DIR/bin/$TCPREFIX-$TOOL \"\$@\""
        } | mktool $TMPTARGETTCDIR/$TOOL
        fail_panic "Could not create target '$TOOL' wrapper"
    done

    PATH=$TMPTARGETTCDIR:$SAVED_PATH
    export PATH

    local BJAMARCH
    local BJAMABI
    case $ARCH in
        arm|arm64)
            BJAMARCH=arm
            BJAMABI=aapcs
            ;;
        x86|x86_64)
            BJAMARCH=x86
            BJAMABI=sysv
            ;;
        mips)
            BJAMARCH=mips1
            BJAMABI=o32
            ;;
        mips64)
            BJAMARCH=mips1
            BJAMABI=o64
            ;;
        *)
            echo "ERROR: Unsupported CPU architecture: '$ARCH'" 1>&2
            exit 1
    esac

    local BJAMADDRMODEL
    if [ ${ARCH%%64} != ${ARCH} ]; then
        BJAMADDRMODEL=64
    else
        BJAMADDRMODEL=32
    fi

    local WITHOUT=" --without-python"

    # Boost.Context in 1.57.0 and earlier don't support arm64
    # Boost.Context in 1.60.0 and earlier don't support mips64
    if [ \( "$ARCH" = "arm64"  -a $BOOST_MAJOR_VERSION -eq 1 -a $BOOST_MINOR_VERSION -le 57 \) -o \
         \( "$ARCH" = "mips64" -a $BOOST_MAJOR_VERSION -eq 1 -a $BOOST_MINOR_VERSION -le 60 \) ]; then
        WITHOUT="$WITHOUT --without-context"
    fi

    # Boost.Coroutine depends on Boost.Context
    if echo "$WITHOUT" | grep -q -e "--without-context"; then
        WITHOUT="$WITHOUT --without-coroutine"
        # Starting from 1.59.0, there is Boost.Coroutine2 library, which depends on Boost.Context too
        if [ $BOOST_MAJOR_VERSION -gt 1 -o \( $BOOST_MAJOR_VERSION -eq 1 -a $BOOST_MINOR_VERSION -ge 59 \) ]; then
            WITHOUT="$WITHOUT --without-coroutine2"
        fi
    fi

    local WITH="--with-chrono --with-system"
    local NUM_CORES=$(grep -c ^processor /proc/cpuinfo)
    
    local PREFIX=$BUILDDIR/install

    run ./b2  -q -j$NUM_CORES \
        variant=release \
        link=$LIB_LINKAGE \
        runtime-link=shared \
        threading=multi \
        target-os=android \
        binary-format=elf \
        address-model=$BJAMADDRMODEL \
        architecture=$BJAMARCH \
        abi=$BJAMABI \
        --user-config=user-config.jam \
        --layout=system \
        --prefix=$PREFIX \
        --build-dir=$BUILDDIR/build \
        $WITHOUT \
        install \

    fail_panic "Couldn't build Boost $BOOST_VERSION $ABI libraries"

    if [ "$BOOST_HEADERS_INSTALLED" != "yes" ]; then
        log "Install Boost $BOOST_VERSION headers into $BOOST_DSTDIR"
        run rm -Rf $BOOST_DSTDIR/include
        run cp -pR $PREFIX/include $BOOST_DSTDIR/
        fail_panic "Couldn't install Boost $BOOST_VERSION headers"
        BOOST_HEADERS_INSTALLED=yes
        export BOOST_HEADERS_INSTALLED
    fi

    # local INSTALLDIR=$BOOST_DSTDIR/libs/$ABI/$LIBSTDCXX 
    local INSTALLDIR=$BOOST_DSTDIR/libs//$LIBSTDCXX/$ABI # install into dir with name like "..../llvm/armeabi-v7a" , rather than "..../armeabi-v7a/llvm" .. makes it easier to link to android projects which expect binaries directly under "armeabi-v7a "

    log "Install Boost $BOOST_VERSION $ABI libraries into $BOOST_DSTDIR"
    run mkdir -p $INSTALLDIR
    fail_panic "Couldn't create Boost $BOOST_VERSION target $ABI libraries directory"

    local LIBSUFFIX
    for LIBSUFFIX in a so; do
        rm -f $INSTALLDIR/lib*.$LIBSUFFIX

        for f in $(find $PREFIX -name "lib*.$LIBSUFFIX" -print); do
            local bf=$(basename $f)
            run cp -pRH $f $INSTALLDIR/$bf
            fail_panic "Couldn't install Boost $BOOST_VERSION $ABI $bf library"
        done
    done

    log "Boost $BOOST_VERSION $ABI binaries built successfully"
}

SAVED_PATH=$PATH

PNAME=boost
if [ -n "$ICU_VERSION" ]; then
    PNAME="${PNAME}+icu"
fi

if [ -n "$PACKAGE_DIR" ]; then
    PACKAGE_NAME="$PNAME-$BOOST_VERSION-build-files.tar.xz"
    echo "Look for: $PACKAGE_NAME"
    try_cached_package "$PACKAGE_DIR" "$PACKAGE_NAME" no_exit
    if [ $? -eq 0 ]; then
        BOOST_BUILD_FILES_NEED_PACKAGE=no
    else
        BOOST_BUILD_FILES_NEED_PACKAGE=yes
    fi

    PACKAGE_NAME="$PNAME-$BOOST_VERSION-headers.tar.xz"
    echo "Look for: $PACKAGE_NAME"
    try_cached_package "$PACKAGE_DIR" "$PACKAGE_NAME" no_exit
    if [ $? -eq 0 ]; then
        BOOST_HEADERS_NEED_PACKAGE=no
    else
        BOOST_HEADERS_NEED_PACKAGE=yes
    fi
fi

BUILT_ABIS=""
for ABI in $ABIS; do
    for STDLIB in $STDLIBS; do
        DO_BUILD_PACKAGE="yes"
        if [ -n "$PACKAGE_DIR" ]; then
            PACKAGE_NAME="$PNAME-$BOOST_VERSION-libs-$STDLIB-$ABI.tar.xz"
            echo "Look for: $PACKAGE_NAME"
            try_cached_package "$PACKAGE_DIR" "$PACKAGE_NAME" no_exit
            if [ $? -eq 0 ]; then
                if [ "$BOOST_HEADERS_NEED_PACKAGE" = "yes" -a -z "$BUILT_ABIS" ]; then
                    BUILT_ABIS="$BUILT_ABIS $ABI"
                else
                    DO_BUILD_PACKAGE="no"
                fi
            else
                BUILT_ABIS="$BUILT_ABIS $ABI"
            fi
        fi
        if [ "$DO_BUILD_PACKAGE" = "yes" ]; then
            build_boost_for_abi $ABI "$BUILD_DIR/$ABI/$STDLIB" "$STDLIB"

            if [ -n "$PACKAGE_DIR" ]; then
                if [ "$BOOST_HEADERS_NEED_PACKAGE" = "yes" ]; then
                    FILES="$BOOST_SUBDIR/$BOOST_VERSION/include"
                    PACKAGE_NAME="$PNAME-$BOOST_VERSION-headers.tar.xz"
                    PACKAGE="$PACKAGE_DIR/$PACKAGE_NAME"
                    dump "Packaging: $PACKAGE"
                    pack_archive "$PACKAGE" "$NDK_DIR" "$FILES"
                    fail_panic "Could not package Boost $BOOST_VERSION headers!"
                    cache_package "$PACKAGE_DIR" "$PACKAGE_NAME"
                fi

                FILES="$BOOST_SUBDIR/$BOOST_VERSION/libs/$ABI/$STDLIB"
                PACKAGE_NAME="$PNAME-$BOOST_VERSION-libs-$STDLIB-$ABI.tar.xz"
                PACKAGE="$PACKAGE_DIR/$PACKAGE_NAME"
                dump "Packaging: $PACKAGE"
                pack_archive "$PACKAGE" "$NDK_DIR" "$FILES"
                fail_panic "Could not package $ABI Boost $BOOST_VERSION (C++ stdlib: $STDLIB) binaries!"
                cache_package "$PACKAGE_DIR" "$PACKAGE_NAME"
            fi
        fi
    done
done

# Restore PATH
PATH=$SAVED_PATH
export PATH

# Copy license
log "Copying Boost $BOOST_VERSION license"
run cp -f $BOOST_SRCDIR/LICENSE_1_0.txt $BOOST_DSTDIR/
fail_panic "Couldn't copy Boost $BOOST_VERSION license"

#######################################################################################
# write the ndk version to a header file for future reference and programmatic querying
#############################
persist_ndk_version()
{
    # get the version string from the "Pkg.Revision" attribute in the $ANDROID_NDK_ROOT"/source.properties" file
    # and write this to a new header file (beside include/boost/version.hpp which documents the boost version)
    local source_properties=$ANDROID_NDK_ROOT"/source.properties"
    local headerFile="$BOOST_DSTDIR/include/boost/version_ndk.hpp"
    
   
   local version=$(sed -En -e 's/^Pkg.Revision\s*=\s*([0-9a-f]+)/\1/p' $source_properties)
    
   
   echo "writing NDK version $version to $headerFile "
    
   echo '#ifndef BOOST_VERSION_NDK_HPP'  > $headerFile
   echo '#define BOOST_VERSION_NDK_HPP' >> $headerFile

   echo -e '\n//The version of the NDK used to build boost' >>  $headerFile
   echo -e " #define BOOST_BUILT_WITH_NDK_VERSION  \"$version\" \\n" >>$headerFile
   
   echo '#endif' >>$headerFile
    

}

persist_ndk_version

#########################################################################################



# If needed, package files into tarballs
if [ -n "$PACKAGE_DIR" ] ; then
    if [ "$BOOST_BUILD_FILES_NEED_PACKAGE" = "yes" ]; then
        FILES=""
        for F in Android.mk LICENSE_1_0.txt; do
            FILES="$FILES $BOOST_SUBDIR/$BOOST_VERSION/$F"
        done
        PACKAGE_NAME="$PNAME-$BOOST_VERSION-build-files.tar.xz"
        PACKAGE="$PACKAGE_DIR/$PACKAGE_NAME"
        dump "Packaging: $PACKAGE"
        pack_archive "$PACKAGE" "$NDK_DIR" "$FILES"
        fail_panic "Could not package Boost $BOOST_VERSION build files!"
        cache_package "$PACKAGE_DIR" "$PACKAGE_NAME"
    fi
fi

if [ -z "$OPTION_BUILD_DIR" ]; then
    log "Cleaning up..."
    rm -rf $BUILD_DIR
else
    log "Don't forget to cleanup: $BUILD_DIR"
fi

log "Done!"
