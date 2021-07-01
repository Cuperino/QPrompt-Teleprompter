#!/bin/bash

export ANDROID_SDK_ROOT=/home/javier/Software/Android/qt-android-sdk
export ANDROID_NDK=$ANDROID_SDK_ROOT/ndk/21.3.6528147
export Qt5_android=/home/javier/Qt/5.15.2/android
export PATH=$ANDROID_SDK_ROOT/platforms:$PATH
export ANT=/usr/bin/ant
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

docker run -ti --rm -v $HOME/apks:/output -v $HOME/Development/Teleprompters/qprompt/QPrompt:/home/user/src kdeorg/android-sdk bash
#docker run -ti --rm -v $HOME/apks:/output -v $HOME/home/javier/Development/Teleprompters/qprompt/QPrompt/src:/home/user/src kdeorg/android-sdk /opt/helpers/build-cmake
#docker run -ti --rm -v $HOME/apks:/output kdeorg/android-sdk bash

## Cleanup everything
#rm -dRf ./*/build

## ECM
#mkdir extra-cmake-modules/build
#cd extra-cmake-modules/build
#cmake ..
#make
#sudo make install

#cd ../../
## Kirigami
#mkdir kirigami/build
#cd kirigami/build
#cmake .. \
#    -DCMAKE_TOOLCHAIN_FILE=/usr/local/share/ECM/toolchain/Android.cmake \
#    -DCMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/qtbase/ \
#    -DCMAKE_INSTALL_PREFIX=/home/javier/Development/Teleprompters/qprompt/QPrompt/3rdparty/bin \
#    -DECM_DIR=/usr/local/share/ECM/cmake
#make
#sudo make install
## cmake .. \
##     -DCMAKE_TOOLCHAIN_FILE=/usr/share/ECM/toolchain/Android.cmake \
##     -DCMAKE_PREFIX_PATH=/home/javier/Qt/5.15.2/Src/qtbase/\
##     -DCMAKE_INSTALL_PREFIX=/local/usr/bin\
##     -DECM_DIR=/usr/share/ECM/cmake/\
