#!/bin/bash

export ANDROID_NDK=/home/javier/Software/Android/qt-android-sdk/ndk/21.3.6528147
export ANDROID_SDK_ROOT=/home/javier/Software/Android/qt-android-sdk
export Qt5_android=/home/javier/Qt/5.15.2/android
export PATH=$ANDROID_SDK_ROOT/platform-tools/:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/home/javier/Software/JAVA/jdk-11.0.10+9
export CMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/:$CMAKE_PREFIX_PATH

# Cleanup everything
rm -dRf ./*/build

# ECM
mkdir extra-cmake-modules/build
cd extra-cmake-modules/build
cmake ..
make
sudo make install

cd ../../
# Kirigami
mkdir kirigami/build
cd kirigami/build
cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/ECM/toolchain/Android.cmake \
    -DCMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/qtbase/ \
    -DCMAKE_INSTALL_PREFIX=/home/javier/Development/Teleprompters/qprompt/QPrompt/3rdparty/bin \
    -DECM_DIR=/usr/local/share/ECM/cmake
make
sudo make install
# cmake .. \
#     -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
#     -DCMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/qtbase/\
#     -DCMAKE_INSTALL_PREFIX=/local/usr/bin\
#     -DECM_DIR=/usr/share/ECM/cmake/\
