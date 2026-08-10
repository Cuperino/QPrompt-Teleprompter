param(
    [string]$Executable = "",
    [string]$AssetDirectory = "",
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$QPromptArguments
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($Executable)) {
    $Executable = Join-Path $PSScriptRoot "..\install\bin\QPrompt.exe"
}
if ([string]::IsNullOrWhiteSpace($AssetDirectory)) {
    $AssetDirectory = Join-Path $PSScriptRoot "..\build\voice-assets"
}

$executablePath = [System.IO.Path]::GetFullPath($Executable)
$assetRoot = [System.IO.Path]::GetFullPath($AssetDirectory)
$runtimeDirectory = Join-Path $assetRoot "vosk-win64-0.3.45"
$libraryPath = Join-Path $runtimeDirectory "libvosk.dll"
$modelPath = Join-Path $assetRoot "vosk-model-small-en-us-0.15"

if (-not (Test-Path -LiteralPath $executablePath)) {
    throw "QPrompt has not been installed at $executablePath"
}
if (-not (Test-Path -LiteralPath $libraryPath)) {
    throw "Vosk development assets are missing. Run scripts\setup-vosk-dev.ps1 first."
}
if (-not (Test-Path -LiteralPath (Join-Path $modelPath "conf"))) {
    throw "The Vosk development model is missing. Run scripts\setup-vosk-dev.ps1 first."
}

$env:PATH = "$runtimeDirectory;$env:PATH"
$env:QPROMPT_VOSK_LIBRARY = $libraryPath
$env:QPROMPT_VOSK_MODEL = $modelPath
$env:QT_LOGGING_TO_CONSOLE = "1"
$env:QT_FORCE_STDERR_LOGGING = "1"

$applicationDirectory = Split-Path -Parent $executablePath
$exitCode = 0
Push-Location -LiteralPath $applicationDirectory
try {
    & $executablePath @QPromptArguments
    if ($null -ne $LASTEXITCODE) {
        $exitCode = $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    throw "QPrompt exited during startup with code $exitCode. See the Qt messages above."
}
