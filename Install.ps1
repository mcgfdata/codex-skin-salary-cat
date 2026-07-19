[CmdletBinding()]
param([switch]$NoApply)

$ErrorActionPreference = 'Stop'
$ScriptPath = Join-Path $PSScriptRoot 'scripts/install-theme-windows.ps1'
& $ScriptPath @PSBoundParameters
