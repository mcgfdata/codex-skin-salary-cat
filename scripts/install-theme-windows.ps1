[CmdletBinding()]
param([switch]$NoApply)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DefaultPresetId = 'preset-yuexinmiao-payday'
$PresetIds = @(
  'preset-yuexinmiao-payday',
  'preset-yuexinmiao'
)

function Fail {
  param([Parameter(Mandatory = $true)][string]$Message)
  throw "月薪喵安装器: $Message"
}

function Assert-NoReparseComponents {
  param([Parameter(Mandatory = $true)][string]$Path)
  $current = [System.IO.Path]::GetFullPath($Path)
  $root = [System.IO.Path]::GetPathRoot($current)
  while ($true) {
    if (Test-Path -LiteralPath $current) {
      $item = Get-Item -LiteralPath $current -Force
      if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
        Fail "安装路径不能包含符号链接或目录联接: $current"
      }
    }
    if ($current.TrimEnd('\') -eq $root.TrimEnd('\')) { break }
    $parent = [System.IO.Path]::GetDirectoryName($current)
    if (-not $parent -or $parent -eq $current) { break }
    $current = $parent
  }
}

if (-not $env:LOCALAPPDATA) {
  Fail 'LOCALAPPDATA 环境变量为空。'
}

$StateRoot = Join-Path $env:LOCALAPPDATA 'CodexDreamSkin'
$ThemeRoot = Join-Path $StateRoot 'themes'
$StageRoot = Join-Path $ThemeRoot ('.salary-cat.install.' + [guid]::NewGuid().ToString('N'))
$BackupRoot = Join-Path $ThemeRoot ('.salary-cat.backup.' + [guid]::NewGuid().ToString('N'))
$SourceDirs = @{}
$TargetDirs = @{}

foreach ($presetId in $PresetIds) {
  $sourceDir = Join-Path $ProjectRoot "presets\$presetId"
  $SourceDirs[$presetId] = $sourceDir
  $TargetDirs[$presetId] = Join-Path $ThemeRoot $presetId
  foreach ($required in @('background.jpg', 'theme.json')) {
    $path = Join-Path $sourceDir $required
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
      Fail "找不到预设文件: $path"
    }
    $item = Get-Item -LiteralPath $path -Force
    if (($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) {
      Fail "预设文件不能是符号链接: $path"
    }
  }

  try {
    $utf8 = [System.Text.UTF8Encoding]::new($false, $true)
    $themePath = Join-Path $sourceDir 'theme.json'
    $theme = $utf8.GetString([System.IO.File]::ReadAllBytes($themePath)) | ConvertFrom-Json -ErrorAction Stop
  } catch {
    Fail "theme.json 不是有效的 UTF-8 JSON: $($_.Exception.Message)"
  }
  if ($theme.id -cne $presetId) {
    Fail "theme.json 的 id 必须是 $presetId"
  }
  if ($theme.image -cne 'background.jpg') {
    Fail 'theme.json 必须引用 background.jpg'
  }
}

Assert-NoReparseComponents -Path $ThemeRoot
New-Item -ItemType Directory -Force -Path $ThemeRoot | Out-Null
Assert-NoReparseComponents -Path $ThemeRoot
foreach ($presetId in $PresetIds) {
  Assert-NoReparseComponents -Path $TargetDirs[$presetId]
}

$publishedIds = @()
$backedUpIds = @()
$committed = $false
try {
  New-Item -ItemType Directory -Path $StageRoot | Out-Null
  New-Item -ItemType Directory -Path $BackupRoot | Out-Null
  foreach ($presetId in $PresetIds) {
    $stageDir = Join-Path $StageRoot $presetId
    New-Item -ItemType Directory -Path $stageDir | Out-Null
    Copy-Item -LiteralPath (Join-Path $SourceDirs[$presetId] 'background.jpg') -Destination $stageDir -Force
    Copy-Item -LiteralPath (Join-Path $SourceDirs[$presetId] 'theme.json') -Destination $stageDir -Force
  }

  foreach ($presetId in $PresetIds) {
    $targetDir = $TargetDirs[$presetId]
    if (Test-Path -LiteralPath $targetDir) {
      Move-Item -LiteralPath $targetDir -Destination (Join-Path $BackupRoot $presetId)
      $backedUpIds += $presetId
    }
  }
  foreach ($presetId in $PresetIds) {
    Move-Item -LiteralPath (Join-Path $StageRoot $presetId) -Destination $TargetDirs[$presetId]
    $publishedIds += $presetId
  }
  $committed = $true
} catch {
  foreach ($presetId in $publishedIds) {
    Remove-Item -LiteralPath $TargetDirs[$presetId] -Recurse -Force -ErrorAction SilentlyContinue
  }
  foreach ($presetId in $backedUpIds) {
    $backupDir = Join-Path $BackupRoot $presetId
    if ((Test-Path -LiteralPath $backupDir) -and -not (Test-Path -LiteralPath $TargetDirs[$presetId])) {
      Move-Item -LiteralPath $backupDir -Destination $TargetDirs[$presetId] -ErrorAction SilentlyContinue
    }
  }
  throw
} finally {
  Remove-Item -LiteralPath $StageRoot -Recurse -Force -ErrorAction SilentlyContinue
  if ($committed) {
    Remove-Item -LiteralPath $BackupRoot -Recurse -Force -ErrorAction SilentlyContinue
  }
}

Write-Host "两套月薪喵样式已保存到：$ThemeRoot"

if ($NoApply) {
  Write-Host '已按要求只保存两套样式，没有自动应用。'
  exit 0
}

$EngineScripts = Join-Path $StateRoot 'engine\scripts'
$CommonScript = Join-Path $EngineScripts 'common-windows.ps1'
$ThemeScript = Join-Path $EngineScripts 'theme-windows.ps1'
if ((Test-Path -LiteralPath $CommonScript -PathType Leaf) -and
    (Test-Path -LiteralPath $ThemeScript -PathType Leaf)) {
  try {
    . $CommonScript
    . $ThemeScript
    $null = Use-DreamSkinSavedTheme -ThemeDirectory $TargetDirs[$DefaultPresetId] -StateRoot $StateRoot
    Set-DreamSkinPaused -Paused $false -StateRoot $StateRoot | Out-Null
    Write-Host '已应用默认样式“月薪喵 · 今日营业”；可在“已保存的主题”中切换到“月薪喵”。'
    exit 0
  } catch {
    Write-Warning "两套样式已保存，但未自动应用：$($_.Exception.Message)"
  }
}

Write-Host '未检测到可用的 Codex Dream Skin 运行时，两套样式已保存但未应用。'
Write-Host '基础运行时：https://github.com/Fei-Away/Codex-Dream-Skin'
