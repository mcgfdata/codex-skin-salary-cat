#!/bin/bash

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd -P)"
EXTENSION_CSS="$PROJECT_ROOT/assets/salary-cat-extension.css"
RUNTIME_CSS="$HOME/.codex/codex-dream-skin-studio/assets/dream-skin.css"
START_MARKER="/* SALARY_CAT_EXTENSION_START */"
END_MARKER="/* SALARY_CAT_EXTENSION_END */"

fail() {
  printf '月薪喵样式扩展: %s\n' "$*" >&2
  exit 1
}

assert_no_symlink_components() {
  local candidate="$1"
  while [ "$candidate" != "/" ]; do
    [ ! -L "$candidate" ] || fail "路径不能包含符号链接: $candidate"
    candidate="$(/usr/bin/dirname "$candidate")"
  done
}

[ -f "$EXTENSION_CSS" ] && [ ! -L "$EXTENSION_CSS" ] || fail "扩展样式文件缺失或不安全: $EXTENSION_CSS"
[ -f "$RUNTIME_CSS" ] && [ ! -L "$RUNTIME_CSS" ] || fail "Dream Skin 运行时样式文件缺失: $RUNTIME_CSS"
assert_no_symlink_components "$RUNTIME_CSS"

temporary="$(/usr/bin/mktemp "${TMPDIR:-/tmp}/salary-cat-css.XXXXXX")"
cleanup() {
  /bin/rm -f "$temporary"
}
trap cleanup EXIT

/usr/bin/awk -v start="$START_MARKER" -v end="$END_MARKER" '
  $0 == start { skipping = 1; next }
  $0 == end { skipping = 0; next }
  skipping == 1 { next }
  { lines[++count] = $0 }
  END {
    while (count > 0 && lines[count] == "") count -= 1
    for (i = 1; i <= count; i += 1) print lines[i]
  }
' "$RUNTIME_CSS" > "$temporary"

{
  /usr/bin/printf '%s\n' "$START_MARKER"
  /bin/cat "$EXTENSION_CSS"
  /usr/bin/printf '%s\n' "$END_MARKER"
} >> "$temporary"

if /usr/bin/cmp -s "$temporary" "$RUNTIME_CSS"; then
  printf '月薪喵样式扩展已是最新。\n'
  exit 0
fi

/bin/chmod 600 "$temporary"
/bin/mv "$temporary" "$RUNTIME_CSS"
temporary=""
printf '月薪喵样式扩展已应用到 Dream Skin 运行时。\n'
