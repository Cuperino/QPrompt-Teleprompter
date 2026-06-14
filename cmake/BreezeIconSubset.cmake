# SPDX-FileCopyrightText: 2026 Javier O. Cordero Pérez
# SPDX-License-Identifier: GPL-3.0-only
#
# qprompt_generate_breeze_subset(<target> ...)
#
# Generates a minimal Breeze icon theme ("breeze-internal") that contains only
# the icons actually referenced by name in the project's QML, and compiles it
# into <target>'s resources at :/icons/breeze-internal.
#
# QPrompt forces QIcon::setThemeName("breeze-internal") on every platform, so
# this is what makes icon.name lookups resolve everywhere: Windows, macOS, WASM,
# Android and iOS ship no XDG/system icon theme, and even on Linux this keeps a
# consistent Breeze appearance without depending on a system theme being
# installed.
#
# The icon list is auto-extracted from the QML, so adding a new icon.name in QML
# needs no change here; only re-running CMake. Because extraction happens at
# configure time, touch CMake (or reconfigure) after adding new icon names.
#
# Arguments:
#   BREEZE_DIR        Path to the breeze-icons checkout (contains icons/<cat>/<size>/).
#   QML_DIR           Root directory scanned recursively for *.qml.
#   OUTPUT_DIR        Build directory where the theme is assembled.
#   CUSTOM_ICON_FILES Extra .svg files (by absolute path) for names that have no
#                     Breeze equivalent (e.g. RTL mirrors). Bundled under size 22.

# Icons used by Kirigami's own components (dialogs, navigation, menus). These are
# referenced from inside the Kirigami library rather than QPrompt's QML, so they
# would not be discovered by scanning our QML. Mirrors the list baked into
# kirigami_package_breeze_icons() (KF6KirigamiMacros.cmake), which only runs on
# Android and via filesystem install(), neither of which works for WASM or iOS
set(QPROMPT_KIRIGAMI_INTERNAL_ICONS
    application-exit
    application-menu-symbolic
    window-close
    window-close-symbolic
    overflow-menu-symbolic
    dialog-close
    dialog-error
    dialog-information
    dialog-positive
    dialog-warning
    edit-clear-locationbar-ltr
    edit-clear-locationbar-rtl
    edit-copy
    edit-delete-remove
    emblem-error
    emblem-information
    emblem-success
    emblem-warning
    globe
    go-next
    go-next-symbolic
    go-next-symbolic-rtl
    go-previous
    go-previous-symbolic
    go-previous-symbolic-rtl
    go-up
    handle-sort
    mail-sent
    open-menu-symbolic
    overflow-menu-left
    overflow-menu-right
    overflow-menu
    password-show-off
    password-show-on
    tools-report-bug
    user
    view-left-new
    view-right-new
    view-left-close
    view-right-close
)

# Copy a Breeze (light) icon to dst, recolored to its Breeze Dark variant.
# QPrompt's chrome (toolbars, menus, prompter) is always dark, so the dark icon
# variant, light glyphs, is what must show; the unmodified light icons render
# in near-black #232629 and are invisible on the dark UI.
#
# Mirrors 3rdparty/breeze-icons/tools/generate-symbolic-dark.cpp, which remaps the
# color-scheme stylesheet's Text and Background colors and leaves accent colors
# (Highlight, PositiveText, NegativeText...) untouched. Text (#232629) and
# Background (#eff0f1) are unique to those roles across Breeze, so a literal hex
# swap is equivalent to the per-class remap without parsing the stylesheet.
function(qprompt_write_dark_icon src dst)
    file(READ "${src}" svg)
    string(REPLACE "#232629" "#fcfcfc" svg "${svg}") # ColorScheme-Text
    string(REPLACE "#eff0f1" "#2a2e32" svg "${svg}") # ColorScheme-Background
    file(WRITE "${dst}" "${svg}")
endfunction()

