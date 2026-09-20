param(
    [Parameter(Mandatory=$true)]
    [string]$Name,
    [string]$Adb = 'adb',
    [string]$OutRoot = "$PSScriptRoot\traces\apk"
)

$ErrorActionPreference = 'Stop'
$scenarioPath = Join-Path $PSScriptRoot "scenarios\$Name.json"
if (-not (Test-Path -LiteralPath $scenarioPath)) { throw "Scenario introuvable : $Name" }

$scenario = Get-Content -Raw -LiteralPath $scenarioPath | ConvertFrom-Json
$taps = ($scenario.taps | ForEach-Object { [string]$_ }) -join ','
$scenarioDir = Join-Path $OutRoot $scenario.id
New-Item -ItemType Directory -Force -Path $scenarioDir | Out-Null
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$out = Join-Path $scenarioDir "$stamp.csv"

Write-Host ''
Write-Host "=== $($scenario.id) : $($scenario.title) ===" -ForegroundColor Cyan
Write-Host "Seed : $($scenario.seed)"
Write-Host "Score attendu : $($scenario.expected.score)"
Write-Host "Fin attendue : tick $($scenario.expected.endTick), $($scenario.expected.death)"
Write-Host ''

& "$PSScriptRoot\run-replay.ps1" -Seed ([int]$scenario.seed) -Taps $taps -Out $out -Adb $Adb
if (-not (Test-Path -LiteralPath $out)) { throw 'La trace APK n a pas ete creee.' }

$latest = Join-Path $scenarioDir 'latest.csv'
Copy-Item -LiteralPath $out -Destination $latest -Force

& node "$PSScriptRoot\tools\validate-trace.mjs" $scenarioPath $out
if ($LASTEXITCODE -ne 0) { throw "Trace invalide pour $($scenario.id)." }

Write-Host ''
Write-Host "Archive : $out" -ForegroundColor Green
Write-Host "Latest  : $latest" -ForegroundColor Green
