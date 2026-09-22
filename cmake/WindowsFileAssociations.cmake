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
# WindowsFileAssociations.cmake
#
# File type registration for the Windows NSIS installer.
#
# Installing QPrompt always registers the file types listed below: each one
# gets a ProgID of its own under Software\Classes, QPrompt is added to the
# extension's "Open with" menu, the application is registered under
# Software\Classes\Applications, and its capabilities are published through
# Software\RegisteredApplications, which is what gives QPrompt a page of its
# own under Settings > Default apps. None of that takes a file type away
# from the program currently handling it.
#
# What is optional is whether QPrompt becomes the *default* application for
# each type. That is asked on a page of its own, shown once QPrompt has been
# installed and before the finish page offers to run it, with every file
# type unticked. The choices are applied when the user moves on from that
# page.
#
# Windows 10 and 11 do not let an installer change a default the user has
# already picked: that choice lives in a per-user UserChoice key protected
# by a hash, and on Windows 11 by the UCPD driver as well, and it overrides
# any machine-wide default. So ticking a file type does two things:
#   - it makes QPrompt the machine-wide default handler of the extension,
#     remembering the handler that was in place so uninstalling QPrompt
#     puts it back. This is what applies to accounts that have not chosen
#     a default for the extension.
#   - if the account running the installer has chosen another application,
#     Settings is opened on QPrompt's Default apps page, where the user
#     confirms the change. That is the only way Windows allows a program to
#     become the user's default.
#
# Implementation note: CPack has no documented hook for adding a page or a
# function to the generated NSIS script — every CPACK_NSIS_EXTRA_*_COMMANDS
# variable is substituted inside a section or function that already exists.
# Two variables the NSIS template substitutes at the places this needs are
# not written by the NSIS generator when a project leaves them alone, so the
# values set here are what end up in the script:
#
#   CPACK_NSIS_INSTALLER_FINISH_TITLE_3LINES_CODE
#       the finish page's MUI_FINISHPAGE_TITLE_3LINES define, which the
#       generator only writes for CPACK_NSIS_FINISH_TITLE_3LINES (QPrompt
#       does not set it). It is substituted between the installation page
#       and the finish page, which is where the custom page is inserted.
#   CPACK_NSIS_INSTALLATION_TYPES
#       the CPack install types (declared with cpack_add_install_type(),
#       which QPrompt does not use), substituted at file scope ahead of the
#       component sections. Carries the page's variables and functions.
#
# Setting CPACK_NSIS_FINISH_TITLE_3LINES or declaring install types would
# therefore be ignored, and should a future CPack write either variable on
# its own, the file type page would go missing from the installer, which is
# visible the first time the installer is run.
#
# Public function:
#   qprompt_windows_file_associations(<exe_path>
#       PAGE <var> CODE <var> INSTALL <var> UNINSTALL <var>)
#
#       <exe_path> is the QPrompt executable's path relative to the
#       installation directory, e.g. "bin/QPrompt.exe". PAGE and CODE are
#       set to the page insertion and to the page's implementation; the
#       registration and cleanup code is appended to INSTALL and UNINSTALL.
#       Pass CPACK_NSIS_INSTALLER_FINISH_TITLE_3LINES_CODE,
#       CPACK_NSIS_INSTALLATION_TYPES, CPACK_NSIS_EXTRA_INSTALL_COMMANDS and
#       CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS, in that order.
#
#**************************************************************************

include_guard(GLOBAL)

# File type list. Format: "<extension>|<file type name>|<ProgID>"
#
# The ProgID is the key QPrompt owns under Software\Classes; it is prefixed
# with the application name so it cannot collide with the ProgID of another
# application. To offer another extension, add a line here; the extension
# has to be one Prompter.qml's open dialog accepts.
set(_QPROMPT_FILE_ASSOCIATION_DEFS
    "html|Hypertext Markup Language|QPrompt.html"
    "txt|Plain Text|QPrompt.txt"
)

