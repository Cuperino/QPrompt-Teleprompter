param(
    [string]$QtPrefix = "C:\Qt\6.8.3\msvc2022_64",
    [string]$BuildDirectory = "",
    [string]$InstallDirectory = "",
    [int]$ParallelJobs = 4
)

$ErrorActionPreference = "Stop"

$sourceDirectory = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
if ([string]::IsNullOrWhiteSpace($BuildDirectory)) {
    $BuildDirectory = Join-Path $sourceDirectory "build-release"
}
if ([string]::IsNullOrWhiteSpace($InstallDirectory)) {
    $InstallDirectory = Join-Path $sourceDirectory "package-stage"
}

$buildPath = [System.IO.Path]::GetFullPath($BuildDirectory)
$installPath = [System.IO.Path]::GetFullPath($InstallDirectory)
$qtPath = [System.IO.Path]::GetFullPath($QtPrefix)
$assetPath = Join-Path $sourceDirectory "build\voice-assets"
$qtRoot = Split-Path -Parent (Split-Path -Parent $qtPath)
$cmake = Join-Path $qtRoot "Tools\CMake_64\bin\cmake.exe"
$ctest = Join-Path $qtRoot "Tools\CMake_64\bin\ctest.exe"
$cpack = Join-Path $qtRoot "Tools\CMake_64\bin\cpack.exe"

foreach ($requiredTool in @($cmake, $ctest, $cpack)) {
    if (-not (Test-Path -LiteralPath $requiredTool)) {
        throw "Required Qt build tool was not found: $requiredTool"
    }
}
if (-not (Test-Path -LiteralPath (Join-Path $qtPath "bin\Qt6Core.dll"))) {
    throw "Qt was not found at $qtPath"
}

& (Join-Path $PSScriptRoot "setup-vosk-dev.ps1") `
    -OutputDirectory $assetPath `
    -SkipEnvironmentInstructions

& $cmake `
    -Wno-dev `
    -S $sourceDirectory `
    -B $buildPath `
    "-DCMAKE_CONFIGURATION_TYPES=Release" `
    "-DCMAKE_PREFIX_PATH=$qtPath" `
    "-DCMAKE_INSTALL_PREFIX=$installPath" `
    "-DQPROMPT_BUILD_TESTS=ON" `
    "-DQPROMPT_BUNDLE_VOSK=ON" `
    "-DQPROMPT_VOSK_ASSET_DIR=$assetPath"
if ($LASTEXITCODE -ne 0) {
    throw "CMake configuration failed with exit code $LASTEXITCODE."
}

& $cmake --build $buildPath --config Release --parallel $ParallelJobs
if ($LASTEXITCODE -ne 0) {
    throw "Release build failed with exit code $LASTEXITCODE."
}

& $ctest --test-dir $buildPath -C Release --output-on-failure
if ($LASTEXITCODE -ne 0) {
    throw "Automated tests failed with exit code $LASTEXITCODE."
}

& $cmake --install $buildPath --config Release
if ($LASTEXITCODE -ne 0) {
    throw "Release staging failed with exit code $LASTEXITCODE."
}

$makensisDirectory = "C:\Program Files (x86)\NSIS"
if (Test-Path -LiteralPath (Join-Path $makensisDirectory "makensis.exe")) {
    $env:Path = "$makensisDirectory;$env:Path"
}

Push-Location -LiteralPath $buildPath
try {
    & $cpack -C Release -G NSIS
    if ($LASTEXITCODE -ne 0) {
        throw "NSIS packaging failed with exit code $LASTEXITCODE."
    }
}
finally {
    Pop-Location
}

$installer = Get-ChildItem -LiteralPath $buildPath -Filter "*.exe" -File |
    Where-Object { $_.Name -ne "QPrompt.exe" } |
    Sort-Object LastWriteTime -Descending |
    Select-Object -First 1
if ($null -eq $installer) {
    throw "CPack completed but no installer was found in $buildPath"
}

Write-Output ""
Write-Output "Self-contained Voice Follow installer: $($installer.FullName)"
Write-Output "Staged application: $(Join-Path $installPath 'bin\QPrompt.exe')"
