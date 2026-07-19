#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
DEFAULT_PRESET_ID="preset-yuexinmiao"
PRESET_IDS=(
  "preset-yuexinmiao"
  "preset-yuexinmiao-payday"
)
THEME_ROOT=""
BASE_SWITCH=""
APPLY_NOW="true"
STAGE_ROOT=""
BACKUP_ROOT=""
PUBLISHED_IDS=()
COMMITTED="false"

fail() {
  printf '月薪喵设置器: %s\n' "$*" >&2
  exit 1
}

assert_no_symlink_components() {
  local candidate="$1"
  while [ "$candidate" != "/" ]; do
    [ ! -L "$candidate" ] || fail "设置路径不能包含符号链接: $candidate"
    candidate="$(/usr/bin/dirname "$candidate")"
  done
}

cleanup() {
  local preset_id=""
  local target_dir=""

  [ -z "$STAGE_ROOT" ] || /bin/rm -rf "$STAGE_ROOT"
  if [ -n "$BACKUP_ROOT" ] && [ -d "$BACKUP_ROOT" ]; then
    if [ "$COMMITTED" = "true" ]; then
      /bin/rm -rf "$BACKUP_ROOT"
      return
    fi

    for preset_id in "${PUBLISHED_IDS[@]}"; do
      target_dir="$THEME_ROOT/$preset_id"
      [ ! -e "$target_dir" ] || /bin/rm -rf "$target_dir"
    done
    for preset_id in "${PRESET_IDS[@]}"; do
      if [ -e "$BACKUP_ROOT/$preset_id" ]; then
        /bin/mv "$BACKUP_ROOT/$preset_id" "$THEME_ROOT/$preset_id" 2>/dev/null || true
      fi
    done
    /bin/rm -rf "$BACKUP_ROOT"
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
BASE_SWITCH="$HOME_ROOT/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"

assert_no_symlink_components "$THEME_ROOT"
/bin/mkdir -p "$THEME_ROOT"
[ -d "$THEME_ROOT" ] || fail "无法安全创建主题库: $THEME_ROOT"
assert_no_symlink_components "$THEME_ROOT"

STAGE_ROOT="$(/usr/bin/mktemp -d "$THEME_ROOT/.salary-cat.install.XXXXXX")"
BACKUP_ROOT="$(/usr/bin/mktemp -d "$THEME_ROOT/.salary-cat.backup.XXXXXX")"
/bin/chmod 700 "$STAGE_ROOT" "$BACKUP_ROOT"

for preset_id in "${PRESET_IDS[@]}"; do
  source_dir="$PROJECT_ROOT/presets/$preset_id"
  target_dir="$THEME_ROOT/$preset_id"
  for required in "$source_dir/background.jpg" "$source_dir/theme.json"; do
    [ -f "$required" ] && [ ! -L "$required" ] || fail "预设文件缺失或不是普通文件: $required"
  done

  theme_id="$(/usr/bin/plutil -extract id raw -o - "$source_dir/theme.json" 2>/dev/null || true)"
  theme_image="$(/usr/bin/plutil -extract image raw -o - "$source_dir/theme.json" 2>/dev/null || true)"
  [ "$theme_id" = "$preset_id" ] || fail "theme.json 的 id 必须是 $preset_id"
  [ "$theme_image" = "background.jpg" ] || fail "theme.json 必须引用 background.jpg"
  assert_no_symlink_components "$target_dir"

  /bin/mkdir "$STAGE_ROOT/$preset_id"
  /bin/cp "$source_dir/background.jpg" "$source_dir/theme.json" "$STAGE_ROOT/$preset_id/"
  /bin/chmod 600 "$STAGE_ROOT/$preset_id/background.jpg" "$STAGE_ROOT/$preset_id/theme.json"
done

# Publish the pair as one transaction while leaving all unrelated themes alone.
for preset_id in "${PRESET_IDS[@]}"; do
  target_dir="$THEME_ROOT/$preset_id"
  if [ -e "$target_dir" ]; then
    /bin/mv "$target_dir" "$BACKUP_ROOT/$preset_id"
  fi
done
for preset_id in "${PRESET_IDS[@]}"; do
  target_dir="$THEME_ROOT/$preset_id"
  /bin/mv "$STAGE_ROOT/$preset_id" "$target_dir" || fail "无法发布 $preset_id，旧版本会自动恢复"
  PUBLISHED_IDS+=("$preset_id")
done

COMMITTED="true"
/bin/rm -rf "$STAGE_ROOT" "$BACKUP_ROOT"
STAGE_ROOT=""
BACKUP_ROOT=""

printf '两套月薪喵样式已保存到：%s\n' "$THEME_ROOT"

if [ "$APPLY_NOW" = "true" ] && [ -x "$BASE_SWITCH" ]; then
  if "$BASE_SWITCH" --id "$DEFAULT_PRESET_ID" >/dev/null 2>&1; then
    printf '已应用默认样式“月薪喵”；可在“已保存的主题”中切换到“月薪喵 · 今日营业”。\n'
    exit 0
  fi
  printf '两套样式已保存但未自动应用，可在 Codex Dream Skin 的“已保存的主题”中选择。\n'
  exit 0
fi

if [ "$APPLY_NOW" = "false" ]; then
  printf '已按要求只保存两套样式，没有自动应用。\n'
  exit 0
fi

printf '未检测到可用的 Codex Dream Skin 切换入口，两套样式已保存但未应用。\n'
printf '基础运行时：https://github.com/Fei-Away/Codex-Dream-Skin\n'
