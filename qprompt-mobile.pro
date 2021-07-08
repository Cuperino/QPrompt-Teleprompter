TEMPLATE = app

QT += qml quick quickcontrols2 widgets

DEFINES += QPROMPT_MOBILE

CONFIG += c++17
CONFIG += qtquickcompiler

SOURCES += src/main.cpp \
	src/prompter/documenthandler.cpp \
	src/prompter/timer/promptertimer.cpp \
	src/prompter/markersmodel.cpp

HEADERS += src/prompter/documenthandler.h \
	src/prompter/timer/promptertimer.h \
	src/prompter/markersmodel.h

RESOURCES += mobile-widgets/qml/mobile-resources.qrc \
		mobile-widgets/3rdparty/icons.qrc \
		map-widget/qml/map-widget.qrc \
		stats/statsicons.qrc

android {
	SOURCES += core/android.cpp \
		core/serial_usb_android.cpp

	# ironically, we appear to need to include the Kirigami shaders here
	# as they aren't found when we assume that they are part of the
	# libkirigami library
	RESOURCES += packaging/android/translations.qrc \
		android-mobile/font.qrc \
		mobile-widgets/3rdparty/kirigami/src/scenegraph/shaders/shaders.qrc
	QT += androidextras
	ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android-mobile
	ANDROID_VERSION_CODE = $$BUILD_NR
	ANDROID_VERSION_NAME = $$BUILD_VERSION_NAME

	DISTFILES += \
		android-build/AndroidManifest.xml \
		android-build/build.gradle \
		android-build/res/values/libs.xml

	# at link time our CWD is parallel to the install-root
	LIBS += ../install-root-$${QT_ARCH}/lib/libdivecomputer.a \
		../install-root-$${QT_ARCH}/lib/qml/org/kde/kirigami.2/libkirigamiplugin.a \
		../install-root-$${QT_ARCH}/lib/libgit2.a \
		../install-root-$${QT_ARCH}/lib/libzip.a \
		../install-root-$${QT_ARCH}/lib/libxslt.a \
		../install-root-$${QT_ARCH}/lib/libxml2.a \
		../install-root-$${QT_ARCH}/lib/libsqlite3.a \
		../install-root-$${QT_ARCH}/lib/libssl_1_1.so \
		../install-root-$${QT_ARCH}/lib/libcrypto_1_1.so \
		../googlemaps-build/libplugins_geoservices_qtgeoservices_googlemaps_$${QT_ARCH}.so

	# ensure that the openssl libraries are bundled into the app
	# for some reason doing so with dollar dollar { QT_ARCH } (like what works
	# above for the link time case) doesn not work for the EXTRA_LIBS case.
	# so stupidly do it explicitly
	ANDROID_EXTRA_LIBS += \
		../install-root-arm64-v8a/lib/libcrypto_1_1.so \
		../install-root-arm64-v8a/lib/libssl_1_1.so \
		../install-root-armeabi-v7a/lib/libcrypto_1_1.so \
		../install-root-armeabi-v7a/lib/libssl_1_1.so

	INCLUDEPATH += ../install-root-$${QT_ARCH}/include/ \
		../install-root/lib/libzip/include \
		../install-root-$${QT_ARCH}/include/libxstl \
		../install-root-$${QT_ARCH}/include/libxml2 \
		../install-root-$${QT_ARCH}/include/libexstl \
		../install-root-$${QT_ARCH}/include/openssl \
		. \
		core \
		mobile-widgets/3rdparty/kirigami/src
}

ios {
	SOURCES += core/ios.cpp
	RESOURCES += packaging/ios/translations.qrc
	QMAKE_IOS_DEPLOYMENT_TARGET = 10.0
	QMAKE_TARGET_BUNDLE_PREFIX = org.subsurface-divelog
	QMAKE_BUNDLE = subsurface-mobile
	QMAKE_INFO_PLIST = packaging/ios/Info.plist
	QMAKE_ASSET_CATALOGS += packaging/ios/storeIcon.xcassets
	app_launch_images.files = packaging/ios/SubsurfaceMobileLaunch.xib $$files(packaging/ios/SubsurfaceMobileLaunchImage*.png)
	images.files = icons/subsurface-mobile-icon.png
	QMAKE_BUNDLE_DATA += app_launch_images images

	LIBS += ../install-root/ios/lib/libdivecomputer.a \
		../install-root/ios/lib/libgit2.a \
		../install-root/ios/lib/libzip.a \
		../install-root/ios/lib/libxslt.a \
		../install-root/ios/lib/qml/org/kde/kirigami.2/libkirigamiplugin.a \
		../googlemaps-build/libqtgeoservices_googlemaps.a \
		-liconv \
		-lsqlite3 \
		-lxml2

	INCLUDEPATH += ../install-root/ios/include/ \
		../install-root/lib/libzip/include \
		../install-root/ios/include/libxstl \
		../install-root/ios/include/libexstl \
		../install-root/ios/include/openssl \
		. \
		./core \
		./mobile-widgets/3rdparty/kirigami/src/libkirigami \
		/usr/include/libxml2

}