# Tells the shell to reload file type information, so registrations made or
# undone by the installer take effect without a sign out. 0x08000000 is
# SHCNE_ASSOCCHANGED.
set(_QPROMPT_ASSOC_NOTIFY_SHELL
    "System::Call 'shell32::SHChangeNotify(i 0x08000000, i 0, i 0, i 0)'")

# Registry writes are made in the 64 bit view: the shell reads file type
# information from it, while the installer itself is a 32 bit program whose
# writes to HKLM\Software would otherwise be redirected into Wow6432Node and
# go unnoticed.
set(_QPROMPT_ASSOC_REGVIEW "SetRegView 64")

# Name QPrompt is registered under in Software\RegisteredApplications, and
# the key holding its capabilities. The Settings link below refers to the
# former, so it must not contain characters that need escaping in a URI.
set(_QPROMPT_ASSOC_APP_NAME "QPrompt")
set(_QPROMPT_ASSOC_CAPABILITIES_KEY "Software\\QPrompt\\Capabilities")

function(_qprompt_association_split_def def out_ext out_name out_progid)
    string(REPLACE "|" ";" parts "${def}")
    list(GET parts 0 ext)
    list(GET parts 1 name)
    list(GET parts 2 progid)
    set(${out_ext}    "${ext}"    PARENT_SCOPE)
    set(${out_name}   "${name}"   PARENT_SCOPE)
    set(${out_progid} "${progid}" PARENT_SCOPE)
endfunction()

