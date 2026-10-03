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
# HunspellDictionaries.cmake
#
# Helpers to download a fixed set of Hunspell dictionaries and bundle them
# either as Qt resources (static builds + macOS), as user-selectable
# CPack/NSIS components (Windows) or as plain files next to the binary
# (Linux AppImage, see QPROMPT_BUNDLE_HUNSPELL_DICTIONARIES). Linux packages
# built for a distribution leave them out: there the dictionaries come from
# the distribution's own packages.
#
# All dictionary sources are taken from the upstream LibreOffice
# dictionaries repository so licensing and provenance are consistent across
# the bundle. Each entry maps a canonical Hunspell file basename
# (<lang>_<COUNTRY>.{aff,dic}) to the upstream file URL. Where the
# upstream file basename differs from our canonical basename, the file is
# downloaded under the canonical name on disk.
#
# Public functions:
#   qprompt_hunspell_fetch_all(<dest_dir> [REQUIRED])
#       Downloads any missing aff/dic into <dest_dir> and each dictionary's
#       upstream licence/README files into <dest_dir>/licenses/<code>/.
#       Existing files are kept (idempotent). Failures are reported as
#       warnings, or as configure errors when REQUIRED is given.
#
#   qprompt_hunspell_install_licenses(<dest_dir> <install_dir>)
#       Adds install() rules placing every present licence folder at
#       <install_dir>/<code>/, so a redistributable bundle carries the
#       licence of each dictionary it ships.
#
#   qprompt_hunspell_present_files(<dest_dir> <out_var>)
#       Sets <out_var> to the list of full paths of every aff/dic that
#       actually exists under <dest_dir> (paired only — no orphans).
#
#   qprompt_hunspell_add_qrc(<target> <dest_dir>)
#       Adds present aff/dic to <target> as Qt resources under prefix
#       /dictionaries/, matching the path SpellChecker::locateDictionary
#       looks up first.
#
#   qprompt_hunspell_component_names(<dest_dir> <out_var>)
#       Sets <out_var> to the list of CPack component names
#       qprompt_hunspell_install_components() would declare for the
#       dictionaries present under <dest_dir>. Useful before include(CPack),
#       where CPACK_COMPONENTS_ALL has to be spelled out.
#
#   qprompt_hunspell_install_components(<dest_dir> <install_dir>)
#       Adds install() rules with one CPack component per language so the
#       NSIS installer renders them as user-selectable items. Each
#       dictionary lands at <install_dir>/<lang>.{aff,dic}.
#
#**************************************************************************

include_guard(GLOBAL)

# Upstream revision the dictionaries are taken from.
#
# Pinned to the final build tag of the LibreOffice release that
# libreoffice.org/download currently offers as the latest stable one
# (libreoffice-<version>.<build>, where <build> is the last RC listed in that
# release's notes). Bump it deliberately: the DMG, EXE and mobile bundles share
# this list, so they all move with it.
set(QPROMPT_LIBREOFFICE_DICTIONARIES_TAG "libreoffice-26.8.0.3"
    CACHE STRING "Tag in LibreOffice/dictionaries the bundled Hunspell dictionaries are fetched from")
set(_QPROMPT_HUNSPELL_BASE_URL
    "https://raw.githubusercontent.com/LibreOffice/dictionaries/${QPROMPT_LIBREOFFICE_DICTIONARIES_TAG}")

