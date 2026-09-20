param(
    [string]$Apk = "$PSScriptRoot\out\FlappyBird-1.3-instrumented.apk",
    [string]$Adb = 'adb',
    [switch]$UninstallOriginal
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $Apk)) { throw "APK introuvable : $Apk" }
if (-not (Get-Command $Adb -ErrorAction SilentlyContinue)) { throw "adb introuvable : $Adb" }

& $Adb wait-for-device
if ($UninstallOriginal) {
    & $Adb uninstall com.dotgears.flappybird | Out-Host
}
& $Adb install -r $Apk | Out-Host
if ($LASTEXITCODE -ne 0) { throw 'Installation ADB echouee.' }
