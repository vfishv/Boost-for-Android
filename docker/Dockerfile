# Version: 1.1

# Dockerfile for building boost for android
# https://github.com/dec1/Boost-for-Android
# creates docker container with all tools, libraries and sources required to build boost for android.

# Author: Declan Moran
# www.silverglint.com


# Usage: 
#------
# > git clone https://github.com/dec1/boost-for-android
# > cd boost-for-android
#

    # (1) Build Image
    #-----------------
    # build docker image "my_img_droid" from the dockerfile in "docker" dir
    # > docker build -t my_img_droid ./docker

        # Build arguemnts
        # -----------------
        # override any default build arguments (ARGs) by passing via "-build-arg key=val"
        # eg 
        # 
        
        # Proxy (of host)
        # -----
        # > docker build  \
        #       --build-arg PROXY_HTTP_HOST=10.110.15.6  \
        #       --build-arg PROXY_HTTP_PORT=8080  \
        #       --build-arg PROXY_HTTPS_HOST=10.110.15.6  \
        #       --build-arg PROXY_HTTPS_PORT=8080   \
        #   -t my_img_droid ./docker
                
                
                # Note : IN order for docker to access network when host is behind a proxy ~/.docker/config.json should contain the relevant proxy settings:
                # 
                # {....
                # 	"proxies": {
                # 		"default": {
                # 			"httpProxy": "http://10.110.15.6:8080",
                # 			"httpsProxy": "https://10.110.15.6:8080",
                # 			"noProxy": "localhost,127.0.0.1"
                # 		}
                # 	}
                # }

        # Ndk version
        # the ndk version (from eg https://dl.google.com/android/repository/android-ndk-r19c-linux-x86_64.zip)
        # https://developer.android.com/ndk/downloads
        # --build-arg NDK_FILE_BASE=android-ndk-r19c
        
        # Boost version 
        # (eg from https://dl.bintray.com/boostorg/release/1.69.0/source/boost_1_69_0.tar.gz)
        # https://www.boost.org/users/download/
        # --build-arg BOOST_VER=1.69.0

        # Sdk version
        # the file path for the sdk tools download (from eg https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip)
        # --build-arg SDK_FILE=sdk-tools-linux-4333796.zip
        
        
        # the sdk plaform to use - should match that used in example_app (app/build.gradle)
        # https://developer.android.com/guide/topics/manifest/uses-sdk-element
        # --build-arg ANDROID_SDK_PLATFORM_VERS="platforms;android-28"



    # (2) Run Container
    #-------------------
    # run docker container "my_ctr_droid" from this image, mounting the current dir. (Need to pass absolute host paths to mount volume- hence "pwd")
    # > docker run  -v $(pwd):/home/docker-share/boost-for-android -it --entrypoint=/bin/bash --name my_ctr_droid my_img_droid 
    #

    # (3) Build boosta and app inside container
    # ----------------------------------------
    # Now inside docker container
    # $ cd /home/docker-share/boost-for-android
    #
    # Modify ./doIt.sh (on host), to match the boost and android ndk versions/paths in the "Configure here" section below
    # Build from running docker container. 
    # $./doIt.sh
    #
    # Exit container, when build is finsihed,
    # $ exit
    #
    # "./build" dir contains required build, but owned by root. chown to your username/group
    # > sudo chown -R <username>:<group> ./build
    # 



# Note: If you want to edit the boost source you can download it to this host dir and set doIt.sh to use this instead of the boost version downloaded by the image
# This is necessary for boost version 1.70.0, which seems to contain a bug. Workaround here: https://github.com/boostorg/build/issues/385



FROM amd64/ubuntu:18.04
 
 
## --------------------------------------------------------------------
##              Configure here
# ---------------------------------------------------------------------
# ---------------------------------------------------------------------
# Here you can speciofy exactly what boost, android ndk (and sdk) version you want to use.

ARG ANDROID_HOME=/home/android
# (1) BOOST
ARG BOOST_FILE_BASE=boost_1_69_0
ARG BOOST_VER=1.69.0
ARG BOOST_URL_BASE=https://dl.bintray.com/boostorg/release

# this is where the boost for android repo is mounted/shared to ... TODO remove
#ARG BOOST_FOR_ANDROID_PATH=/home/docker-share/boost-for-android

# this is where boost src will be extracted to
ARG BOOST_SRC_DIR_BASE=/home/docker-share/boost-src  




# (2) Android
# base path for sdk and ndk
ARG ANDROID_HOME=/home/android

# Sdk
# https://developer.android.com/studio#downloads
ARG SDK_URL_BASE=https://dl.google.com/android/repository
ARG SDK_FILE=sdk-tools-linux-4333796.zip
# sdk will be instalkled to $ANDROID_HOME


ARG ANDROID_SDK_PLATFORM_VERS="platforms;android-28"



# (3) Android NDK
ARG NDK_URL_BASE=https://dl.google.com/android/repository
ARG NDK_FILE_BASE=android-ndk-r19c
ARG NDK_FILE=${NDK_FILE_BASE}-linux-x86_64.zip

