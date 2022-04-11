#**************************************************************************
#
# QPrompt
# Copyright (C) 2022 Javier O. Cordero Pérez
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

cmake_minimum_required(VERSION 3.0)

FIND_PROGRAM(GETTEXT_MSGFMT_EXECUTABLE msgfmt)

IF(NOT GETTEXT_MSGFMT_EXECUTABLE)
    MESSAGE(
"------
                 NOTE: msgfmt not found. Translations will *not* be installed
------")
ELSE(NOT GETTEXT_MSGFMT_EXECUTABLE)

    SET(catalogname qprompt)

    FILE(GLOB PO_FILES *.po)
    SET(GMO_FILES)

    FOREACH(_poFile ${PO_FILES})
        GET_FILENAME_COMPONENT(_poFileName ${_poFile} NAME)
        STRING(REGEX REPLACE "^${catalogname}_?" "" _langCode ${_poFileName} )
        STRING(REGEX REPLACE "\\.po$" "" _langCode ${_langCode} )

        IF( _langCode )
            GET_FILENAME_COMPONENT(_lang ${_poFile} NAME_WE)
            SET(_gmoFileTarget ${_lang}.gmo)
            SET(_gmoFile ${CMAKE_CURRENT_BINARY_DIR}/${_gmoFileTarget})
            #SET(_gmoFile ${_gmoFileTarget})

            add_custom_target(${_gmoFileTarget})
            ADD_CUSTOM_COMMAND(TARGET ${_gmoFileTarget} # ${PROJECT_NAME} # ${_gmoFile}
                COMMAND ${GETTEXT_MSGFMT_EXECUTABLE} --check -o ${_gmoFile} ${_poFile}
                DEPENDS ${_poFile})
            INSTALL(FILES ${_gmoFile} DESTINATION ${LOCALE_INSTALL_DIR}/${_langCode}/LC_MESSAGES/ RENAME ${catalogname}.mo)
            LIST(APPEND GMO_FILES ${_gmoFile})
        ENDIF( _langCode )

    ENDFOREACH(_poFile ${PO_FILES})

    ADD_CUSTOM_TARGET(translations ALL DEPENDS ${GMO_FILES})
    #install(FILES translations DESTINATION ${LOCALE_INSTALL_DIR})

ENDIF(NOT GETTEXT_MSGFMT_EXECUTABLE)
