param([Parameter(Mandatory=$true)][string]$PwaRepo)
$ErrorActionPreference = 'Stop'
& node "$PSScriptRoot\tools\generate-pwa-traces.mjs" $PwaRepo $PSScriptRoot
if ($LASTEXITCODE -ne 0) { throw 'Generation des traces PWA echouee.' }
