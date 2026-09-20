param([string]$Adb = 'adb')
$ErrorActionPreference = 'Stop'
$scenarios = Get-ChildItem "$PSScriptRoot\scenarios\*.json" | Sort-Object Name

Write-Host 'Flappy Bird 1.3 - cross-test suite' -ForegroundColor Cyan
Write-Host 'Chaque scenario relance l APK. Au menu, clique UNE FOIS sur PLAY puis ne touche plus.'
Write-Host ''

foreach ($file in $scenarios) {
    $scenario = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json
    Write-Host "Prochain scenario : $($scenario.id) - $($scenario.title)" -ForegroundColor Yellow
    Read-Host 'Appuie sur Entree pour lancer'
    & "$PSScriptRoot\run-scenario.ps1" -Name $scenario.id -Adb $Adb
}

Write-Host ''
Write-Host 'Suite APK terminee. Traces archivees sous traces\apk\<scenario>\.' -ForegroundColor Green
