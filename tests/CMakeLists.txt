qt_add_executable(scriptfollower_test
    scriptfollower_test.cpp
    ${CMAKE_SOURCE_DIR}/src/scriptfollower.cpp
    ${CMAKE_SOURCE_DIR}/src/scriptfollower.h
)

target_include_directories(scriptfollower_test PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(scriptfollower_test PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Test
)

add_test(NAME scriptfollower_test COMMAND scriptfollower_test)
set_tests_properties(scriptfollower_test PROPERTIES
    ENVIRONMENT_MODIFICATION
        "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt${QT_VERSION_MAJOR}::Core>"
)

<<<<<<< HEAD
# Integration harness. Its runtime, model and WAV fixture are build assets
# prepared by scripts/setup-vosk-dev.ps1.
=======
# Manual integration harness. Its runtime, model and WAV fixture are external
# development assets prepared by scripts/setup-vosk-dev.ps1.
>>>>>>> 22c88cbd1500f0bf9e16afd17121cd20c6daf717
qt_add_executable(vosk_recognizer_smoke
    vosk_recognizer_smoke.cpp
    ${CMAKE_SOURCE_DIR}/src/offlinespeechrecognizer.h
    ${CMAKE_SOURCE_DIR}/src/scriptfollower.cpp
    ${CMAKE_SOURCE_DIR}/src/scriptfollower.h
    ${CMAKE_SOURCE_DIR}/src/voskspeechrecognizer.cpp
    ${CMAKE_SOURCE_DIR}/src/voskspeechrecognizer.h
)

target_include_directories(vosk_recognizer_smoke PRIVATE ${CMAKE_SOURCE_DIR}/src)
target_link_libraries(vosk_recognizer_smoke PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Qml
)
<<<<<<< HEAD

if(WIN32 AND QPROMPT_BUNDLE_VOSK AND DEFINED QPROMPT_VOSK_ASSET_DIR)
    set(_vosk_runtime_dir "${QPROMPT_VOSK_ASSET_DIR}/vosk-win64-0.3.45")
    set(_vosk_library "${_vosk_runtime_dir}/libvosk.dll")
    set(_vosk_model "${QPROMPT_VOSK_ASSET_DIR}/vosk-model-small-en-us-0.15")
    set(_vosk_audio "${QPROMPT_VOSK_ASSET_DIR}/vosk-test.wav")
    set(_vosk_script "${CMAKE_CURRENT_SOURCE_DIR}/fixtures/vosk-test-script.txt")

    if(EXISTS "${_vosk_library}"
            AND EXISTS "${_vosk_model}/conf/model.conf"
            AND EXISTS "${_vosk_audio}")
        add_test(NAME vosk_recognizer_smoke COMMAND vosk_recognizer_smoke
            "${_vosk_library}"
            "${_vosk_model}"
            "${_vosk_audio}"
            "${_vosk_script}"
        )
        set_tests_properties(vosk_recognizer_smoke PROPERTIES
            ENVIRONMENT_MODIFICATION
                "PATH=path_list_prepend:$<TARGET_FILE_DIR:Qt${QT_VERSION_MAJOR}::Core>;PATH=path_list_prepend:${_vosk_runtime_dir}"
        )
    endif()
endif()
=======
>>>>>>> 22c88cbd1500f0bf9e16afd17121cd20c6daf717
