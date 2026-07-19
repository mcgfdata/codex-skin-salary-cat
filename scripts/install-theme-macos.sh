#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
PRESET_ID="preset-yuexinmiao"
SOURCE_DIR="$PROJECT_ROOT/presets/$PRESET_ID"
THEME_ROOT=""
TARGET_DIR=""
BASE_SWITCH=""
APPLY_NOW="true"
STAGE_DIR=""
BACKUP_DIR=""

fail() {
  printf '月薪喵安装器: %s\n' "$*" >&2
  exit 1
}

assert_no_symlink_components() {
  local candidate="$1"
  while [ "$candidate" != "/" ]; do
    [ ! -L "$candidate" ] || fail "安装路径不能包含符号链接: $candidate"
    candidate="$(/usr/bin/dirname "$candidate")"
  done
}

cleanup() {
  [ -z "$STAGE_DIR" ] || /bin/rm -rf "$STAGE_DIR"
  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    if [ ! -e "$TARGET_DIR" ]; then
      /bin/mv "$BACKUP_DIR" "$TARGET_DIR" 2>/dev/null || true
    else
      /bin/rm -rf "$BACKUP_DIR"
    fi
  fi
}
trap cleanup EXIT

while [ "$#" -gt 0 ]; do
  case "$1" in
    --no-apply) APPLY_NOW="false"; shift ;;
    *) fail "未知参数: $1" ;;
  esac
done

[ -n "${HOME:-}" ] || fail "HOME 环境变量为空"
HOME_ROOT="$(cd "$HOME" && pwd -P)" || fail "无法解析 HOME: $HOME"
THEME_ROOT="$HOME_ROOT/Library/Application Support/CodexDreamSkinStudio/themes"
TARGET_DIR="$THEME_ROOT/$PRESET_ID"
BASE_SWITCH="$HOME_ROOT/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"

for required in "$SOURCE_DIR/background.jpg" "$SOURCE_DIR/theme.json"; do
  [ -f "$required" ] && [ ! -L "$required" ] || fail "预设文件缺失或不是普通文件: $required"
done

THEME_ID="$(/usr/bin/plutil -extract id raw -o - "$SOURCE_DIR/theme.json" 2>/dev/null || true)"
THEME_IMAGE="$(/usr/bin/plutil -extract image raw -o - "$SOURCE_DIR/theme.json" 2>/dev/null || true)"
[ "$THEME_ID" = "$PRESET_ID" ] || fail "theme.json 的 id 必须是 $PRESET_ID"
[ "$THEME_IMAGE" = "background.jpg" ] || fail "theme.json 必须引用 background.jpg"

assert_no_symlink_components "$THEME_ROOT"
/bin/mkdir -p "$THEME_ROOT"
[ -d "$THEME_ROOT" ] || fail "无法安全创建主题库: $THEME_ROOT"
assert_no_symlink_components "$TARGET_DIR"

STAGE_DIR="$(/usr/bin/mktemp -d "$THEME_ROOT/.${PRESET_ID}.install.XXXXXX")"
/bin/chmod 700 "$STAGE_DIR"
/bin/cp "$SOURCE_DIR/background.jpg" "$SOURCE_DIR/theme.json" "$STAGE_DIR/"
/bin/chmod 600 "$STAGE_DIR/background.jpg" "$STAGE_DIR/theme.json"

if [ -e "$TARGET_DIR" ]; then
  BACKUP_DIR="$THEME_ROOT/.${PRESET_ID}.backup.$$"
  [ ! -e "$BACKUP_DIR" ] || fail "临时备份目录已存在: $BACKUP_DIR"
  /bin/mv "$TARGET_DIR" "$BACKUP_DIR"
fi

if ! /bin/mv "$STAGE_DIR" "$TARGET_DIR"; then
  fail "无法发布主题，旧版本会自动恢复"
fi
STAGE_DIR=""
if [ -n "$BACKUP_DIR" ]; then
  /bin/rm -rf "$BACKUP_DIR"
  BACKUP_DIR=""
fi

printf '月薪喵主题已安装到：%s\n' "$TARGET_DIR"

if [ "$APPLY_NOW" = "true" ] && [ -x "$BASE_SWITCH" ]; then
  if "$BASE_SWITCH" --id "$PRESET_ID" >/dev/null 2>&1; then
    printf '已自动切换到月薪喵。\n'
    exit 0
  fi
  printf '主题已安装，但未自动切换。打开 Codex Dream Skin 后，在已保存主题里选择月薪喵。\n'
  exit 0
fi

if [ "$APPLY_NOW" = "false" ]; then
  printf '已按要求仅安装主题，没有自动应用。\n'
  exit 0
fi

printf '未检测到可用的 Codex Dream Skin 切换脚本，主题已保存但未应用。\n'
printf '请先安装基础运行时：https://github.com/Fei-Away/Codex-Dream-Skin\n'
