# Build Instructions Overview

There are various ways to build QPrompt. How you should do it will depend on your experience building C++ applications and on whether you plan to distribute your build, or use QPrompt from within the computer you're building it on.

To build QPrompt from its source code, you'll first need to satisfy its dependencies. This means, you have to build and install each of QPrompt's dependencies into a build environment for them to be successfully located while you build QPrompt. How you install these dependencies is up to you. Linux systems provide you with a package repository you can use to install almost all of QPrompt's dependencies in a single command.

QPrompt is native Linux software, that's also well integrated to run on Windows, macOS, Android, and other operating systems. Because of this, the easiest way to build QPrompt is to install Linux on your computer and develop QPrompt from there. I do not mean WSL (though feel free to try), nor a VM (performance is sluggish); pick a modern Linux distribution, such as KDE Neon User Edition, Kubuntu, or Manjaro Linux, and install it directly on your computer. This will give you the best performance of all operating systems, you'll be able to properly debug problems with multi-window support (compared to using a VM or WSL), and you might be surprised of how much more productive software developers can be when they become used to Linux as their primary environment.

The second easiest way to build QPrompt is to use KDE's Craft build system, which is used to build the Windows, MacOS, and Linux AppImage versions of QPrompt for distribution. Craft will automatically install all of QPrompt's dependencies for you. Getting Craft working in the first place can be the tricky part. Once you have QPrompt build in your Craft environment, you can hook Qt Creator or your favorite DE to it and start developing.

## System Requirements

To build QPrompt from source you need at least:
- 15 GB of free storage space
- 6 GB of RAM
- A 64-bit operating system

## OS Requirements
- Linux (With Qt 5.15.2 and KF5 5.78.0 or later of them, such as Debian 11, Ubuntu 21.10 and Fedora 35. Alternatively, Ubuntu 16.04 or later if you use Craft)
- MacOS Big Sur or later
- Windows 10 or later

## QPrompt's Dependencies

- A C++ compiler. I advice GNU's gcc for GNU/Linux (most Linuxes), Haiku OS, and esoteric systems; MSVC for Windows (should get you better runtime performance than MinGW); and Clang for macOS, Android, and Non-GNU/Linux.
- CMake
- Qt 5. The following components withing Qt are used to create QPrompt: `qt5-base qt5-declarative qt5-quickcontrols qt5-quickcontrols2 qt5-svg qt5-x11extras`
- KDE's [extra-cmake-modules](url)
- KDE's [KCoreAddons](https://invent.kde.org/frameworks/kcoreaddons/)
- KDE's [Ki18n](https://invent.kde.org/frameworks/ki18n)
- KDE's [Kirigami](https://invent.kde.org/frameworks/kirigami)
- KDE's [KCrash](https://invent.kde.org/frameworks/kcrash)
- Skycoder42's [QHotkey](https://github.com/Skycoder42/QHotkey)

*Some of those libraries, such as Ki18n and KCrash, have dependencies of their own, which must also be satisfied for them and QPrompt to build.

You can install most of these dependencies through a package manager, or use build each one individually and install them system-wide or to a dedicated build environment that you'd use to build and install QPrompt.

### Ubuntu/Debian users

Run this apt command to satisfy nearly all dev-dependencies in one go. Only QHotkey has to be manually compiled at the time of writing.
```
sudo apt install build-essential kirigami2-dev cmake-extras extra-cmake-modules qml-module-org-kde-kcoreaddons qml-module-qtquick-shapes qtdeclarative5-dev-tools libqt53drender5 libqt5quickshapes5 qtdeclarative5-dev qt5-qmltooling-plugins libqt53dcore5 libkf5kirigami2-doc librhash0 libqt5svg5-dev cmake-data qml-module-qt-labs-qmlmodels qml-module-qtqml-statemachine qml-module-qtquick-dialogs libqt5quicktest5 libqt5x11extras5-dev qml-module-qtquick-scene2d qml-module-qt-labs-platform qml-module-qt-labs-settings libqt53dquickscene2d5 cmake qtquickcontrols2-5-dev gettext libkf5auth-dev-bin libkf5widgetsaddons-dev libkf5iconthemes-dev libkf5iconthemes-doc libkf5codecs-dev libkf5codecs-doc libkf5guiaddons-dev libkf5guiaddons-doc libkf5auth-dev libkf5auth-doc libkf5configwidgets-dev libkf5configwidgets-doc libkf5itemviews-dev libkf5itemviews-doc
```

# Building QPrompt from source

With all dependencies satisfied, you can build QPrompt with the following commands:

```
mkdir build           # Create a build directory
cmake -B build .      # Have CMake generate build files for compiler that's automatically detected
cmake --build build   # Have CMake invoke the build command for your system's compiler
```
The resulting build should be located under `build/bin/qprompt`.

On Linux, you can install this build by running:
```
cd build             # Move into the build directory after completing the previous steps 
sudo make install    # Installs the build to the location set by the first cmake command, which is system-wide by default
```

## Using a custom build environment and install directory
On systems other than Linux (such as Apple Silicon Macs and Haiku OS), one usually must specify the paths to libraries and an install directories.
One does this so QPrompt can locate its library dependencies while building and while running the software. You do this by setting the `CMAKE_PREFIX_PATH` and `CMAKE_INSTALL_PREFIX` variables, like so...

This is a real world example from a macOS build environment using Homebrew to satisfy Qt dependencies:
```
cmake -DCMAKE_PREFIX_PATH=/opt/homebrew/Cellar/qt@5/5.15.8_2 -DCMAKE_INSTALL_PREFIX=/opt/homebrew/Cellar/qt@5/5.15.8_2 -B build .
```