function(qprompt_windows_file_associations exe_path)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "" "PAGE;CODE;INSTALL;UNINSTALL" "")
    foreach(keyword IN ITEMS PAGE CODE INSTALL UNINSTALL)
        if(NOT ARG_${keyword})
            message(FATAL_ERROR "qprompt_windows_file_associations: ${keyword} is required")
        endif()
    endforeach()

    # NSIS expects Windows path separators.
    string(REPLACE "/" "\\" exe "${exe_path}")
    get_filename_component(exe_name "${exe_path}" NAME)
    set(app_key "Software\\Classes\\Applications\\${exe_name}")

    set(page "; File types QPrompt should open by default, asked once QPrompt is
  ; installed (see cmake/WindowsFileAssociations.cmake)
  Page custom qpromptFileTypesPage qpromptFileTypesPageLeave
")

    # The page's controls are laid out below the explanation, one row of 14
    # dialog units per file type. Leaving the page applies the file types
    # ticked on it, which is the installer's last step before the finish
    # page.
    set(code "
;--------------------------------
; QPrompt's file type page (see cmake/WindowsFileAssociations.cmake)

!include \"nsDialogs.nsh\"

Var QPROMPT_FILE_TYPES_DIALOG
; Set to 1 when the current user has to confirm a default application in
; Settings.
Var QPROMPT_CONFIRM_DEFAULTS
")
    set(page_controls "")
    set(page_leave "")
    set(row 34)
    foreach(def IN LISTS _QPROMPT_FILE_ASSOCIATION_DEFS)
        _qprompt_association_split_def("${def}" ext name progid)
        string(TOUPPER "${ext}" ext_upper)
        string(APPEND code "Var QPROMPT_DEFAULT_${ext_upper}
Var QPROMPT_DEFAULT_${ext_upper}_CHECKBOX
")
        string(APPEND page_controls "
  \${NSD_CreateCheckbox} 0 ${row}u 100% 12u \"${name} (.${ext})\"
  Pop \$QPROMPT_DEFAULT_${ext_upper}_CHECKBOX
  \${NSD_SetState} \$QPROMPT_DEFAULT_${ext_upper}_CHECKBOX \$QPROMPT_DEFAULT_${ext_upper}
")
        string(APPEND page_leave "
  ; Default application for .${ext}, if it was ticked. The machine-wide
  ; handler that was in place is noted down so the uninstaller can restore
  ; it; the note is only taken the first time, so reinstalling over an
  ; existing association does not overwrite it with QPrompt's own file type.
  \${NSD_GetState} \$QPROMPT_DEFAULT_${ext_upper}_CHECKBOX \$QPROMPT_DEFAULT_${ext_upper}
  StrCmp \$QPROMPT_DEFAULT_${ext_upper} 1 0 qprompt_default_${ext}_done
  ReadRegStr \$0 SHCTX \"Software\\Classes\\.${ext}\" \"\"
  StrCmp \$0 \"${progid}\" qprompt_default_${ext}_set 0
  WriteRegStr SHCTX \"Software\\Classes\\${progid}\" \"QPromptPreviousHandler\" \"\$0\"
  qprompt_default_${ext}_set:
  WriteRegStr SHCTX \"Software\\Classes\\.${ext}\" \"\" \"${progid}\"
  ; A default the user picked takes precedence over the one above and
  ; cannot be changed by an installer, so have them confirm it in Settings
  ; unless it already is QPrompt.
  ReadRegStr \$0 HKCU \"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\FileExts\\.${ext}\\UserChoice\" \"ProgId\"
  StrCmp \$0 \"\" qprompt_default_${ext}_done 0
  StrCmp \$0 \"${progid}\" qprompt_default_${ext}_done 0
  StrCpy \$QPROMPT_CONFIRM_DEFAULTS 1
  qprompt_default_${ext}_done:
")
        math(EXPR row "${row} + 14")
    endforeach()

    string(APPEND code "
Function qpromptFileTypesPage
  !insertmacro MUI_HEADER_TEXT \"File Types\" \"Choose the file types QPrompt should open by default.\"

  nsDialogs::Create 1018
  Pop \$QPROMPT_FILE_TYPES_DIALOG
  StrCmp \$QPROMPT_FILE_TYPES_DIALOG error 0 +2
  Abort

  \${NSD_CreateLabel} 0 0 100% 28u \"QPrompt has been added to the $\\\"Open with$\\\" menu of the file types below. Tick a file type to make QPrompt its default application. If you have already picked another application for it, Windows asks you to confirm the change in Settings, which opens when you click Next.\"
  Pop \$0
${page_controls}
  nsDialogs::Show
FunctionEnd

Function qpromptFileTypesPageLeave
  StrCpy \$QPROMPT_CONFIRM_DEFAULTS 0
  ${_QPROMPT_ASSOC_REGVIEW}
${page_leave}
  SetRegView default
  ${_QPROMPT_ASSOC_NOTIFY_SHELL}

  ; Open QPrompt's page under Settings > Default apps, where the user can
  ; make it the default for the file types they ticked.
  StrCmp \$QPROMPT_CONFIRM_DEFAULTS 1 0 qprompt_confirm_defaults_done
  ExecShell \"open\" \"ms-settings:defaultapps?registeredAppMachine=${_QPROMPT_ASSOC_APP_NAME}\"
  qprompt_confirm_defaults_done:
FunctionEnd
")

    # Registration, always performed as part of the installation.
    set(install "
  ; Register QPrompt's file types (see cmake/WindowsFileAssociations.cmake).
  DetailPrint \"Registering QPrompt's file types...\"
  ${_QPROMPT_ASSOC_REGVIEW}
  WriteRegStr SHCTX \"${app_key}\" \"FriendlyAppName\" \"QPrompt\"
  WriteRegStr SHCTX \"${app_key}\\DefaultIcon\" \"\" \"\$INSTDIR\\${exe},0\"
  WriteRegStr SHCTX \"${app_key}\\shell\\open\\command\" \"\" '\"\$INSTDIR\\${exe}\" \"%1\"'

  ; Capabilities, which list QPrompt under Settings > Default apps.
  WriteRegStr SHCTX \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\" \"ApplicationName\" \"QPrompt\"
  WriteRegStr SHCTX \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\" \"ApplicationDescription\" \"Personal teleprompter software for all video makers.\"
  WriteRegStr SHCTX \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\" \"ApplicationIcon\" \"\$INSTDIR\\${exe},0\"
  WriteRegStr SHCTX \"Software\\RegisteredApplications\" \"${_QPROMPT_ASSOC_APP_NAME}\" \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\"
")
    set(uninstall "
  ; Unregister QPrompt's file types. Every extension is checked before it is
  ; touched, so file types QPrompt was not made the default application of,
  ; and handlers registered by other applications, are left alone.
  ${_QPROMPT_ASSOC_REGVIEW}
  DeleteRegKey SHCTX \"${app_key}\"
  DeleteRegValue SHCTX \"Software\\RegisteredApplications\" \"${_QPROMPT_ASSOC_APP_NAME}\"
  DeleteRegKey SHCTX \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\"
  DeleteRegKey /ifempty SHCTX \"Software\\QPrompt\"
")

    foreach(def IN LISTS _QPROMPT_FILE_ASSOCIATION_DEFS)
        _qprompt_association_split_def("${def}" ext name progid)

        string(APPEND install "
  ; The file type QPrompt owns for .${ext}, and the entries that put QPrompt
  ; in this extension's \"Open with\" menu.
  WriteRegStr SHCTX \"Software\\Classes\\${progid}\" \"\" \"${name} document\"
  WriteRegStr SHCTX \"Software\\Classes\\${progid}\" \"FriendlyTypeName\" \"${name} document\"
  WriteRegStr SHCTX \"Software\\Classes\\${progid}\\DefaultIcon\" \"\" \"\$INSTDIR\\${exe},0\"
  WriteRegStr SHCTX \"Software\\Classes\\${progid}\\shell\\open\\command\" \"\" '\"\$INSTDIR\\${exe}\" \"%1\"'
  WriteRegStr SHCTX \"Software\\Classes\\.${ext}\\OpenWithProgids\" \"${progid}\" \"\"
  WriteRegStr SHCTX \"${app_key}\\SupportedTypes\" \".${ext}\" \"\"
  WriteRegStr SHCTX \"${_QPROMPT_ASSOC_CAPABILITIES_KEY}\\FileAssociations\" \".${ext}\" \"${progid}\"
")

        string(APPEND uninstall "
  ReadRegStr \$0 SHCTX \"Software\\Classes\\.${ext}\" \"\"
  StrCmp \$0 \"${progid}\" 0 qprompt_unassoc_${ext}_cleanup
  ReadRegStr \$1 SHCTX \"Software\\Classes\\${progid}\" \"QPromptPreviousHandler\"
  StrCmp \$1 \"\" 0 qprompt_unassoc_${ext}_restore
  DeleteRegValue SHCTX \"Software\\Classes\\.${ext}\" \"\"
  Goto qprompt_unassoc_${ext}_cleanup
  qprompt_unassoc_${ext}_restore:
  WriteRegStr SHCTX \"Software\\Classes\\.${ext}\" \"\" \"\$1\"
  qprompt_unassoc_${ext}_cleanup:
  DeleteRegValue SHCTX \"Software\\Classes\\.${ext}\\OpenWithProgids\" \"${progid}\"
  DeleteRegKey /ifempty SHCTX \"Software\\Classes\\.${ext}\\OpenWithProgids\"
  DeleteRegKey SHCTX \"Software\\Classes\\${progid}\"
  DeleteRegKey /ifempty SHCTX \"Software\\Classes\\.${ext}\"
")
    endforeach()

    string(APPEND install "
  SetRegView default
  ${_QPROMPT_ASSOC_NOTIFY_SHELL}
")
    string(APPEND uninstall "
  SetRegView default
  ${_QPROMPT_ASSOC_NOTIFY_SHELL}
")

    set(${ARG_PAGE} "${page}" PARENT_SCOPE)
    set(${ARG_CODE} "${code}" PARENT_SCOPE)
    set(${ARG_INSTALL} "${${ARG_INSTALL}}${install}" PARENT_SCOPE)
    set(${ARG_UNINSTALL} "${${ARG_UNINSTALL}}${uninstall}" PARENT_SCOPE)
endfunction()
