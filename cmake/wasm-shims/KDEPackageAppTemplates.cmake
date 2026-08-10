# No-op shim for bundled KDE Framework builds.
#
# Kirigami packages a developer project template as part of its default build.
# QPrompt neither installs nor uses that template, and packaging it requires
# Unix bzip2 tooling that is not supplied by Git for Windows.
include_guard(GLOBAL)

function(kde_package_app_templates)
endfunction()
