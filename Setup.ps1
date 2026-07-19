[CmdletBinding()]
param(
  [switch]$NoApply,
  [switch]$DryRun,
  [switch]$DependenciesOnly,
  [switch]$ForcePortableNode
)

$ErrorActionPreference = 'Stop'
$StateRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin'
$RuntimeThemeScript = Join-Path $StateRoot 'engine\scripts\theme-windows.ps1'
$RuntimeCompletionMarker = Join-Path $StateRoot 'config.before-dream-skin.toml.appearance.json'
$InstallTheme = Join-Path $PSScriptRoot 'Install.ps1'
$UpstreamArchiveUrl = 'https://github.com/Fei-Away/Codex-Dream-Skin/archive/refs/heads/main.zip'
$NodeDistributionRoot = 'https://nodejs.org/dist/latest-v22.x'

function Invoke-SalaryCatDownload {
  param(
    [Parameter(Mandatory = $true)][string]$Uri,
    [Parameter(Mandatory = $true)][string]$Destination
  )
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -Uri $Uri -OutFile $Destination -UseBasicParsing
  if (-not (Test-Path -LiteralPath $Destination -PathType Leaf) -or
      (Get-Item -LiteralPath $Destination).Length -lt 1) {
    throw "Download was empty: $Uri"
  }
}

function Test-SalaryCatDreamSkinRuntime {
  if (-not (Test-Path -LiteralPath $RuntimeThemeScript -PathType Leaf) -or
      -not (Test-Path -LiteralPath $RuntimeCompletionMarker -PathType Leaf)) {
    return $false
  }
  try {
    $marker = Get-Content -LiteralPath $RuntimeCompletionMarker -Raw -Encoding UTF8 | ConvertFrom-Json
    return ([int]$marker.schemaVersion -eq 1 -and $marker.appearanceThemeManaged -is [bool])
  } catch {
    return $false
  }
}

function Get-SalaryCatNodeRuntime {
  $command = Get-Command node.exe -ErrorAction SilentlyContinue
  if (-not $command) { $command = Get-Command node -ErrorAction SilentlyContinue }
  if (-not $command) { return $null }
  try {
    $version = (& $command.Source -p 'process.versions.node' 2>$null).Trim()
    $major = 0
    if ($LASTEXITCODE -ne 0 -or
        -not [int]::TryParse(($version -split '\.')[0], [ref]$major) -or
        $major -lt 22) {
      return $null
    }
    return [pscustomobject]@{ Path = $command.Source; Version = $version; Major = $major }
  } catch {
    return $null
  }
}

