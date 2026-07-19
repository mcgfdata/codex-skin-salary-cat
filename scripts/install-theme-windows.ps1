[CmdletBinding()]
param([switch]$NoApply)

$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$PresetId = 'preset-yuexinmiao'
$SourceDir = Join-Path $ProjectRoot "presets\$PresetId"

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
$TargetDir = Join-Path $ThemeRoot $PresetId
$StageDir = Join-Path $ThemeRoot ('.' + $PresetId + '.install.' + [guid]::NewGuid().ToString('N'))
$BackupDir = Join-Path $ThemeRoot ('.' + $PresetId + '.backup.' + [guid]::NewGuid().ToString('N'))

foreach ($required in @('background.jpg', 'theme.json')) {
  $path = Join-Path $SourceDir $required
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
  $themePath = Join-Path $SourceDir 'theme.json'
  $theme = $utf8.GetString([System.IO.File]::ReadAllBytes($themePath)) | ConvertFrom-Json -ErrorAction Stop
} catch {
  Fail "theme.json 不是有效的 UTF-8 JSON: $($_.Exception.Message)"
}
if ($theme.id -cne $PresetId) {
  Fail "theme.json 的 id 必须是 $PresetId"
}
if ($theme.image -cne 'background.jpg') {
  Fail 'theme.json 必须引用 background.jpg'
}

Assert-NoReparseComponents -Path $ThemeRoot
New-Item -ItemType Directory -Force -Path $ThemeRoot | Out-Null
Assert-NoReparseComponents -Path $ThemeRoot
Assert-NoReparseComponents -Path $TargetDir

try {
  New-Item -ItemType Directory -Path $StageDir | Out-Null
  Copy-Item -LiteralPath (Join-Path $SourceDir 'background.jpg') -Destination $StageDir -Force
  Copy-Item -LiteralPath (Join-Path $SourceDir 'theme.json') -Destination $StageDir -Force

  if (Test-Path -LiteralPath $TargetDir) {
    Move-Item -LiteralPath $TargetDir -Destination $BackupDir
  }
  try {
    Move-Item -LiteralPath $StageDir -Destination $TargetDir
  } catch {
    if ((Test-Path -LiteralPath $BackupDir) -and -not (Test-Path -LiteralPath $TargetDir)) {
      Move-Item -LiteralPath $BackupDir -Destination $TargetDir
    }
    throw
  }
  if (Test-Path -LiteralPath $BackupDir) {
    Remove-Item -LiteralPath $BackupDir -Recurse -Force
  }
} finally {
  Remove-Item -LiteralPath $StageDir -Recurse -Force -ErrorAction SilentlyContinue
  if (Test-Path -LiteralPath $BackupDir) {
    if (-not (Test-Path -LiteralPath $TargetDir)) {
      Move-Item -LiteralPath $BackupDir -Destination $TargetDir -ErrorAction SilentlyContinue
    } else {
      Remove-Item -LiteralPath $BackupDir -Recurse -Force -ErrorAction SilentlyContinue
    }
  }
}

Write-Host "月薪喵主题已安装到：$TargetDir"

if ($NoApply) {
  Write-Host '已按要求仅安装主题，没有自动应用。'
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
    $null = Use-DreamSkinSavedTheme -ThemeDirectory $TargetDir -StateRoot $StateRoot
    Set-DreamSkinPaused -Paused $false -StateRoot $StateRoot | Out-Null
    Write-Host '已自动切换到月薪喵。'
    exit 0
  } catch {
    Write-Warning "主题已安装，但未自动切换：$($_.Exception.Message)"
  }
}

Write-Host '未检测到可用的 Codex Dream Skin 运行时，主题已保存但未应用。'
Write-Host '请先安装基础运行时：https://github.com/Fei-Away/Codex-Dream-Skin'