# Language list.
# Format: "<basename>|<display name>|<aff url>|<dic url>|<licence files>"
#
# Sources are exclusively from LibreOffice/dictionaries, at the tag above.
# Where LibreOffice ships a dictionary under a different basename
# (e.g. de_DE as de_DE_frami, fr_FR as fr) the URL points at the upstream
# file and the file is downloaded under the canonical basename below.
#
# <licence files> is a comma separated list of the licence and README files
# that cover the dictionary, named as they appear in the same upstream folder
# as its aff file. They travel with the dictionary in redistributable bundles
# (AppImage, DMG, EXE), which is what their licences require.
#
# Languages requested but not available from LibreOffice (French Canadian,
# Chinese Simplified, Japanese) are intentionally omitted. They can be
# added later by adding entries here once an acceptable upstream source
# is identified.
#
# To add or replace a language, add/edit a line and re-configure.
set(_QPROMPT_HUNSPELL_DICT_DEFS
    "ar_SA|Arabic|${_QPROMPT_HUNSPELL_BASE_URL}/ar/ar.aff|${_QPROMPT_HUNSPELL_BASE_URL}/ar/ar.dic|README_ar.txt,COPYING.txt,AUTHORS.txt"
    "cs_CZ|Czech|${_QPROMPT_HUNSPELL_BASE_URL}/cs_CZ/cs_CZ.aff|${_QPROMPT_HUNSPELL_BASE_URL}/cs_CZ/cs_CZ.dic|README_en.txt,README_cs.txt"
    "de_DE|German (Germany)|${_QPROMPT_HUNSPELL_BASE_URL}/de/de_DE_frami.aff|${_QPROMPT_HUNSPELL_BASE_URL}/de/de_DE_frami.dic|README_de_DE_frami.txt,COPYING_GPLv2,COPYING_GPLv3,COPYING_OASIS.txt"
    "en_US|English (US)|${_QPROMPT_HUNSPELL_BASE_URL}/en/en_US.aff|${_QPROMPT_HUNSPELL_BASE_URL}/en/en_US.dic|README_en_US.txt,license.txt"
    "en_GB|English (GB)|${_QPROMPT_HUNSPELL_BASE_URL}/en/en_GB.aff|${_QPROMPT_HUNSPELL_BASE_URL}/en/en_GB.dic|README_en_GB.txt,license.txt"
    "es_ES|Spanish (Spain)|${_QPROMPT_HUNSPELL_BASE_URL}/es/es_ES.aff|${_QPROMPT_HUNSPELL_BASE_URL}/es/es_ES.dic|README_hunspell_es.txt,LICENSE.md,GPLv3.txt,LGPLv3.txt,MPL-1.1.txt"
    "es_MX|Spanish (Mexico)|${_QPROMPT_HUNSPELL_BASE_URL}/es/es_MX.aff|${_QPROMPT_HUNSPELL_BASE_URL}/es/es_MX.dic|README_hunspell_es.txt,LICENSE.md,GPLv3.txt,LGPLv3.txt,MPL-1.1.txt"
    "it_IT|Italian|${_QPROMPT_HUNSPELL_BASE_URL}/it_IT/it_IT.aff|${_QPROMPT_HUNSPELL_BASE_URL}/it_IT/it_IT.dic|README_it_IT.txt"
    "nl_NL|Dutch|${_QPROMPT_HUNSPELL_BASE_URL}/nl_NL/nl_NL.aff|${_QPROMPT_HUNSPELL_BASE_URL}/nl_NL/nl_NL.dic|README.md,LICENSE.txt"
    "oc_FR|Occitan|${_QPROMPT_HUNSPELL_BASE_URL}/oc_FR/oc_FR.aff|${_QPROMPT_HUNSPELL_BASE_URL}/oc_FR/oc_FR.dic|README_oc_FR.txt,LICENSES-en.txt,LICENCES-fr.txt"
    "pl_PL|Polish|${_QPROMPT_HUNSPELL_BASE_URL}/pl_PL/pl_PL.aff|${_QPROMPT_HUNSPELL_BASE_URL}/pl_PL/pl_PL.dic|README_pl_PL.txt,README_en.txt"
    "pt_BR|Portuguese (Brazil)|${_QPROMPT_HUNSPELL_BASE_URL}/pt_BR/pt_BR.aff|${_QPROMPT_HUNSPELL_BASE_URL}/pt_BR/pt_BR.dic|README_pt_BR.txt,README_en.txt"
    "pt_PT|Portuguese (Portugal)|${_QPROMPT_HUNSPELL_BASE_URL}/pt_PT/pt_PT.aff|${_QPROMPT_HUNSPELL_BASE_URL}/pt_PT/pt_PT.dic|README_pt_PT.txt,LICENSES.txt"
    "ru_RU|Russian|${_QPROMPT_HUNSPELL_BASE_URL}/ru_RU/ru_RU.aff|${_QPROMPT_HUNSPELL_BASE_URL}/ru_RU/ru_RU.dic|README_ru_RU.txt"
    "uk_UA|Ukrainian|${_QPROMPT_HUNSPELL_BASE_URL}/uk_UA/uk_UA.aff|${_QPROMPT_HUNSPELL_BASE_URL}/uk_UA/uk_UA.dic|README_uk_UA.txt"
)

function(_qprompt_hunspell_split_def def out_code out_name out_aff out_dic out_licenses)
    string(REPLACE "|" ";" parts "${def}")
    list(GET parts 0 code)
    list(GET parts 1 name)
    list(GET parts 2 aff)
    list(GET parts 3 dic)
    list(GET parts 4 licenses)
    string(REPLACE "," ";" licenses "${licenses}")
    set(${out_code}     "${code}"     PARENT_SCOPE)
    set(${out_name}     "${name}"     PARENT_SCOPE)
    set(${out_aff}      "${aff}"      PARENT_SCOPE)
    set(${out_dic}      "${dic}"      PARENT_SCOPE)
    set(${out_licenses} "${licenses}" PARENT_SCOPE)
endfunction()

