#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
UPSTREAM_REPOSITORY="https://github.com/Fei-Away/Codex-Dream-Skin.git"
PRESET_ID="preset-yuexinmiao"
APPLY_NOW="true"
DRY_RUN="false"
TEMPORARY=""

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

if [ "$DRY_RUN" = "true" ]; then
  printf '会检测基础运行时：%s\n' "$BASE_SWITCH"
  printf '缺失时只会从官方仓库克隆：%s\n' "$UPSTREAM_REPOSITORY"
  printf '会安装主题：%s\n' "$PROJECT_ROOT/presets/$PRESET_ID"
  exit 0
fi

if [ ! -x "$BASE_SWITCH" ]; then
  command -v git >/dev/null 2>&1 || fail "首次安装基础运行时需要 git"
  TEMPORARY="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/salary-cat-runtime.XXXXXX")"
  git clone --depth 1 "$UPSTREAM_REPOSITORY" "$TEMPORARY/Codex-Dream-Skin"
  RUNTIME_INSTALLER="$TEMPORARY/Codex-Dream-Skin/macos/scripts/install-dream-skin-macos.sh"
  [ -x "$RUNTIME_INSTALLER" ] || fail "官方基础运行时安装器缺失"
  "$RUNTIME_INSTALLER" --no-launch
fi

[ -x "$BASE_SWITCH" ] || fail "基础运行时安装后仍找不到切换脚本"

if [ "$APPLY_NOW" = "true" ]; then
  "$PROJECT_ROOT/scripts/install-theme-macos.sh"
  exit 0
fi

"$PROJECT_ROOT/scripts/install-theme-macos.sh" --no-apply
"$BASE_SWITCH" --id "$PRESET_ID" --no-apply
printf '月薪喵已安装并设为活动主题；下次从 Codex Dream Skin 启动时生效。\n'
