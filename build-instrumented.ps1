param(
    [Parameter(Mandatory=$true)]
    [string]$Apk,
    [string]$ApktoolJar = "$PSScriptRoot\.cache\apktool_2.9.3.jar",
    [string]$OutApk = "$PSScriptRoot\out\FlappyBird-1.3-instrumented.apk",
    [switch]$AllowUnverifiedApk
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$ExpectedApkSha256 = 'A3E6958CE2100966F4E207778E4CDBE72788214148C7F4BFD042BA365498DEB3'
$ExpectedApktoolSha256 = '7956EB04194300CE0D0A84AD18771EEBC94B89FB8D1DDCCE8EA4C056818646F4'

function Resolve-JavaTool([string]$Name) {
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $candidates = @(
        "$env:ProgramFiles\Android\Android Studio\jbr\bin\$Name.exe",
        "$env:ProgramFiles\Java\jdk-21\bin\$Name.exe",
        "$env:ProgramFiles\Java\jdk-17\bin\$Name.exe"
    )
    foreach ($candidate in $candidates) {
        if (Test-Path $candidate) { return $candidate }
    }
    throw "$Name introuvable. Installe Android Studio ou un JDK puis relance."
}

function Resolve-Python {
    $candidates = @(
        @{ Name = 'python'; Prefix = @() },
        @{ Name = 'py'; Prefix = @('-3') },
        @{ Name = 'python3'; Prefix = @() }
    )

    foreach ($candidate in $candidates) {
        $cmd = Get-Command $candidate.Name -ErrorAction SilentlyContinue
        if (-not $cmd) { continue }

        $exe = $cmd.Source
        $prefix = @($candidate.Prefix)
        try {
            & $exe @prefix -c 'import sys; raise SystemExit(0 if sys.version_info.major == 3 else 1)' 2>$null
            if ($LASTEXITCODE -eq 0) {
                return @{ Exe = $exe; Prefix = $prefix }
            }
        } catch {
            # Ignore Windows App Execution Alias stubs and continue to the next candidate.
        }
    }

    throw 'Python 3 utilisable introuvable dans le PATH.'
}

if (-not (Test-Path -LiteralPath $Apk)) { throw "APK introuvable : $Apk" }
$Apk = (Resolve-Path -LiteralPath $Apk).Path

$apkHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $Apk).Hash.ToUpperInvariant()
if ($apkHash -ne $ExpectedApkSha256) {
    if (-not $AllowUnverifiedApk) {
        throw "APK non reconnu. SHA-256=$apkHash ; attendu=$ExpectedApkSha256. Utilise -AllowUnverifiedApk uniquement pour un test volontaire."
    }
    Write-Warning "APK non verifie : $apkHash"
} else {
    Write-Host "APK 1.3 de reference verifie : $apkHash" -ForegroundColor Green
}

$java = Resolve-JavaTool 'java'
$keytool = Resolve-JavaTool 'keytool'
$jarsigner = Resolve-JavaTool 'jarsigner'
$python = Resolve-Python

if (-not (Test-Path -LiteralPath $ApktoolJar)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $ApktoolJar) | Out-Null
    $url = 'https://github.com/iBotPeaches/Apktool/releases/download/v2.9.3/apktool_2.9.3.jar'
    Write-Host 'Telechargement apktool 2.9.3...'
    Invoke-WebRequest -Uri $url -OutFile $ApktoolJar
}

$apktoolHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $ApktoolJar).Hash.ToUpperInvariant()
if ($apktoolHash -ne $ExpectedApktoolSha256) {
    throw "SHA-256 apktool invalide : $apktoolHash"
}

$work = Join-Path $PSScriptRoot 'work'
$decoded = Join-Path $work 'decoded'
Remove-Item $work -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $decoded | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $OutApk) | Out-Null

Write-Host 'Decodage APK...'
& $java -jar $ApktoolJar d -f $Apk -o $decoded
if ($LASTEXITCODE -ne 0) { throw 'apktool decode a echoue.' }

Write-Host 'Injection du harness...'
$pythonArgs = @($python.Prefix) + @(
    "$PSScriptRoot\tools\patch-apk.py",
    '--decoded', $decoded,
    '--patch', "$PSScriptRoot\patches\TestHarness.smali"
)
& $python.Exe @pythonArgs
if ($LASTEXITCODE -ne 0) { throw 'Patch de l APK echoue.' }

$unsigned = Join-Path $work 'FlappyBird-1.3-instrumented-unsigned.apk'
Write-Host 'Recompilation APK...'
& $java -jar $ApktoolJar b $decoded -o $unsigned
if ($LASTEXITCODE -ne 0) { throw 'apktool build a echoue.' }

$keystore = Join-Path $PSScriptRoot '.cache\flappy13-test.jks'
if (-not (Test-Path -LiteralPath $keystore)) {
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $keystore) | Out-Null
    Write-Host 'Creation de la cle de test locale...'
    & $keytool -genkeypair -v -keystore $keystore -storepass flappy13test -keypass flappy13test -alias flappy13test -keyalg RSA -keysize 2048 -validity 3650 -dname 'CN=Flappy13 Test Harness,O=Local Test,C=FR'
    if ($LASTEXITCODE -ne 0) { throw 'Generation keystore echouee.' }
}

Copy-Item -LiteralPath $unsigned -Destination $OutApk -Force
Write-Host 'Signature APK de test...'
& $jarsigner -keystore $keystore -storepass flappy13test -keypass flappy13test -sigalg SHA256withRSA -digestalg SHA-256 $OutApk flappy13test
if ($LASTEXITCODE -ne 0) { throw 'Signature APK echouee.' }

& $jarsigner -verify $OutApk | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Verification signature echouee.' }

Write-Host ''
Write-Host 'APK instrumentee prete :' -ForegroundColor Green
Write-Host $OutApk
Write-Host ''
Write-Host 'La signature est volontairement differente de l APK original : desinstalle l original avant installation.'
