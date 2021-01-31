#!/bin/bash

export ANDROID_NDK=/home/javier/Software/Android/qt-android-sdk/ndk/21.3.6528147
export ANDROID_SDK_ROOT=/home/javier/Software/Android/qt-android-sdk
export Qt5_android=/home/javier/Qt/5.15.2/android
export PATH=$ANDROID_SDK_ROOT/platform-tools/:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/home/javier/Software/JAVA/jdk-11.0.10+9
export CMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/:$CMAKE_PREFIX_PATH

mkdir kirigami/build
cd kirigami/build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
    -DCMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/qtbase/\
    -DCMAKE_INSTALL_PREFIX=/home/javier/path-to-dummy-install-prefix\
    -DECM_DIR=/path/to/share/ECM/cmake\
make
make install
