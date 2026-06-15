# No-op shim for ECMGenerateQDoc, used only by the bundled WASM framework build.
#
# Both KCoreAddons and Kirigami unconditionally include(ECMGenerateQDoc), and the
# upstream module creates global doc targets (prepare_docs, generate_docs, ...)
# at include time without an include guard. Building both frameworks in a single
# CMake tree — as the WASM build does via FetchContent — therefore aborts with
# duplicate-target errors. QDoc API documentation is not part of QPrompt's build,
# so shadowing the module with an empty ecm_generate_qdoc() is sufficient.
#
# This directory is prepended to CMAKE_MODULE_PATH in the WASM branch of the
# top-level CMakeLists.txt so this file is found ahead of ECM's copy.
include_guard(GLOBAL)

function(ecm_generate_qdoc)
endfunction()
