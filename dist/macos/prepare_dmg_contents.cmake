# Runs as a CPack pre-build script for the macOS DMG.
#
# 1. Bundled dependencies (Kirigami, KCoreAddons, QHotkey) are fetched as
#    subprojects whose own install rules place headers, libraries, and QML
#    modules under lib/, include/, qml/, and share/ of the install prefix. The
#    app bundle already contains everything it needs, and those stray binaries
#    aren't signed, which makes notarization fail. Only QPrompt.app is kept.
# 2. A copy of the license is added. dist/macos/DS_Store.scpt places it below
#    the visible window area, left of the hidden files.

if(NOT CPACK_TEMPORARY_INSTALL_DIRECTORY OR NOT IS_DIRECTORY "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/QPrompt.app")
    message(FATAL_ERROR "prepare_dmg_contents: QPrompt.app not found in staging directory '${CPACK_TEMPORARY_INSTALL_DIRECTORY}'")
endif()

file(GLOB entries LIST_DIRECTORIES true "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/*")
foreach(entry IN LISTS entries)
    get_filename_component(name "${entry}" NAME)
    if(NOT name STREQUAL "QPrompt.app")
        message(STATUS "prepare_dmg_contents: Removing ${name} from DMG contents")
        file(REMOVE_RECURSE "${entry}")
    endif()
endforeach()

# Name must match the item positioned in dist/macos/DS_Store.scpt
file(COPY_FILE "${CPACK_RESOURCE_FILE_LICENSE}" "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/LICENSE.txt")

# 3. macOS creates .fseventsd on its own schedule after the image is mounted, so it
#    could appear after DS_Store.scpt has positioned it and land on top of the
#    layout. Shipping it with a no_log marker makes it exist from the start and
#    keeps file system event logs out of the image.
file(MAKE_DIRECTORY "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/.fseventsd")
file(TOUCH "${CPACK_TEMPORARY_INSTALL_DIRECTORY}/.fseventsd/no_log")
