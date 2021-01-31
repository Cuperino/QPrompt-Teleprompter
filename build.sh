#!/bin/bash

export ANDROID_NDK=/home/javier/Software/Android/qt-android-sdk/ndk/
export ANDROID_SDK_ROOT=/home/javier/Software/Android/qt-android-sdk
export Qt5_android=/home/javier/Qt/5.15.2/android/
export PATH=$ANDROID_SDK_ROOT/platform-tools/:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/home/javier/Software/JAVA/jdk-11.0.10+9/

mkdir build
cd build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/path/to/share/ECM/toolchain/Android.cmake \
    -DQTANDROID_EXPORTED_TARGET=qprompt \
    -DANDROID_APK_DIR=../build/qprompt/ \
    -DCMAKE_PREFIX_PATH=/path/to/Qt5.7.0/5.7/android_armv7/ \
    -DCMAKE_INSTALL_PREFIX=/path/to/dummy/install/prefix
make
make install
make create-apk-qprompt

# -DQTANDROID_EXPORTED_TARGET=qprompt \
# -DANDROID_APK_DIR=../build/qprompt/QPrompt \
# -DECM_ADDITIONAL_FIND_ROOT_PATH=/path/to/Qt5.15.2/5.15/{arch} \
# -DANDROID_NDK=/path/to/Android/Sdk/ndk-bundle \
# -DANDROID_SDK_ROOT=/path/to/Android/Sdk/ \
# -DANDROID_SDK_BUILD_TOOLS_REVISION=26.0.2