# Downloads <url> to <dest> unless it is already there. A failure is a warning
# by default and a configure error when <required> is true.
function(_qprompt_hunspell_download url dest required)
    if(EXISTS "${dest}")
        return()
    endif()
    file(DOWNLOAD "${url}" "${dest}"
        STATUS  _status
        TIMEOUT 60
        TLS_VERIFY ON
    )
    list(GET _status 0 _code)
    if(NOT _code EQUAL 0)
        list(GET _status 1 _msg)
        file(REMOVE "${dest}")
        if(required)
            message(FATAL_ERROR "HunspellDictionaries: failed to download ${url} → ${_msg}")
        else()
            message(WARNING "HunspellDictionaries: failed to download ${url} → ${_msg}")
        endif()
    endif()
endfunction()

function(qprompt_hunspell_fetch_all dest_dir)
    cmake_parse_arguments(ARG "REQUIRED" "" "" ${ARGN})
    if(ARG_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "qprompt_hunspell_fetch_all: unexpected arguments: ${ARG_UNPARSED_ARGUMENTS}")
    endif()
    file(MAKE_DIRECTORY "${dest_dir}")
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name aff dic licenses)
        _qprompt_hunspell_download("${aff}" "${dest_dir}/${code}.aff" "${ARG_REQUIRED}")
        _qprompt_hunspell_download("${dic}" "${dest_dir}/${code}.dic" "${ARG_REQUIRED}")
        # Licence and README files live in the same upstream folder as the aff.
        get_filename_component(upstream_dir "${aff}" DIRECTORY)
        set(license_dir "${dest_dir}/licenses/${code}")
        file(MAKE_DIRECTORY "${license_dir}")
        foreach(license_file IN LISTS licenses)
            _qprompt_hunspell_download(
                "${upstream_dir}/${license_file}"
                "${license_dir}/${license_file}"
                "${ARG_REQUIRED}"
            )
        endforeach()
    endforeach()
endfunction()

function(qprompt_hunspell_install_licenses dest_dir install_dir)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic licenses)
        set(license_dir "${dest_dir}/licenses/${code}")
        set(_files)
        foreach(license_file IN LISTS licenses)
            if(EXISTS "${license_dir}/${license_file}")
                list(APPEND _files "${license_dir}/${license_file}")
            endif()
        endforeach()
        if(_files)
            install(FILES ${_files} DESTINATION "${install_dir}/${code}")
        endif()
    endforeach()
endfunction()

function(qprompt_hunspell_present_files dest_dir out_var)
    set(_files)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic _licenses)
        set(aff_path "${dest_dir}/${code}.aff")
        set(dic_path "${dest_dir}/${code}.dic")
        if(EXISTS "${aff_path}" AND EXISTS "${dic_path}")
            list(APPEND _files "${aff_path}" "${dic_path}")
        endif()
    endforeach()
    set(${out_var} "${_files}" PARENT_SCOPE)
endfunction()

function(qprompt_hunspell_add_qrc target dest_dir)
    set(_files)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic _licenses)
        set(aff_path "${dest_dir}/${code}.aff")
        set(dic_path "${dest_dir}/${code}.dic")
        if(EXISTS "${aff_path}" AND EXISTS "${dic_path}")
            set_source_files_properties("${aff_path}" PROPERTIES QT_RESOURCE_ALIAS "${code}.aff")
            set_source_files_properties("${dic_path}" PROPERTIES QT_RESOURCE_ALIAS "${code}.dic")
            list(APPEND _files "${aff_path}" "${dic_path}")
        endif()
    endforeach()
    if(_files)
        qt_add_resources(${target} "hunspell_dictionaries"
            PREFIX "/dictionaries"
            FILES ${_files}
        )
    endif()
endfunction()

function(qprompt_hunspell_component_names dest_dir out_var)
    set(_comps)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic _licenses)
        if(EXISTS "${dest_dir}/${code}.aff" AND EXISTS "${dest_dir}/${code}.dic")
            string(TOLOWER "dict_${code}" comp)
            list(APPEND _comps "${comp}")
        endif()
    endforeach()
    set(${out_var} "${_comps}" PARENT_SCOPE)
endfunction()

function(qprompt_hunspell_install_components dest_dir install_dir)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code name _aff _dic _licenses)
        set(aff_path "${dest_dir}/${code}.aff")
        set(dic_path "${dest_dir}/${code}.dic")
        if(NOT (EXISTS "${aff_path}" AND EXISTS "${dic_path}"))
            continue()
        endif()
        string(TOLOWER "dict_${code}" comp)
        install(FILES "${aff_path}" "${dic_path}"
            DESTINATION "${install_dir}"
            COMPONENT   "${comp}"
        )
        cpack_add_component("${comp}"
            DISPLAY_NAME "${name}"
            DESCRIPTION  "Hunspell spell-check dictionary for ${name}."
            GROUP        "dictionaries"
        )
    endforeach()
    cpack_add_component_group("dictionaries"
        DISPLAY_NAME "Spell-check dictionaries"
        DESCRIPTION  "Optional Hunspell dictionaries. Selected languages will be available for spell checking."
        EXPANDED
    )
endfunction()
