param(
    [int]$Seed = 123456789,
    [string]$Taps = '0,18,36,54,72,90,108,126,144,162,180',
    [string]$Out = "$PSScriptRoot\out\apk-trace.csv",
    [string]$Adb = 'adb'
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command $Adb -ErrorAction SilentlyContinue)) {
    throw 'adb introuvable dans le PATH. Passe -Adb C:\...\adb.exe si necessaire.'
}

New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Out) | Out-Null
Remove-Item -LiteralPath $Out -Force -ErrorAction SilentlyContinue

& $Adb wait-for-device
& $Adb logcat -c
& $Adb shell am force-stop com.dotgears.flappybird

$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = $Adb
$psi.Arguments = 'logcat -v raw -s Flappy13Trace:I *:S'
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$logcat = New-Object System.Diagnostics.Process
$logcat.StartInfo = $psi
[void]$logcat.Start()
Start-Sleep -Milliseconds 250

Write-Host "Seed : $Seed"
Write-Host "Taps : $Taps"
Write-Host 'Lancement de l APK instrumentee...'

& $Adb shell am start -S -n com.dotgears.flappybird/com.dotgears.flappy.SplashScreen --ez flappy_test true --ei flappy_seed $Seed --es flappy_taps $Taps | Out-Null

Write-Host ''
Write-Host 'Dans le jeu : appuie UNE FOIS sur PLAY, puis ne touche plus l ecran.' -ForegroundColor Yellow
Write-Host 'Le replay demarre automatiquement quand GET READY est stabilise.'
Write-Host "Trace : $Out"
Write-Host ''

$tapCount = @($Taps -split ',' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }).Count
$expectedConfig = "CONFIG,seed=$Seed,taps=$tapCount"
$captureStarted = $false
try {
    while (-not $logcat.HasExited) {
        $line = $logcat.StandardOutput.ReadLine()
        if ($null -eq $line) { Start-Sleep -Milliseconds 20; continue }
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # CONFIG is the authoritative start marker. Some API 19 AVD/logcat
        # combinations can replay stale tagged lines even after logcat -c.
        if (-not $captureStarted) {
            if ($line -ne $expectedConfig) { continue }
            $captureStarted = $true
        }

        Add-Content -LiteralPath $Out -Value $line -Encoding UTF8
        Write-Host $line
        if ($line -like 'END,*') {
            Write-Host ''
            Write-Host 'Run termine. Trace capturee.' -ForegroundColor Green
            break
        }
    }
}
finally {
    if (-not $logcat.HasExited) { $logcat.Kill() }
    $logcat.Dispose()
}
