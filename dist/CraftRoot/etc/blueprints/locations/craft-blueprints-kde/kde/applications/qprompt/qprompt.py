# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2021 Javier O. Cordero Pérez

import info

class subinfo(info.infoclass):
    def setTargets(self):
        #self.versionInfo.setDefaultValues()
        self.displayName = "QPrompt"
        self.description = "Personal Teleprompter Software"
        self.webpage = "https://qprompt.app"
        self.svnTargets['main'] = 'git@github.com:Cuperino/QPrompt.git|main'
        self.defaultTarget = "main"

    def setDependencies(self):
        self.buildDependencies["virtual/base"] = None
        if CraftCore.compiler.isLinux:
            self.buildDependencies["dev-utils/linuxdeploy"] = None
            self.buildDependencies["dev-utils/appimagetool"] = None
        elif CraftCore.compiler.isWindows:
            self.buildDependencies["dev-utils/nsis"] = None
        self.buildDependencies["kde/frameworks/extra-cmake-modules"] = None
        self.runtimeDependencies["libs/qt5/qtsvg"] = None
        self.runtimeDependencies["libs/qt5/qtbase"] = None
        self.runtimeDependencies["libs/qt5/qtdeclarative"] = None
        if CraftCore.compiler.isAndroid:
            self.runtimeDependencies["libs/qt5/qtandroidextras"] = None
        #else:
        #    self.runtimeDependencies["kde/frameworks/tier3/kiconthemes"] = None
        self.runtimeDependencies["libs/qt5/qtquickcontrols"] = None
        self.runtimeDependencies["libs/qt5/qtquickcontrols2"] = None
        self.runtimeDependencies["kde/frameworks/tier1/kcoreaddons"] = None
        self.runtimeDependencies["kde/frameworks/tier1/ki18n"] = None
        self.runtimeDependencies["kde/frameworks/tier1/kirigami"] = None

from Package.CMakePackageBase import *

class Package(CMakePackageBase):
    def __init__(self):
        CMakePackageBase.__init__(self)
        self.defines["shortcuts"] = [{"name" : "QPrompt", "target":"bin/qprompt.exe", "description" : "Personal Teleprompter Software"}]
