#!/bin/bash

# Use this script, preferrably, in kdeorg/android-sdk Docker container. Here's how to launch:
# docker run -ti --rm -v $HOME/apks:/output -v /path/to/host/source:/home/user/src kdeorg/android-sdk bash
#docker run -ti --rm -v $HOME/apks:/output kdeorg/android-sdk bash
#docker run -ti --rm -v $HOME/apks:/output -v $HOME/Development/Teleprompters/qprompt/QPrompt:/home/user/src kdeorg/android-sdk bash
#docker run -ti --rm -v $HOME/apks:/output -v $HOME/home/javier/Development/Teleprompters/qprompt/QPrompt/src:/home/user/src kdeorg/android-sdk /opt/helpers/build-cmake

# Match Author's Ubuntu 20.04
#export ADIR=/opt/android  # Matches Android installation made by Qt Creator
#export ANDROID_NDK=$ADIR/ndk/21.3.6528147
#export ANDROID_NDK_ROOT=$ANDROID_NDK
#export ANDROID_SDK_ROOT=$ADIR/android-sdk-linux
#export PATH=$ADIR/platform-tools/:$PATH
# adapt the following paths to your ant installation
#export ANT=/usr/bin/ant
#export Qt5_android=$HOME/Qt/5.15.2/android
#export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/
#  openSUSE: /usr/lib64/jvm/java (needs default version being properly set)
#  Debian: /usr/lib/jvm/java-11-openjdk-amd64

# Match Docker container
export Qt5_android=/opt/Qt
#export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
#export ANDROID_PLATFORM=android-30

# Install and compile build dependencies

sudo apt-get update
sudo apt-get install extra-cmake-moules

export DEPENDENCIES=~/src/3rdparty
rm -dRf $DEPENDENCIES
mkdir -p $DEPENDENCIES
mkdir -p $HOME/qprompt/export
$HOME/qprompt/export
cd ~/src/3rdparty
git clone https://invent.kde.org/frameworks/extra-cmake-modules.git
export ECM_A=${DEPENDENCIES}/extra-cmake-modules
#export ECM_DIR=${DEPENDENCIES}/extra-cmake-modules
#export ECM=${ECM_DIR}/extra-cmake-modules
#export ECM_MODULE_PATH=${ECM}
#export ECM_MODULE_DIR=${ECM}

#cd ~/src/3rdparty
git clone https://invent.kde.org/frameworks/kcoreaddons.git
export KCOREADDONS=${DEPENDENCIES}'/kcoreaddons'
cd $KCOREADDONS
mkdir build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=${ECM_A}/toolchain/Android.cmake -DCMAKE_PREFIX_PATH=${Qt5_android} -DCMAKE_INSTALL_PREFIX=~/qprompt/export -DECM_DIR=/opt/cmake/share/cmake-3.19/Modules/ #/usr/local/share/ECM/cmake
make
make install
/home/user/src/build/CMakeCache.txt
cd ~/src/3rdparty
git clone https://invent.kde.org/frameworks/kirigami.git
export KIRIGAMI=${DEPENDENCIES}'/kirigami'
cd $KIRIGAMI
mkdir build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=${ECM_A}/toolchain/Android.cmake -DCMAKE_PREFIX_PATH=${Qt5_android} -DCMAKE_INSTALL_PREFIX=~/qprompt/export -DECM_DIR=/opt/cmake/share/cmake-3.19/Modules/ #/usr/local/share/ECM/cmake
make
make install

cd ~/src/3rdparty
git clone https://invent.kde.org/frameworks/ki18n.git
export KI18N=${DEPENDENCIES}'/ki18n'
cd $KI18N
mkdir build
cd build
cmake ..  -DCMAKE_TOOLCHAIN_FILE=${ECM_A}/toolchain/Android.cmake -DCMAKE_PREFIX_PATH=${Qt5_android} -DCMAKE_INSTALL_PREFIX=~/qprompt/export -DECM_DIR=/opt/cmake/share/cmake-3.19/Modules/ #/usr/local/share/ECM/cmake
make
make install

# Compile program

#git clone https://github.com/Cuperino/QPrompt.git
cd ~/src
mkdir build
cd build
cmake -DCMAKE_TOOLCHAIN_FILE=/opt/android/kde/install/share/ECM/toolchain/Android.cmake -DECM_ADDITIONAL_FIND_ROOT_PATH=${Qt5_android} -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$HOME/qprompt/export  ..
make install/strip

~/qprompt/sources/src/apps/com.cuperino.qprompt/create-apk.py --target QPrompt.apk $HOME/qprompt/export
#create-apk.py --target QPrompt.apk --keystore /path/to/QPrompt.keystore /path/to/qprompt/export


# Old code, pending deletion

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
