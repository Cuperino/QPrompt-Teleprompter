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

# Manual integration harness. Its runtime, model and WAV fixture are external
# development assets prepared by scripts/setup-vosk-dev.ps1.
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
