[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$env:LOCALAPPDATA = Join-Path $env:RUNNER_TEMP ('salary-cat-' + [guid]::NewGuid().ToString('N'))
$originalUserPath = [Environment]::GetEnvironmentVariable('Path', 'User')

try {
  & (Join-Path $ProjectRoot 'Setup.ps1') -DryRun
  & (Join-Path $ProjectRoot 'skills\codex-skin-salary-cat\scripts\bootstrap-windows.ps1') -DryRun
  & (Join-Path $ProjectRoot 'Setup.ps1') -DependenciesOnly -ForcePortableNode

  $nodeRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\dependencies\node'
  $node = Join-Path $nodeRoot 'node.exe'
  if (-not (Test-Path -LiteralPath $node -PathType Leaf)) { throw 'portable node.exe was not installed' }
  $nodeVersion = (& $node -p 'process.versions.node').Trim()
  if ($LASTEXITCODE -ne 0 -or -not $nodeVersion.StartsWith('22.')) {
    throw "unexpected portable Node.js version: $nodeVersion"
  }
  $userPathEntries = @([Environment]::GetEnvironmentVariable('Path', 'User') -split ';')
  if ($userPathEntries -notcontains $nodeRoot) { throw 'portable Node.js was not added to the user PATH' }

  $unrelated = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin\themes\custom-keepme'
  New-Item -ItemType Directory -Force -Path $unrelated | Out-Null
  Set-Content -LiteralPath (Join-Path $unrelated 'theme.json') -Value '{}' -Encoding UTF8

  & (Join-Path $ProjectRoot 'Install.ps1') -NoApply
  & (Join-Path $ProjectRoot 'Install.ps1') -NoApply

  foreach ($presetId in @('preset-yuexinmiao', 'preset-yuexinmiao-payday')) {
    $target = Join-Path $env:LOCALAPPDATA "CodexDreamSkin\themes\$presetId"
    if (-not (Test-Path -LiteralPath (Join-Path $target 'background.jpg') -PathType Leaf)) {
      throw "$presetId background.jpg was not installed"
    }
    $theme = Get-Content -LiteralPath (Join-Path $target 'theme.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($theme.id -cne $presetId) { throw "unexpected theme id: $($theme.id)" }
    $files = @(Get-ChildItem -LiteralPath $target -File)
    if ($files.Count -ne 2) { throw "$presetId must contain exactly two files" }
  }
  if (-not (Test-Path -LiteralPath (Join-Path $unrelated 'theme.json') -PathType Leaf)) {
    throw 'an unrelated saved theme was removed'
  }

  Write-Host 'Windows installer tests passed.'
} finally {
  [Environment]::SetEnvironmentVariable('Path', $originalUserPath, 'User')
}
