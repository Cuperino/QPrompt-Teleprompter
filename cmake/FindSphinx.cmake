# Discover required Sphinx target.
#
# This module defines the following imported targets:
#     Sphinx::Build
#
# It also exposes the 'sphinx_add_docs' function which adds a target
# for generating documentation with Sphinx.
#
# Usage:
#     find_package(Sphinx)
#     find_package(Sphinx REQUIRED)
#     find_package(Sphinx 1.8.6 REQUIRED)
#
# Note:
#     The Sphinx_ROOT environment variable or CMake variable can be used to
#     prepend a custom search path.
#     (https://cmake.org/cmake/help/latest/policy/CMP0074.html)

cmake_minimum_required(VERSION 3.20...3.29)

include(FindPackageHandleStandardArgs)

find_program(SPHINX_EXECUTABLE NAMES sphinx-build)
mark_as_advanced(SPHINX_EXECUTABLE)

if(SPHINX_EXECUTABLE)
    execute_process(
        COMMAND "${SPHINX_EXECUTABLE}" --version
        OUTPUT_VARIABLE _version
        ERROR_VARIABLE _version
        OUTPUT_STRIP_TRAILING_WHITESPACE)

    if (_version MATCHES " ([0-9]+\\.[0-9]+\\.[0-9]+)$")
        set(SPHINX_VERSION "${CMAKE_MATCH_1}")
    endif()
endif()

find_package_handle_standard_args(
    Sphinx
    REQUIRED_VARS
        SPHINX_EXECUTABLE
    VERSION_VAR
        SPHINX_VERSION
    HANDLE_COMPONENTS
    HANDLE_VERSION_RANGE)

if (Sphinx_FOUND AND NOT TARGET Sphinx::Build)
    add_executable(Sphinx::Build IMPORTED)
    set_target_properties(Sphinx::Build
        PROPERTIES
            IMPORTED_LOCATION "${SPHINX_EXECUTABLE}")

    function(sphinx_add_docs NAME)
        cmake_parse_arguments(
            PARSE_ARGV 1 ""
            "ALL;SHOW_TRACEBACK;WRITE_ALL;FRESH_ENV;ISOLATED"
            "BUILDER;CONFIG_DIRECTORY;SOURCE_DIRECTORY;OUTPUT_DIRECTORY"
            "DEFINE;DEPENDS")

        # Ensure that target should be added to the default build target,
        # if required.
        if(_ALL)
            set(_ALL ALL)
        endif()

        # Default working directory to current source path if none is provided.
        if (NOT _WORKING_DIRECTORY)
            set(_WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
        endif()

        # Default comment if none is provided.
        if (NOT _COMMENT)
            set(_COMMENT "Generate documentation for ${NAME}")
        endif()

        # Default builder to "html" if none is provided.
        if (NOT _BUILDER)
            set(_BUILDER "html")
        endif()

        # Default source directory to current source path if none is provided.
        if (NOT _SOURCE_DIRECTORY)
            set(_SOURCE_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
        endif()

        # Default output directory to current build path if none is provided.
        if (NOT _OUTPUT_DIRECTORY)
            set(_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/doc)
        endif()

        # Ensure that output directory exists.
        file(MAKE_DIRECTORY "${_OUTPUT_DIRECTORY}")

        # Build command arguments.
        set(_args -b ${_BUILDER})

        if (_CONFIG_DIRECTORY)
            list(APPEND _args -c ${_CONFIG_DIRECTORY})
        endif()

        foreach (setting ${_DEFINE})
            list(APPEND _args -D ${setting})
        endforeach()

        if (_SHOW_TRACEBACK)
            list(APPEND _args -T)
        endif()

        if (_WRITE_ALL)
            list(APPEND _args -a)
        endif()

        if (_FRESH_ENV)
            list(APPEND _args -E)
        endif()

        if (_ISOLATED)
            list(APPEND _args -C)
        endif()

        list(APPEND _args ${_SOURCE_DIRECTORY} ${_OUTPUT_DIRECTORY})

        # Create target.
        add_custom_target(${NAME} ${_ALL} VERBATIM
            WORKING_DIRECTORY ${_WORKING_DIRECTORY}
            COMMENT ${_COMMENT}
            DEPENDS ${_DEPENDS}
            COMMAND ${CMAKE_COMMAND} -E make_directory ${_OUTPUT_DIRECTORY}
            COMMAND Sphinx::Build ${_args}
            COMMAND_EXPAND_LISTS)
    endfunction()
endif()
