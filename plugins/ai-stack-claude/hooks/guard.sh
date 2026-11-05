#!/usr/bin/env bash
# PostToolUse guard: lint + fast test after Claude Code writes or edits a file.
# Exit 2 blocks the tool result and hands stderr back to Claude, which is the point:
# a red tree must stop the next edit, not be discovered at the end.
set -uo pipefail

payload="$(cat)"
file="$(printf '%s' "$payload" | sed -n 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')"

[ -z "${file:-}" ] && exit 0
case "$file" in
  *.md|*.txt|*.json|*.yaml|*.yml|*.lock|*/.git/*) exit 0 ;;
esac

cd "$(dirname "$file")" 2>/dev/null || exit 0
root="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
cd "$root" || exit 0

[ -f Makefile ] || exit 0

if ! out="$(make --no-print-directory lint 2>&1)"; then
  printf 'guard: lint falhou em %s\n%s\n' "$file" "$(printf '%s' "$out" | tail -n 25)" >&2
  exit 2
fi

exit 0
