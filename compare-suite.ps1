param([Parameter(Mandatory=$true)][string]$PwaRepo)
$ErrorActionPreference = 'Stop'
& "$PSScriptRoot\generate-pwa-traces.ps1" -PwaRepo $PwaRepo

$failed = 0
foreach ($file in (Get-ChildItem "$PSScriptRoot\scenarios\*.json" | Sort-Object Name)) {
    $scenario = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json
    $apk = Join-Path $PSScriptRoot "traces\apk\$($scenario.id)\latest.csv"
    $golden = Join-Path $PSScriptRoot "golden\apk\$($scenario.id).csv"
    if (-not (Test-Path -LiteralPath $apk)) { $apk = $golden }
    $pwa = Join-Path $PSScriptRoot "traces\pwa\$($scenario.id).csv"
    Write-Host "COMPARE $($scenario.id)" -ForegroundColor Cyan
    & node "$PSScriptRoot\tools\compare-traces.mjs" $apk $pwa
    if ($LASTEXITCODE -ne 0) { $failed++ }
}
if ($failed -gt 0) { throw "$failed scenario(s) divergent(s)." }
