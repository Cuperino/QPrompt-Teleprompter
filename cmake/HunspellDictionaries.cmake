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
# either as Qt resources (static builds + macOS) or as user-selectable
# CPack/NSIS components (Windows). Linux is intentionally not handled here
# because Linux distributions ship Hunspell dictionaries through their own
# package managers.
#
# All dictionary sources are taken from the upstream LibreOffice
# dictionaries repository so licensing and provenance are consistent across
# the bundle. Each entry maps a canonical Hunspell file basename
# (<lang>_<COUNTRY>.{aff,dic}) to the upstream file URL. Where the
# upstream file basename differs from our canonical basename, the file is
# downloaded under the canonical name on disk.
#
# Public functions:
#   qprompt_hunspell_fetch_all(<dest_dir>)
#       Downloads any missing aff/dic into <dest_dir>. Existing files are
#       kept (idempotent); failures are reported as warnings, not errors.
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
#   qprompt_hunspell_install_components(<dest_dir> <install_dir>)
#       Adds install() rules with one CPack component per language so the
#       NSIS installer renders them as user-selectable items. Each
#       dictionary lands at <install_dir>/<lang>.{aff,dic}.
#
#**************************************************************************

include_guard(GLOBAL)

# Language list. Format: "<basename>|<display name>|<aff url>|<dic url>"
#
# Sources are exclusively from LibreOffice/dictionaries (master branch).
# Where LibreOffice ships a dictionary under a different basename
# (e.g. de_DE as de_DE_frami, fr_FR as fr) the URL points at the upstream
# file and the file is downloaded under the canonical basename below.
#
# Languages requested but not available from LibreOffice (French Canadian,
# Chinese Simplified, Japanese) are intentionally omitted. They can be
# added later by adding entries here once an acceptable upstream source
# is identified.
#
# To add or replace a language, add/edit a line and re-configure.
set(_QPROMPT_HUNSPELL_DICT_DEFS
    "ar_SA|Arabic|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/ar/ar.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/ar/ar.dic"
    "cs_CZ|Czech|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/cs_CZ/cs_CZ.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/cs_CZ/cs_CZ.dic"
    "de_DE|German (Germany)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/de/de_DE_frami.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/de/de_DE_frami.dic"
    "en_US|English (US)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_US.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_US.dic"
    "en_GB|English (GB)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_GB.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/en/en_GB.dic"
    "es_ES|Spanish (Spain)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/es/es_ES.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/es/es_ES.dic"
    "es_MX|Spanish (Mexico)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/es/es_MX.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/es/es_MX.dic"
    "fr_FR|French (France)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/fr_FR/fr.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/fr_FR/fr.dic"
    "it_IT|Italian|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/it_IT/it_IT.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/it_IT/it_IT.dic"
    "nl_NL|Dutch|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/nl_NL/nl_NL.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/nl_NL/nl_NL.dic"
    "oc_FR|Occitan|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/oc_FR/oc_FR.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/oc_FR/oc_FR.dic"
    "pl_PL|Polish|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pl_PL/pl_PL.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pl_PL/pl_PL.dic"
    "pt_BR|Portuguese (Brazil)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pt_BR/pt_BR.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pt_BR/pt_BR.dic"
    "pt_PT|Portuguese (Portugal)|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pt_PT/pt_PT.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/pt_PT/pt_PT.dic"
    "ru_RU|Russian|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/ru_RU/ru_RU.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/ru_RU/ru_RU.dic"
    "uk_UA|Ukrainian|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/uk_UA/uk_UA.aff|https://raw.githubusercontent.com/LibreOffice/dictionaries/master/uk_UA/uk_UA.dic"
)

function(_qprompt_hunspell_split_def def out_code out_name out_aff out_dic)
    string(REPLACE "|" ";" parts "${def}")
    list(GET parts 0 code)
    list(GET parts 1 name)
    list(GET parts 2 aff)
    list(GET parts 3 dic)
    set(${out_code} "${code}" PARENT_SCOPE)
    set(${out_name} "${name}" PARENT_SCOPE)
    set(${out_aff}  "${aff}"  PARENT_SCOPE)
    set(${out_dic}  "${dic}"  PARENT_SCOPE)
endfunction()

function(_qprompt_hunspell_download url dest)
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
        message(WARNING "HunspellDictionaries: failed to download ${url} → ${_msg}")
    endif()
endfunction()

function(qprompt_hunspell_fetch_all dest_dir)
    file(MAKE_DIRECTORY "${dest_dir}")
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name aff dic)
        _qprompt_hunspell_download("${aff}" "${dest_dir}/${code}.aff")
        _qprompt_hunspell_download("${dic}" "${dest_dir}/${code}.dic")
    endforeach()
endfunction()

function(qprompt_hunspell_present_files dest_dir out_var)
    set(_files)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic)
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
        _qprompt_hunspell_split_def("${def}" code _name _aff _dic)
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

function(qprompt_hunspell_install_components dest_dir install_dir)
    foreach(def IN LISTS _QPROMPT_HUNSPELL_DICT_DEFS)
        _qprompt_hunspell_split_def("${def}" code name _aff _dic)
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