function Install-SalaryCatPortableNode {
  $architecture = if ($env:PROCESSOR_ARCHITEW6432) {
    $env:PROCESSOR_ARCHITEW6432
  } else {
    $env:PROCESSOR_ARCHITECTURE
  }
  switch -Regex ($architecture) {
    '^ARM64$' { $nodeArchitecture = 'arm64'; break }
    '^(AMD64|x64)$' { $nodeArchitecture = 'x64'; break }
    default { throw "Unsupported Windows architecture for Node.js: $architecture" }
  }

  $temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('salary-cat-node-' + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $temporary | Out-Null
  try {
    $checksumsPath = Join-Path $temporary 'SHASUMS256.txt'
    Invoke-SalaryCatDownload -Uri "$NodeDistributionRoot/SHASUMS256.txt" -Destination $checksumsPath
    $pattern = '^(?<hash>[0-9a-fA-F]{64})\s+(?<file>node-v[0-9.]+-win-' + $nodeArchitecture + '\.zip)$'
    $selected = $null
    foreach ($line in Get-Content -LiteralPath $checksumsPath) {
      $match = [regex]::Match($line.Trim(), $pattern)
      if ($match.Success) {
        $selected = [pscustomobject]@{
          Hash = $match.Groups['hash'].Value.ToLowerInvariant()
          File = $match.Groups['file'].Value
        }
        break
      }
    }
    if ($null -eq $selected) { throw "Could not find the official win-$nodeArchitecture Node.js archive." }

    $archivePath = Join-Path $temporary $selected.File
    Invoke-SalaryCatDownload -Uri "$NodeDistributionRoot/$($selected.File)" -Destination $archivePath
    $actualHash = (Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($actualHash -cne $selected.Hash) { throw 'The downloaded Node.js archive failed SHA-256 validation.' }

    $extractRoot = Join-Path $temporary 'extract'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force
    $extracted = @(Get-ChildItem -LiteralPath $extractRoot -Directory)
    if ($extracted.Count -ne 1) { throw 'The Node.js archive had an unexpected directory layout.' }

    $dependenciesRoot = Join-Path $StateRoot 'dependencies'
    New-Item -ItemType Directory -Force -Path $dependenciesRoot | Out-Null
    $nodeRoot = Join-Path $dependenciesRoot 'node'
    if (Test-Path -LiteralPath $nodeRoot) { Remove-Item -LiteralPath $nodeRoot -Recurse -Force }
    Move-Item -LiteralPath $extracted[0].FullName -Destination $nodeRoot
    $nodePath = Join-Path $nodeRoot 'node.exe'
    if (-not (Test-Path -LiteralPath $nodePath -PathType Leaf)) { throw 'Portable Node.js did not contain node.exe.' }

    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    $pathEntries = @($userPath -split ';' | Where-Object { $_ })
    if ($pathEntries -notcontains $nodeRoot) {
      $newUserPath = if ($userPath) { "$nodeRoot;$userPath" } else { $nodeRoot }
      [Environment]::SetEnvironmentVariable('Path', $newUserPath, 'User')
    }
    $env:PATH = "$nodeRoot;$env:PATH"

    $version = (& $nodePath -p 'process.versions.node').Trim()
    if ($LASTEXITCODE -ne 0 -or -not $version.StartsWith('22.')) {
      throw "Portable Node.js validation failed: $version"
    }
    return [pscustomobject]@{ Path = $nodePath; Version = $version; Major = 22 }
  } finally {
    Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue
  }
}

function Ensure-SalaryCatNodeRuntime {
  if (-not $ForcePortableNode) {
    $existing = Get-SalaryCatNodeRuntime
    if ($null -ne $existing) {
      Write-Host "Using Node.js $($existing.Version) at $($existing.Path)"
      return $existing
    }
  }
  $installed = Install-SalaryCatPortableNode
  Write-Host "Installed verified Node.js $($installed.Version) for the current user."
  return $installed
}

if ($DryRun) {
  Write-Host "Would ensure Node.js 22 or newer from: $NodeDistributionRoot"
  Write-Host "Would detect runtime: $RuntimeThemeScript"
  Write-Host "Would detect runtime completion marker: $RuntimeCompletionMarker"
  Write-Host "Would download prerequisite when missing: $UpstreamArchiveUrl"
  Write-Host "Would install theme with: $InstallTheme"
  exit 0
}

$null = Ensure-SalaryCatNodeRuntime
if ($DependenciesOnly) { exit 0 }

$temporary = $null
$themePrepared = $false
try {
  if (-not (Test-SalaryCatDreamSkinRuntime)) {
    & $InstallTheme -NoApply
    $themePrepared = $true
    $temporary = Join-Path ([System.IO.Path]::GetTempPath()) ('salary-cat-runtime-' + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $temporary | Out-Null
    $archivePath = Join-Path $temporary 'Codex-Dream-Skin.zip'
    Invoke-SalaryCatDownload -Uri $UpstreamArchiveUrl -Destination $archivePath
    $extractRoot = Join-Path $temporary 'extract'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force
    $runtimeInstaller = Join-Path $extractRoot 'Codex-Dream-Skin-main\windows\scripts\install-dream-skin.ps1'
    if (-not (Test-Path -LiteralPath $runtimeInstaller -PathType Leaf)) {
      throw 'The official upstream Windows installer is missing.'
    }
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $runtimeInstaller
    if ($LASTEXITCODE -ne 0) {
      throw 'Salary Cat theme files are installed, but the base runtime is incomplete. Close Codex completely, then run Setup.cmd again.'
    }
  }

  if (-not (Test-SalaryCatDreamSkinRuntime)) {
    throw 'The base runtime installer finished without a valid completion marker.'
  }

  if ($NoApply) {
    if (-not $themePrepared) { & $InstallTheme -NoApply }
  } else {
    & $InstallTheme
  }
} finally {
  if ($temporary -and (Test-Path -LiteralPath $temporary)) {
    Remove-Item -LiteralPath $temporary -Recurse -Force -ErrorAction SilentlyContinue
  }
}
