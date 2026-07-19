#!/bin/bash

set -Eeuo pipefail

DRY_RUN="false"
VALIDATE_ONLY="false"
PENDING_ROOT=""
SETUP_STATE_ROOT=""
PROJECT_COPY=""
CODEX_BUNDLE=""
JOB_LABEL=""
DEFAULT_PRESET_ID="preset-yuexinmiao"
PRESET_IDS=(
  "preset-yuexinmiao"
  "preset-yuexinmiao-payday"
)

notify() {
  /usr/bin/osascript -e "display notification \"$1\" with title \"月薪喵 Codex 皮肤\"" \
    >/dev/null 2>&1 || true
}

fail() {
  printf '月薪喵后台设置: %s\n' "$*" >&2
  exit 1
}

assert_no_symlink_components() {
  local candidate="$1"
  while [ "$candidate" != "/" ]; do
    [ ! -L "$candidate" ] || fail "路径不能包含符号链接: $candidate"
    candidate="$(/usr/bin/dirname "$candidate")"
  done
}

finish() {
  local code="$1"
  trap - EXIT
  if [ "$code" -eq 0 ]; then
    notify "设置完成，Codex 已使用月薪喵重新打开。"
    /bin/rm -rf "$PENDING_ROOT" 2>/dev/null || true
  else
    notify "设置未完成，Codex 将以原外观重新打开。"
    /usr/bin/open -b com.openai.codex >/dev/null 2>&1 || true
  fi

  [ -z "$JOB_LABEL" ] || /bin/launchctl remove "$JOB_LABEL" >/dev/null 2>&1 || true
  exit "$code"
}

if [ "${1:-}" = "--dry-run" ]; then
  DRY_RUN="true"
  shift
elif [ "${1:-}" = "--validate-pending" ]; then
  VALIDATE_ONLY="true"
  shift
fi
PENDING_ROOT="${1:-}"
JOB_LABEL="${2:-}"

if [ "$DRY_RUN" = "true" ]; then
  printf '会等待当前 Codex 安全退出。\n'
  printf '会使用官方 Codex Dream Skin 完成基础配置和重启。\n'
  printf '会保存两套月薪喵样式、应用默认样式，并在成功后清理一次性文件。\n'
  exit 0
fi

[ -n "${HOME:-}" ] || fail "HOME 环境变量为空"
[ -n "$PENDING_ROOT" ] || fail "缺少一次性设置目录"
case "$PENDING_ROOT" in /*) ;; *) fail "一次性设置目录必须是绝对路径" ;; esac
case "$JOB_LABEL" in
  ''|com.terminalgeek.salary-cat-setup.*) ;;
  *) fail "后台任务标识不合法" ;;
esac
SETUP_STATE_ROOT="$HOME/Library/Application Support/CodexSalaryCatSetup"
assert_no_symlink_components "$SETUP_STATE_ROOT"
assert_no_symlink_components "$PENDING_ROOT"
[ -d "$SETUP_STATE_ROOT" ] && [ ! -L "$SETUP_STATE_ROOT" ] || fail "设置状态目录不安全"
[ -d "$PENDING_ROOT" ] && [ ! -L "$PENDING_ROOT" ] || fail "一次性设置目录不安全"

state_real="$(cd "$SETUP_STATE_ROOT" && pwd -P)"
pending_real="$(cd "$PENDING_ROOT" && pwd -P)"
case "$pending_real/" in
  "$state_real"/pending.*) ;;
  *) fail "一次性设置目录超出受管范围" ;;
esac
PENDING_ROOT="$pending_real"
PROJECT_COPY="$PENDING_ROOT/project"
UPSTREAM_ARCHIVE="$PENDING_ROOT/Codex-Dream-Skin.zip"
UPSTREAM_EXTRACT="$PENDING_ROOT/upstream"
[ "$VALIDATE_ONLY" = "true" ] || trap 'finish "$?"' EXIT

for required in "$PROJECT_COPY/scripts/install-theme-macos.sh" "$UPSTREAM_ARCHIVE"; do
  [ -f "$required" ] && [ ! -L "$required" ] || fail "一次性设置文件缺失或不安全: $required"
done
for preset_id in "${PRESET_IDS[@]}"; do
  for required in \
    "$PROJECT_COPY/presets/$preset_id/background.jpg" \
    "$PROJECT_COPY/presets/$preset_id/theme.json"; do
    [ -f "$required" ] && [ ! -L "$required" ] || fail "一次性设置文件缺失或不安全: $required"
  done
done
if [ "$VALIDATE_ONLY" = "true" ]; then
  printf '一次性后台设置材料校验通过。\n'
  exit 0
fi

# Give the active task time to report that the one-time restart is beginning.
/bin/sleep 8
/bin/mkdir -p "$UPSTREAM_EXTRACT"
/usr/bin/ditto -x -k "$UPSTREAM_ARCHIVE" "$UPSTREAM_EXTRACT"
UPSTREAM_MACOS="$UPSTREAM_EXTRACT/Codex-Dream-Skin-main/macos"
COMMON="$UPSTREAM_MACOS/scripts/common-macos.sh"
RUNTIME_INSTALLER="$UPSTREAM_MACOS/scripts/install-dream-skin-macos.sh"
[ -f "$COMMON" ] && [ -f "$RUNTIME_INSTALLER" ] || fail "官方基础运行时文件缺失"

# Reuse upstream identity checks and restart behavior instead of managing Codex directly.
. "$COMMON"
discover_codex_app
notify "Codex 将自动重启一次以完成月薪喵设置。"
stop_codex true
/bin/bash "$RUNTIME_INSTALLER" --no-launch
/bin/bash "$PROJECT_COPY/scripts/install-theme-macos.sh" --no-apply
BASE_SWITCH="$HOME/.codex/codex-dream-skin-studio/scripts/switch-theme-macos.sh"
[ -x "$BASE_SWITCH" ] || fail "官方主题切换入口缺失"
"$BASE_SWITCH" --id "$DEFAULT_PRESET_ID"

MARKER="$HOME/Library/Application Support/CodexDreamSkinStudio/theme-backup.json"
ACTIVE_THEME_JSON="$HOME/Library/Application Support/CodexDreamSkinStudio/theme/theme.json"
[ "$(/usr/bin/plutil -extract schemaVersion raw -o - "$MARKER" 2>/dev/null || true)" = "1" ] \
  || fail "基础运行时完成标记缺失或无效"
[ "$(/usr/bin/plutil -extract platform raw -o - "$MARKER" 2>/dev/null || true)" = "darwin" ] \
  || fail "基础运行时平台标记无效"
for preset_id in "${PRESET_IDS[@]}"; do
  theme_json="$HOME/Library/Application Support/CodexDreamSkinStudio/themes/$preset_id/theme.json"
  [ "$(/usr/bin/plutil -extract id raw -o - "$theme_json" 2>/dev/null || true)" = "$preset_id" ] \
    || fail "月薪喵样式校验失败: $preset_id"
done
[ "$(/usr/bin/plutil -extract id raw -o - "$ACTIVE_THEME_JSON" 2>/dev/null || true)" = "$DEFAULT_PRESET_ID" ] \
  || fail "月薪喵活动主题校验失败"
