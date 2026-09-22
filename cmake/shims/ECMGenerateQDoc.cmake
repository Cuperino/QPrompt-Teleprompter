# No-op shim for ECMGenerateQDoc, used only by the bundled framework builds.
#
# Both KCoreAddons and Kirigami unconditionally include(ECMGenerateQDoc), and the
# upstream module creates global doc targets (prepare_docs, generate_docs, ...)
# at include time without an include guard. Building both frameworks in a single
# CMake tree — as the FetchContent based builds do — therefore aborts with
# duplicate-target errors. QDoc API documentation is not part of QPrompt's build,
# so shadowing the module with an empty ecm_generate_qdoc() is sufficient.
#
# This directory is prepended to CMAKE_MODULE_PATH in the bundled frameworks
# branch of the top-level CMakeLists.txt so this file is found ahead of ECM's
# copy. KCoreAddons overwrites CMAKE_MODULE_PATH, so it still loads ECM's copy;
# the top-level CMakeLists.txt hides Qt6Tools from it to keep it a no-op.
include_guard(GLOBAL)

function(ecm_generate_qdoc)
endfunction()
