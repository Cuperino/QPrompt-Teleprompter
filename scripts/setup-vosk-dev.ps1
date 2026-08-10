param(
    [string]$OutputDirectory = "",
    [switch]$ForceDownload
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($OutputDirectory)) {
    $OutputDirectory = Join-Path $PSScriptRoot "..\build\voice-assets"
}

$assetRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$runtimeArchive = Join-Path $assetRoot "vosk-win64-0.3.45.zip"
$modelArchive = Join-Path $assetRoot "vosk-model-small-en-us-0.15.zip"
$sampleAudio = Join-Path $assetRoot "vosk-test.wav"
$licenseFile = Join-Path $assetRoot "VOSK-COPYING"
$runtimeDirectory = Join-Path $assetRoot "vosk-win64-0.3.45"
$modelDirectory = Join-Path $assetRoot "vosk-model-small-en-us-0.15"

New-Item -ItemType Directory -Path $assetRoot -Force | Out-Null

function Get-DevelopmentAsset {
    param(
        [Parameter(Mandatory = $true)][string]$Uri,
        [Parameter(Mandatory = $true)][string]$Destination
    )

    if ((Test-Path -LiteralPath $Destination) -and -not $ForceDownload) {
        return
    }

    $partial = "$Destination.partial"
    Invoke-WebRequest -Uri $Uri -OutFile $partial
    Move-Item -LiteralPath $partial -Destination $Destination -Force
}

Get-DevelopmentAsset `
    -Uri "https://github.com/alphacep/vosk-api/releases/download/v0.3.45/vosk-win64-0.3.45.zip" `
    -Destination $runtimeArchive
Get-DevelopmentAsset `
    -Uri "https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip" `
    -Destination $modelArchive
Get-DevelopmentAsset `
    -Uri "https://raw.githubusercontent.com/alphacep/vosk-api/master/python/example/test.wav" `
    -Destination $sampleAudio
Get-DevelopmentAsset `
    -Uri "https://raw.githubusercontent.com/alphacep/vosk-api/master/COPYING" `
    -Destination $licenseFile

if (-not (Test-Path -LiteralPath $runtimeDirectory)) {
    Expand-Archive -LiteralPath $runtimeArchive -DestinationPath $assetRoot
}
if (-not (Test-Path -LiteralPath $modelDirectory)) {
    Expand-Archive -LiteralPath $modelArchive -DestinationPath $assetRoot
}

$libraryPath = Join-Path $runtimeDirectory "libvosk.dll"
if (-not (Test-Path -LiteralPath $libraryPath)) {
    throw "The Vosk archive did not contain the expected runtime: $libraryPath"
}
if (-not (Test-Path -LiteralPath (Join-Path $modelDirectory "conf"))) {
    throw "The Vosk archive did not contain a valid model: $modelDirectory"
}

Write-Output "Vosk development assets are ready."
Write-Output "Runtime directory: $runtimeDirectory"
Write-Output "Library: $libraryPath"
Write-Output "Model: $modelDirectory"
Write-Output "Recorded sample: $sampleAudio"
Write-Output "License: $licenseFile"
Write-Output ""
Write-Output "For this PowerShell session:"
Write-Output "`$env:PATH='$runtimeDirectory;' + `$env:PATH"
Write-Output "`$env:QPROMPT_VOSK_LIBRARY='$libraryPath'"
Write-Output "`$env:QPROMPT_VOSK_MODEL='$modelDirectory'"
