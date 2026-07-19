[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$env:LOCALAPPDATA = Join-Path $env:RUNNER_TEMP ('salary-cat-' + [guid]::NewGuid().ToString('N'))

& (Join-Path $ProjectRoot 'Setup.ps1') -DryRun
& (Join-Path $ProjectRoot 'Install.ps1') -NoApply
& (Join-Path $ProjectRoot 'Install.ps1') -NoApply

$target = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\themes\preset-yuexinmiao'
if (-not (Test-Path -LiteralPath (Join-Path $target 'background.jpg') -PathType Leaf)) {
  throw 'background.jpg was not installed'
}
$theme = Get-Content -LiteralPath (Join-Path $target 'theme.json') -Raw -Encoding UTF8 | ConvertFrom-Json
if ($theme.id -cne 'preset-yuexinmiao') { throw 'unexpected theme id' }
$files = @(Get-ChildItem -LiteralPath $target -File)
if ($files.Count -ne 2) { throw 'installed preset must contain exactly two files' }

Write-Host 'Windows installer tests passed.'