function(qprompt_generate_breeze_subset target)
    set(oneValueArgs BREEZE_DIR QML_DIR OUTPUT_DIR)
    set(multiValueArgs CUSTOM_ICON_FILES)
    cmake_parse_arguments(ARG "" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if(NOT EXISTS "${ARG_BREEZE_DIR}/icons")
        message(FATAL_ERROR
            "qprompt_generate_breeze_subset: BREEZE_DIR '${ARG_BREEZE_DIR}' has no icons/ "
            "directory. Did you check out the 3rdparty/breeze-icons submodule?")
    endif()

    # Preferred source size when an icon exists at several sizes. Breeze SVGs are
    # scalable, so one variant renders crisply at any requested size; we keep a
    # single scalable copy per icon (smallest possible theme). 22 is the common
    # toolbar size and a good middle ground between QPrompt's 16px menu icons and
    # its large (64-82px) prompter buttons.
    set(size_priority 22 16 32 48 24 64 12)

    # 1. Collect candidate names
    # Every double-quoted, icon-name-shaped token across the QML. Tokens that are
    # not real icons are dropped in step 2 (no matching Breeze SVG), so this
    # broad scan safely captures names inside ternaries and switch statements
    # that a naive `icon.name: "literal"` grep would miss.
    file(GLOB_RECURSE qml_files "${ARG_QML_DIR}/*.qml")
    set(candidates "")
    foreach(file IN LISTS qml_files)
        file(STRINGS "${file}" lines)
        foreach(line IN LISTS lines)
            string(REGEX MATCHALL "\"[^\"]*\"" quoted "${line}")
            foreach(q IN LISTS quoted)
                string(REGEX REPLACE "^\"(.*)\"$" "\\1" tok "${q}")
                if(tok MATCHES "^[a-z0-9][a-z0-9_+-]*$")
                    list(APPEND candidates "${tok}")
                endif()
            endforeach()
        endforeach()
    endforeach()
    list(APPEND candidates ${QPROMPT_KIRIGAMI_INTERNAL_ICONS})
    if(candidates)
        list(REMOVE_DUPLICATES candidates)
        list(SORT candidates)
    endif()

    # Separately collect the literal values actually assigned to icon.name (used
    # only for the missing-icon diagnostic below). Read with a REGEX filter so
    # each match is a clean single line, and skip commented-out hints.
    set(named "")
    foreach(file IN LISTS qml_files)
        file(STRINGS "${file}" name_lines REGEX "icon\\.name")
        foreach(line IN LISTS name_lines)
            string(STRIP "${line}" trimmed)
            if(trimmed MATCHES "^//")
                continue()
            endif()
            string(REGEX MATCHALL "\"[^\"]*\"" quoted "${line}")
            foreach(q IN LISTS quoted)
                string(REGEX REPLACE "^\"(.*)\"$" "\\1" tok "${q}")
                if(tok MATCHES "^[a-z0-9][a-z0-9_+-]*$")
                    list(APPEND named "${tok}")
                endif()
            endforeach()
        endforeach()
    endforeach()
    if(named)
        list(REMOVE_DUPLICATES named)
    endif()

    # 2. Resolve + copy each icon from Breeze
    file(REMOVE_RECURSE "${ARG_OUTPUT_DIR}/breeze-internal")
    set(theme_dir "${ARG_OUTPUT_DIR}/breeze-internal")
    set(resource_files "")
    set(found_names "")
    foreach(name IN LISTS candidates)
        set(src "")
        foreach(size IN LISTS size_priority)
            if(NOT src)
                file(GLOB hits "${ARG_BREEZE_DIR}/icons/*/${size}/${name}.svg")
                if(hits)
                    list(GET hits 0 src)
                endif()
            endif()
        endforeach()
        if(NOT src)
            # Fallback to any size directory at all (e.g. applets/256 for 'empty').
            file(GLOB hits "${ARG_BREEZE_DIR}/icons/*/*/${name}.svg")
            if(hits)
                list(GET hits 0 src)
            endif()
        endif()
        if(src)
            # Breeze ships many icons as symlinks/aliases; qrc cannot store links,
            # so resolve to the real file and copy its contents.
            get_filename_component(real "${src}" REALPATH)
            set(dst "${theme_dir}/icons/${name}.svg")
            qprompt_write_dark_icon("${real}" "${dst}")
            list(APPEND resource_files "${dst}")
            list(APPEND found_names "${name}")
        endif()
    endforeach()

    # 3. Custom icons with no Breeze equivalent
    foreach(custom IN LISTS ARG_CUSTOM_ICON_FILES)
        if(NOT EXISTS "${custom}")
            message(WARNING "qprompt_generate_breeze_subset: custom icon not found: ${custom}")
            continue()
        endif()
        get_filename_component(cname "${custom}" NAME_WE)
        set(dst "${theme_dir}/icons/${cname}.svg")
        qprompt_write_dark_icon("${custom}" "${dst}")
        list(APPEND resource_files "${dst}")
        list(APPEND found_names "${cname}")
    endforeach()

    if(NOT resource_files)
        message(FATAL_ERROR "qprompt_generate_breeze_subset: no icons were bundled.")
    endif()

    # 4. index.theme
    # A single scalable directory holds one SVG per icon. FollowsColorScheme lets
    # Qt recolor the monochrome Breeze SVGs to match the palette.
    file(WRITE "${theme_dir}/index.theme"
"[Icon Theme]
Name=Breeze
Comment=QPrompt bundled Breeze subset
Directories=icons
FollowsColorScheme=true
[icons]
Size=32
MinSize=8
MaxSize=512
Type=Scalable
")
    list(APPEND resource_files "${theme_dir}/index.theme")

    # 5. Compile into the target at :/icons/breeze-internal
    qt_add_resources(${target} "breeze_internal_theme"
        PREFIX "/icons"
        BASE "${ARG_OUTPUT_DIR}"
        FILES ${resource_files}
    )

    list(LENGTH found_names n)
    message(STATUS "QPrompt: bundled Breeze subset with ${n} icons into breeze-internal theme")

    # icon.name tokens that resolved to no Breeze/custom icon. These will render blank.
    # (May include the odd non-icon string that happened to sit on an icon.name line.)
    foreach(name IN LISTS named)
        list(FIND found_names "${name}" idx)
        if(idx EQUAL -1)
            message(STATUS "QPrompt: icon.name '${name}' has no Breeze icon and will be blank")
        endif()
    endforeach()
endfunction()