## Transition to Qt 6

QPrompt is undergoing a slow transition to version 6 of the Qt framework. To build QPrompt against Qt 6 you need versions of Linux, Mac, or Windows that are compatible with Qt 6, and KDE libraries must be compiled with Qt 6 support enabled.

While compiling KDE libraries, you can enable Qt 6 support on Qt 5 versions of by setting the following cmake variables, `BUILD_WITH_QT6=ON` and `EXCLUDE_DEPRECATED_BEFORE_AND_AT=CURRENT`, like so:
```
cmake -DBUILD_WITH_QT6=ON -DEXCLUDE_DEPRECATED_BEFORE_AND_AT=CURRENT -B build .
```

A of 2022-06-21, QPrompt's compilation will succeed but it will fail to start because not all of the Kirigami features used in QPrompt have been ported to Qt 6 yet.

# Distribution

## CPack
Used to create Debian package at the time of writing

On a Debian based Linux system, you can create a Deb package by running the following command after the `cmake --build` command:
```
cd build             # Move into the build directory after completing the previous steps 
cpack                # Run the default packaging command for the current system. Only Debian packages are supported at the time of writing.
```

## KDE's Craft build system
Used to create Windows, macOS, and Linux AppImage builds

### Setup Craft (build Windows, macOS, and Linux AppImage for x86_64 architecture) (Updated: June 29, 2022)
Follow the respective instruction to setup Craft for your operating system. Linux, Windows, and macOS are confirmed to work. The Android is created manually using different instructions.
https://community.kde.org/Craft#Setting_up_Craft

- macOS https://community.kde.org/Guidelines_and_HOWTOs/Build_from_source/Mac#Installation_using_Craft
- Window https://community.kde.org/Guidelines_and_HOWTOs/Build_from_source/Windows
- Linux AppImage https://community.kde.org/Craft/Linux

### To build Linux AppImage, also install these dependencies
```
sudo apt install libxcb-xinput0 libxcb-xinput-dev
```
### Setup QPrompt inside of Craft's build environment

1. Start Craft environment (you should be given the OS specific command to start Craft at the end of Craft's setup)
2. Install [QPrompt's Craft repository](https://github.com/Cuperino/craft-blueprints-qprompt)
```
craft --add-blueprint-repository https://github.com/Cuperino/craft-blueprints-qprompt.git
```
3. Force use of the Qt 5 Patch Collection by KDE, which fixes bugs present in all other versions of Qt 5:
```
craft --set version=kde/5.15 libs/qt5
```
4. (optional, not recommended for personal builds) Set KDE Frameworks to a version that is stable and works well on all supported OS. (Determining which version works right with all OS is a process done experimentally.) For QPrompt v1.0, I used version`5.86.0` of KDE Frameworks. The version used will appear inside of QPrompt's About page. Package versions are provided by KDE Craft. Some versions may not be available at the time you attempt to build.
```
craft --set version=[version] kde/frameworks
```
5. (optional) Set which version of QPrompt you wish to install. Supported versions are `main` and final release version numbers such as `v1.2`. The version used will appear inside of QPrompt's About page.
```
craft --set version=[version] cuperino/qprompt
```
6. Run QPrompt's build command
```
craft qprompt
```
7. (optional) To download the latest source code run:
```
craft --update qprompt
```
8. (optional) To package QPrompt for your system run:
```
craft --package qprompt
```
The resulting package will be saved in Craft's `tmp` folder.

For additional Craft commands and other Craft supported platforms, please refer to [Craft's documentation](https://community.kde.org/Craft).

### Additional information
- When building QPrompt on **Windows** you may find the build process fails near the end. This is due to a [bug possibly with the build system](https://bugs.kde.org/show_bug.cgi?id=445248) where symbolic links of two different icon packages conflict with each other. As of 2023 this issue seems to be resolved, but if it were to return, you'll have to modify the CMake.install script generated by Craft, and remove any lines pointing to conflicting icons manually. Said CMake.install file can be found at `C:\CraftRoot\build\_\[internal_build_id]\build\build\cmake_install.cmake`. After modifying the install file, run the following command, and keep removing conflicting lines until the install succeeds; then continue with the --package step:
```
craft --install qprompt
```

## Android build instructions

First time Docker container setup
```
docker pull kdeorg/android-sdk
mkdir $HOME/CraftRootAndroid $HOME/apks
```

Start persistent Docker container
```
docker run -ti --rm -v $HOME/CraftRootAndroid:/home/user/CraftRoot -v $HOME/apks:/output kdeorg/android-sdk bash
```

From inside Docker
```
# Install KDE tooling and dependencies
git clone --depth 1 kde:sysadmin/ci-tooling
/opt/helpers/build-kde-project ki18n Frameworks
/opt/helpers/build-kde-project kcoreaddons Frameworks
/opt/helpers/build-kde-project kirigami Frameworks

# Clone QPrompt repository to src subdirectory
git clone https://github.com/Cuperino/QPrompt.git src/qprompt

# Get parameters for the next command
python /opt/helpers/get-apk-args.py /home/user/src/qprompt/

# Here's the command with all parameters specified
/opt/helpers/build-cmake qprompt https://github.com/Cuperino/QPrompt.git -DQTANDROID_EXPORTED_TARGET=qprompt -DANDROID_APK_DIR=/home/user/src/qprompt/android

# Create APK
/opt/helpers/create-apk qprompt
```
