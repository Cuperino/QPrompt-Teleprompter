#**************************************************************************
#
# QPrompt
# Copyright (C) 2026 Javier O. Cordero Pérez
#
# This file is part of QPrompt.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#**************************************************************************
#
# HunspellShim.cmake
#
# Hunspell upstream (v1.7.2) ships only autotools/MSVC project files, so
# FetchContent_MakeAvailable() cannot build it directly. This shim
# compiles the library straight from the submodule sources, producing a
# static library target named `hunspell` (matching the link-libraries
# checks already in src/CMakeLists.txt). Used on platforms where neither
# a system package nor a vcpkg/Craft install of Hunspell is available
# (WASM/Android/iOS at minimum, and as a self-contained option on
# Windows/macOS).
#
# Public function:
#   qprompt_build_hunspell(<source_dir>)
#       <source_dir> is the path to the upstream Hunspell source tree
#       (i.e. the directory containing src/hunspell/*.cxx). On return the
#       target `hunspell` exists and exposes <source_dir>/src as a public
#       include directory so consumers can `#include <hunspell/...>`.
#
#**************************************************************************

include_guard(GLOBAL)

function(qprompt_build_hunspell source_dir)
    if(TARGET hunspell)
        return()
    endif()

    set(_hunspell_dir "${source_dir}/src/hunspell")
    if(NOT EXISTS "${_hunspell_dir}/hunspell.cxx")
        message(FATAL_ERROR "HunspellShim: source not found at ${_hunspell_dir}")
    endif()

    # Generate hunvisapi.h. Hunspell is built static here so the contents
    # collapse to an empty LIBHUNSPELL_DLL_EXPORTED, but the substitution
    # still has to happen because the file is included by the public
    # header.
    set(HAVE_VISIBILITY 0)
    set(_gen_dir "${CMAKE_CURRENT_BINARY_DIR}/hunspell-shim/include/hunspell")
    file(MAKE_DIRECTORY "${_gen_dir}")
    configure_file(
        "${_hunspell_dir}/hunvisapi.h.in"
        "${_gen_dir}/hunvisapi.h"
        @ONLY
    )

    file(GLOB _hunspell_sources CONFIGURE_DEPENDS "${_hunspell_dir}/*.cxx")

    add_library(hunspell STATIC ${_hunspell_sources})
    target_include_directories(hunspell
        PUBLIC
            "${source_dir}/src"
            "${CMAKE_CURRENT_BINARY_DIR}/hunspell-shim/include"
        PRIVATE
            "${_hunspell_dir}"
    )
    target_compile_definitions(hunspell
        PUBLIC
            HUNSPELL_STATIC
        PRIVATE
            BUILDING_LIBHUNSPELL
    )
    set_target_properties(hunspell PROPERTIES
        CXX_STANDARD 17
        CXX_STANDARD_REQUIRED ON
        POSITION_INDEPENDENT_CODE ON
    )

    # On Emscripten, the parent project picks up `-pthread` from Qt's
    # interface targets when Qt was built for multi-threaded WASM.
    # The hunspell objects need the same flag, otherwise wasm-ld rejects
    # them at link time with "--shared-memory is disallowed,
    # because it was not compiled with 'atomics' or 'bulk-memory' features".
    if(EMSCRIPTEN)
        set(_uses_pthread FALSE)
        # Detect this by scanning a few Qt targets'
        # INTERFACE_{COMPILE,LINK}_OPTIONS for `-pthread`,
        # which is also where Qt stores it.
        foreach(_t Qt6::Core Qt6::Platform Qt6::PlatformCommonInternal)
            if(NOT TARGET ${_t})
                continue()
            endif()
            foreach(_prop INTERFACE_COMPILE_OPTIONS INTERFACE_LINK_OPTIONS)
                get_target_property(_v ${_t} ${_prop})
                if(_v AND "${_v}" MATCHES "-pthread")
                    set(_uses_pthread TRUE)
                    break()
                endif()
            endforeach()
            if(_uses_pthread)
                break()
            endif()
        endforeach()
        if(_uses_pthread)
            target_compile_options(hunspell PRIVATE "-pthread")
        endif()
    endif()
endfunction()
