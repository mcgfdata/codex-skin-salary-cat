[CmdletBinding()]
param(
  [switch]$NoApply,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$ArchiveUrl = 'https://github.com/mcgfdata/codex-skin-salary-cat/archive/refs/heads/main.zip'

if ($DryRun) {
  Write-Host "Would download the Salary Cat setup repository: $ArchiveUrl"
  Write-Host 'Would then run Setup.ps1, including automatic dependency installation.'
  exit 0
}

$temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('salary-cat-skill-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $temporary | Out-Null
try {
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  $archivePath = Join-Path $temporary 'salary-cat.zip'
  Invoke-WebRequest -Uri $ArchiveUrl -OutFile $archivePath -UseBasicParsing
  $extractRoot = Join-Path $temporary 'extract'
  Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force
  $setup = Join-Path $extractRoot 'codex-skin-salary-cat-main\Setup.ps1'
  if (-not (Test-Path -LiteralPath $setup -PathType Leaf)) { throw 'Salary Cat Setup.ps1 is missing.' }
  if ($NoApply) { & $setup -NoApply } else { & $setup }
} finally {
  Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue
}
