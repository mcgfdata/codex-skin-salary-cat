#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
UPSTREAM_ARCHIVE_URL="https://github.com/Fei-Away/Codex-Dream-Skin/archive/refs/heads/main.zip"
DEFAULT_PRESET_ID="preset-yuexinmiao-payday"
PRESET_IDS=(
  "preset-yuexinmiao-payday"
  "preset-yuexinmiao"
)
APPLY_NOW="true"
DRY_RUN="false"
TEMPORARY=""
THEME_PREPARED="false"

fail() {
  printf '月薪喵完整安装器: %s\n' "$*" >&2
  exit 1
}

assert_no_symlink_components() {
  local candidate="$1"
  while [ "$candidate" != "/" ]; do
    [ ! -L "$candidate" ] || fail "路径不能包含符号链接: $candidate"
    candidate="$(/usr/bin/dirname "$candidate")"
  done
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

codex_is_running() {
  [ "$(/usr/bin/osascript -e 'application id "com.openai.codex" is running' 2>/dev/null || true)" = "true" ]
}

confirm_one_time_restart() {
  /usr/bin/osascript <<'APPLESCRIPT' >/dev/null
display dialog "月薪喵已经准备好。Codex 接下来会自动退出并重新打开一次，无需使用终端或执行命令。" buttons {"稍后", "继续设置"} default button "继续设置" cancel button "稍后" with title "月薪喵 Codex 皮肤"
APPLESCRIPT
}

schedule_deferred_setup() {
  local upstream_archive="$1"
  local deferred_root="$HOME_ROOT/Library/Application Support/CodexSalaryCatSetup"
  local pending=""
  local project_copy=""
  local helper=""
  local log_path="$HOME_ROOT/Library/Logs/Codex Salary Cat Setup.log"
  local label="com.terminalgeek.salary-cat-setup.$$.${RANDOM:-0}"
  local preset_id=""

  assert_no_symlink_components "$deferred_root"
  /bin/mkdir -p "$deferred_root" "$HOME_ROOT/Library/Logs"
  /bin/chmod 700 "$deferred_root"
  pending="$(/usr/bin/mktemp -d "$deferred_root/pending.XXXXXX")"
  project_copy="$pending/project"
  /bin/mkdir -p "$project_copy/assets" "$project_copy/scripts"
  /bin/cp "$PROJECT_ROOT/assets/salary-cat-extension.css" "$project_copy/assets/"
  /bin/cp "$PROJECT_ROOT/scripts/apply-runtime-extension-macos.sh" \
    "$PROJECT_ROOT/scripts/install-theme-macos.sh" "$project_copy/scripts/"
  for preset_id in "${PRESET_IDS[@]}"; do
    /bin/mkdir -p "$project_copy/presets/$preset_id"
    /bin/cp "$PROJECT_ROOT/presets/$preset_id/background.jpg" \
      "$PROJECT_ROOT/presets/$preset_id/theme.json" "$project_copy/presets/$preset_id/"
  done
  /bin/cp "$PROJECT_ROOT/scripts/finish-setup-macos.sh" "$pending/"
  /bin/cp "$upstream_archive" "$pending/Codex-Dream-Skin.zip"
  /bin/chmod 700 "$pending" "$project_copy" "$project_copy/assets" "$project_copy/scripts" \
    "$project_copy/scripts/apply-runtime-extension-macos.sh" \
    "$project_copy/scripts/install-theme-macos.sh" "$pending/finish-setup-macos.sh"
  /bin/chmod 600 "$project_copy/assets/salary-cat-extension.css"
  /bin/chmod 600 "$pending/Codex-Dream-Skin.zip"
  for preset_id in "${PRESET_IDS[@]}"; do
    /bin/chmod 700 "$project_copy/presets/$preset_id"
    /bin/chmod 600 "$project_copy/presets/$preset_id/background.jpg" \
      "$project_copy/presets/$preset_id/theme.json"
  done

  if ! confirm_one_time_restart; then
    /bin/rm -rf "$pending"
    printf '已保留月薪喵主题文件，本次没有重启 Codex。\n'
    return 1
  fi

  helper="$pending/finish-setup-macos.sh"
  /bin/launchctl submit -l "$label" -o "$log_path" -e "$log_path" -- \
    /usr/bin/env "HOME=$HOME_ROOT" /bin/bash "$helper" "$pending" "$label"
  printf '月薪喵已准备完成；Codex 将自动重启一次并完成应用，无需执行任何命令。\n'
}

if [ "$DRY_RUN" = "true" ]; then
  printf '会检测基础运行时：%s\n' "$BASE_SWITCH"
  printf '会检测安装完成标记：%s\n' "$BASE_COMPLETION_MARKER"
  printf '缺失时会从官方仓库下载：%s\n' "$UPSTREAM_ARCHIVE_URL"
  printf '安装不需要 Git、Python 或额外 Node.js。\n'
  printf '首次设置会在确认后自动重启 Codex 一次，无需退出后执行命令。\n'
  printf '会准备两套样式：%s、%s\n' "${PRESET_IDS[0]}" "${PRESET_IDS[1]}"
  "$PROJECT_ROOT/scripts/finish-setup-macos.sh" --dry-run
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

  if codex_is_running; then
    if [ "$APPLY_NOW" = "true" ]; then
      if schedule_deferred_setup "$TEMPORARY/Codex-Dream-Skin.zip"; then
        exit 0
      fi
      exit 0
    fi
    printf '月薪喵主题已准备好；本次按要求不重启 Codex。\n'
    exit 0
  fi

  if ! /bin/bash "$RUNTIME_INSTALLER" --no-launch; then
    fail "官方基础运行时设置未完成"
  fi
fi

base_runtime_is_ready || fail "基础运行时安装后仍缺少脚本或完成标记"

if [ "$APPLY_NOW" = "true" ]; then
  "$PROJECT_ROOT/scripts/install-theme-macos.sh"
  exit 0
fi

[ "$THEME_PREPARED" = "true" ] || "$PROJECT_ROOT/scripts/install-theme-macos.sh" --no-apply
"$BASE_SWITCH" --id "$DEFAULT_PRESET_ID" --no-apply
printf '两套月薪喵样式已保存，默认样式“月薪喵 · 今日营业”已设为活动主题；下次从 Codex Dream Skin 启动时生效。\n'
