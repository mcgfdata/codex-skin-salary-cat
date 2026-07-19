#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
UPSTREAM_ARCHIVE_URL="https://github.com/Fei-Away/Codex-Dream-Skin/archive/refs/heads/main.zip"
PRESET_ID="preset-yuexinmiao"
APPLY_NOW="true"
DRY_RUN="false"
TEMPORARY=""
THEME_PREPARED="false"

fail() {
  printf '月薪喵完整安装器: %s\n' "$*" >&2
  exit 1
}

cleanup() {
  [ -z "$TEMPORARY" ] || /bin/rm -rf "$TEMPORARY"
}
trap cleanup EXIT

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-apply) APPLY_NOW="false"; shift ;;
    --dry-run) DRY_RUN="true"; shift ;;
    *) fail "未知参数: $1" ;;
  esac
done

[ -n "${HOME:-}" ] || fail "HOME 环境变量为空"
HOME_ROOT="$(cd "$HOME" && pwd -P)" || fail "无法解析 HOME"
BASE_SWITCH="$HOME_ROOT/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"
BASE_COMPLETION_MARKER="$HOME_ROOT/Library/Application Support/CodexDreamSkinStudio/theme-backup.json"

base_runtime_is_ready() {
  [ -x "$BASE_SWITCH" ] || return 1
  [ -f "$BASE_COMPLETION_MARKER" ] && [ ! -L "$BASE_COMPLETION_MARKER" ] || return 1
  [ "$(/usr/bin/plutil -extract schemaVersion raw -o - "$BASE_COMPLETION_MARKER" 2>/dev/null || true)" = "1" ] || return 1
  [ "$(/usr/bin/plutil -extract platform raw -o - "$BASE_COMPLETION_MARKER" 2>/dev/null || true)" = "darwin" ] || return 1
  [ "$(/usr/bin/plutil -extract configPath raw -o - "$BASE_COMPLETION_MARKER" 2>/dev/null || true)" = "$HOME_ROOT/.codex/config.toml" ]
}

if [ "$DRY_RUN" = "true" ]; then
  printf '会检测基础运行时：%s\n' "$BASE_SWITCH"
  printf '会检测安装完成标记：%s\n' "$BASE_COMPLETION_MARKER"
  printf '缺失时会从官方仓库下载：%s\n' "$UPSTREAM_ARCHIVE_URL"
  printf '安装不需要 Git、Python 或额外 Node.js。\n'
  printf '会安装主题：%s\n' "$PROJECT_ROOT/presets/$PRESET_ID"
  exit 0
fi

if ! base_runtime_is_ready; then
  "$PROJECT_ROOT/scripts/install-theme-macos.sh" --no-apply
  THEME_PREPARED="true"
  TEMPORARY="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/salary-cat-runtime.XXXXXX")"
  /usr/bin/curl --fail --location --silent --show-error --retry 3 \
    --proto '=https' --tlsv1.2 \
    --output "$TEMPORARY/Codex-Dream-Skin.zip" "$UPSTREAM_ARCHIVE_URL"
  /usr/bin/ditto -x -k "$TEMPORARY/Codex-Dream-Skin.zip" "$TEMPORARY"
  RUNTIME_INSTALLER="$TEMPORARY/Codex-Dream-Skin-main/macos/scripts/install-dream-skin-macos.sh"
  [ -f "$RUNTIME_INSTALLER" ] || fail "官方基础运行时安装器缺失"
  if ! /bin/bash "$RUNTIME_INSTALLER" --no-launch; then
    fail "主题文件已安装，但基础运行时尚未完成。请完全退出 Codex 后重新运行 Setup.command"
  fi
fi

base_runtime_is_ready || fail "基础运行时安装后仍缺少脚本或完成标记"

if [ "$APPLY_NOW" = "true" ]; then
  "$PROJECT_ROOT/scripts/install-theme-macos.sh"
  exit 0
fi

[ "$THEME_PREPARED" = "true" ] || "$PROJECT_ROOT/scripts/install-theme-macos.sh" --no-apply
"$BASE_SWITCH" --id "$PRESET_ID" --no-apply
printf '月薪喵已安装并设为活动主题；下次从 Codex Dream Skin 启动时生效。\n'