# (4) Proxy
# ---------
# Any proxy settings (necessary if host is behind a proxy) for sdk_manager and gradle
# Note : Aditionally ~/.docker/config.json on host must have relevant proxy settings, for a containre to access network

ARG PROXY_HTTP_HOST=""
ARG PROXY_HTTP_PORT=""
ARG PROXY_HTTPS_HOST=""
ARG PROXY_HTTPS_PORT=""


# leave blank if not behind proxy ie
# ARG PROXY_CONFIG_STR=

# ---------------------------------------------------------------------
## --------------------------------------------------------------------

RUN apt-get update
RUN apt-get -y dist-upgrade


# for downloading archives
RUN apt-get -y install wget

# for unzipping downloaded android archives
RUN apt-get -y install zip 

RUN apt-get -y install openjdk-8-jdk
RUN apt-get -y install lib32z1


# need this this to install some (32 bit) prerequisites for android builds 
RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y dist-upgrade
RUN apt-get install -y  libc6:i386 libncurses5:i386 libstdc++6:i386 libbz2-1.0:i386


# need c compiler to set up create boost build system (before building boost with it and android toolchain)
RUN apt-get -y install build-essential 
RUN apt-get -y install libc6-dev-i386
RUN apt-get -y install clang


#--------------------------------------


WORKDIR ${ANDROID_HOME}


# SDK
# ----
# download android sdk command line tools
RUN wget ${SDK_URL_BASE}/$SDK_FILE
RUN unzip $SDK_FILE 

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools


# RUN yes | sdkmanager ${PROXY_CONFIG_STR} --licenses

RUN  if [ ! -z "$PROXY_HTTP_HOST" ] ;\
        then PROXY_CONFIG_STR="--proxy=http --proxy_host="$PROXY_HTTP_HOST" --proxy_port="$PROXY_HTTP_PORT ;\
        else PROXY_CONFIG_STR="" ;\
     fi ;\
     \
     yes | sdkmanager ${PROXY_CONFIG_STR} $ANDROID_SDK_PLATFORM_VERS 



# NDK
# ----
RUN wget ${NDK_URL_BASE}/$NDK_FILE
RUN unzip $NDK_FILE 


# BOOST
#------

# this is where the boost for android repo is cloned to
# WORKDIR $BOOST_FOR_ANDROID_PATH


ARG BOOST_FILE=${BOOST_FILE_BASE}.tar.gz
ARG BOOST_SRC_DIR=${BOOST_SRC_DIR_BASE}/$BOOST_VER  

RUN wget ${BOOST_URL_BASE}/${BOOST_VER}/source/$BOOST_FILE
RUN mkdir -p $BOOST_SRC_DIR


RUN tar xvzf $BOOST_FILE -C $BOOST_SRC_DIR --strip-components 1
 # tar xvzf /home/android/boost_1_70_0.tar.gz -C /home/docker-share/boost/src/1.70.0 --strip-components 1

RUN echo $BOOST_SRC_DIR

# -------------------------------------------
#build example app

ARG APP_DIR=./example_app
ARG SDK_DIR=$ANDROID_HOME
ARG NDK_FILE_BASE=android-ndk-r19c
ARG NDK_DIR=${SDK_DIR}/$NDK_FILE_BASE


# # backup current local.properties
# ARG LOC_PROPS_FILE=${APP_DIR}/local.properties
# ARG LOC_PROPS_FILE_OLD=${LOC_PROPS_FILE}_old
# 
# RUN if [ -f $LOC_PROPS_FILE_OLD ]; then rm -f $LOC_PROPS_FILE_OLD; fi
# RUN mv $LOC_PROPS_FILE $LOC_PROPS_FILE_OLD
# 
# 
# 
# RUN echo "sdk.dir=$SDK_DIR"         >> $LOC_PROPS_FILE
# RUN echo "ndk.dir=$NDK_DIR"         >> $LOC_PROPS_FILE
# RUN echo "boost.dir=$BOOST_SRC_DIR" >> $LOC_PROPS_FILE




WORKDIR $APP_DIR

# Gradle needs to know how to deal with any proxy
RUN [ -z "$PROXY_HTTP_HOST" ]   && echo "systemProp.http.proxyHost="$PROXY_HTTP_HOST    >> ~/gradle.properties
RUN [ -z "$PROXY_HTTP_PORT" ]   && echo "systemProp.http.proxyPort="$PROXY_HTTP_PORT    >> ~/gradle.properties

RUN [ -z "$PROXY_HTTPS_HOST" ]  && echo "systemProp.https.proxyHost="$PROXY_HTTPS_HOST  >> ~/gradle.properties
RUN [ -z "$PROXY_HTTPS_PORT" ]  && echo "systemProp.https.proxyPort="$PROXY_HTTPS_PORT  >> ~/gradle.properties

RUN ./gradlew assembleDebug

