[CmdletBinding()]
param(
  [switch]$NoApply,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$StateRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin'
$RuntimeThemeScript = Join-Path $StateRoot 'engine\scripts\theme-windows.ps1'
$InstallTheme = Join-Path $PSScriptRoot 'Install.ps1'
$UpstreamRepository = 'https://github.com/Fei-Away/Codex-Dream-Skin.git'

if ($DryRun) {
  Write-Host "Would detect runtime: $RuntimeThemeScript"
  Write-Host "Would clone prerequisite when missing: $UpstreamRepository"
  Write-Host "Would install theme with: $InstallTheme"
  exit 0
}

$temporary = $null
try {
  if (-not (Test-Path -LiteralPath $RuntimeThemeScript -PathType Leaf)) {
    if (-not (Get-Command git.exe -ErrorAction SilentlyContinue)) {
      throw 'Git is required to install the Codex Dream Skin prerequisite.'
    }
    $temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('salary-cat-runtime-' + [guid]::NewGuid().ToString('N'))
    & git.exe clone --depth 1 $UpstreamRepository $temporary
    if ($LASTEXITCODE -ne 0) { throw 'Could not clone the Codex Dream Skin prerequisite.' }
    $runtimeInstaller = Join-Path $temporary 'windows\scripts\install-dream-skin.ps1'
    if (-not (Test-Path -LiteralPath $runtimeInstaller -PathType Leaf)) {
      throw 'The upstream Windows installer is missing.'
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runtimeInstaller
    if ($LASTEXITCODE -ne 0) {
      throw 'The base runtime installer failed. Close Codex completely, then run Setup.cmd again.'
    }
  }

  if ($NoApply) {
    & $InstallTheme -NoApply
  } else {
    & $InstallTheme
  }
} finally {
  if ($temporary -and (Test-Path -LiteralPath $temporary)) {
    Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue
  }
}
