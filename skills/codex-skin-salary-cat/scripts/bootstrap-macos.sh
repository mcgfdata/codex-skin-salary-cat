#!/bin/bash

set -euo pipefail

ARCHIVE_URL="https://github.com/mcgfdata/codex-skin-salary-cat/archive/refs/heads/main.zip"
TEMPORARY=""

cleanup() {
  [ -z "$TEMPORARY" ] || /bin/rm -rf "$TEMPORARY"
}
trap cleanup EXIT

if [ "${1:-}" = "--dry-run" ]; then
  printf '会从 GitHub 下载月薪喵安装仓库：%s\n' "$ARCHIVE_URL"
  printf '下载后会运行 scripts/setup-skin-macos.sh。\n'
  exit 0
fi

TEMPORARY="$(/usr/bin/mktemp -d "${TMPDIR:-/tmp}/salary-cat-skill.XXXXXX")"
/usr/bin/curl --fail --location --silent --show-error --retry 3 \
  --proto '=https' --tlsv1.2 \
  --output "$TEMPORARY/salary-cat.zip" "$ARCHIVE_URL"
/usr/bin/ditto -x -k "$TEMPORARY/salary-cat.zip" "$TEMPORARY"
SETUP="$TEMPORARY/codex-skin-salary-cat-main/scripts/setup-skin-macos.sh"
[ -f "$SETUP" ] || { printf '月薪喵完整安装器缺失。\n' >&2; exit 1; }
/bin/bash "$SETUP" "$@"
