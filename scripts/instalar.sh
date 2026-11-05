#!/usr/bin/env bash
# ai-stack installer — core + per-tool shims.
# Usage:
#   ./scripts/instalar.sh --all --target /path/to/project
#   ./scripts/instalar.sh --all --copy --target /path/to/project
#   ./scripts/instalar.sh --cursor --claude --antigravity --cline --target .
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET=""
DO_ALL=0
DO_CURSOR=0 DO_CLAUDE=0 DO_GEMINI=0 DO_CLINE=0 DO_ANTI=0
COPY_ONLY=0

while [ $# -gt 0 ]; do
  case "$1" in
    --all) DO_ALL=1 ;;
    --cursor) DO_CURSOR=1 ;;
    --claude) DO_CLAUDE=1 ;;
    --gemini) DO_GEMINI=1 ;;
    --antigravity) DO_ANTI=1 ;;
    --copy|--no-symlink) COPY_ONLY=1 ;;
    --cline) DO_CLINE=1 ;;
    --target) shift; TARGET="${1:-}" ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 1 ;;
  esac
  shift
done

[ "$DO_ALL" = 1 ] && DO_CURSOR=1 DO_CLAUDE=1 DO_GEMINI=1 DO_CLINE=1 DO_ANTI=1
TARGET="${TARGET:-$PWD}"
mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

say() { printf '  %s\n' "$*"; }

backup() {
  [ -e "$1" ] || return 0
  local b="$1.bak.$(date +%Y%m%d%H%M%S)"
  cp -R "$1" "$b"
  say "backup: ${b#$TARGET/}"
}

copy() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  backup "$dst"
  cp -R "$src" "$dst"
  say "instalado: ${dst#$TARGET/}"
}

echo "ai-stack -> $TARGET"

# ---------- core: every tool reads from here ----------
copy "$ROOT/AGENTS.md" "$TARGET/AGENTS.md"
mkdir -p "$TARGET/.agents/skills"
for d in "$ROOT/.agents/skills"/*/; do
  copy "$d" "$TARGET/.agents/skills/$(basename "$d")"
done

# ---------- cursor ----------
if [ "$DO_CURSOR" = 1 ]; then
  echo "cursor"
  for f in "$ROOT/shims/cursor/.cursor/rules"/*.mdc; do
    copy "$f" "$TARGET/.cursor/rules/$(basename "$f")"
  done
  mkdir -p "$TARGET/.cursor/skills"
  for d in "$ROOT/.agents/skills"/*/; do
    ln -sfn "../../.agents/skills/$(basename "$d")" "$TARGET/.cursor/skills/$(basename "$d")"
  done
  say "symlinks: .cursor/skills -> .agents/skills"
fi

# ---------- claude code ----------
if [ "$DO_CLAUDE" = 1 ]; then
  echo "claude"
  copy "$ROOT/shims/claude/CLAUDE.md" "$TARGET/CLAUDE.md"
  for f in "$ROOT/shims/claude/.claude/rules"/*.md; do
    copy "$f" "$TARGET/.claude/rules/$(basename "$f")"
  done
  copy "$ROOT/shims/claude/.claude/hooks/guard.sh" "$TARGET/.claude/hooks/guard.sh"
  chmod +x "$TARGET/.claude/hooks/guard.sh"
  copy "$ROOT/shims/claude/.claude/settings.json" "$TARGET/.claude/settings.json"

  # Claude Code does not read .agents/skills: symlink each skill into the global dir.
  GLOBAL="${CLAUDE_HOME:-$HOME/.claude}/skills"
  mkdir -p "$GLOBAL"
  for d in "$ROOT/.agents/skills"/*/; do
    if [ "$COPY_ONLY" = 1 ]; then
      cp -R "$d" "$GLOBAL/$(basename "$d")"
      say "copiado: ~/.claude/skills/$(basename "$d")"
    else
      ln -sfn "$ROOT/.agents/skills/$(basename "$d")" "$GLOBAL/$(basename "$d")"
      say "~/.claude/skills/$(basename "$d")"
    fi
  done
fi

# ---------- gemini cli (legado) ----------
if [ "$DO_GEMINI" = 1 ]; then
  echo "gemini (legado)"
  copy "$ROOT/shims/gemini/GEMINI.md" "$TARGET/GEMINI.md"
  copy "$ROOT/shims/gemini/gemini-extension.json" "$TARGET/gemini-extension.json"
  for f in "$ROOT/shims/gemini/commands"/*.toml; do
    copy "$f" "$TARGET/commands/$(basename "$f")"
  done
  mkdir -p "$TARGET/.gemini/skills"
  for d in "$ROOT/.agents/skills"/*/; do
    ln -sfn "../../.agents/skills/$(basename "$d")" "$TARGET/.gemini/skills/$(basename "$d")"
  done
  say "symlinks: .gemini/skills -> .agents/skills"
fi

# ---------- antigravity ----------
if [ "$DO_ANTI" = 1 ]; then
  echo "antigravity"
  for f in "$ROOT/shims/antigravity/.agents/rules"/*.md; do
    copy "$f" "$TARGET/.agents/rules/$(basename "$f")"
  done
  copy "$ROOT/shims/antigravity/.agents/mcp_config.json" "$TARGET/.agents/mcp_config.json"
  say "skills: ja lidas de .agents/skills (nada a copiar)"
fi

# ---------- cline ----------
if [ "$DO_CLINE" = 1 ]; then
  echo "cline"
  for f in "$ROOT/shims/cline/.clinerules"/*.md; do
    copy "$f" "$TARGET/.clinerules/$(basename "$f")"
  done
  for f in "$ROOT/shims/cline/.clinerules/workflows"/*.md; do
    copy "$f" "$TARGET/.clinerules/workflows/$(basename "$f")"
  done
  mkdir -p "$TARGET/.cline/skills"
  for d in "$ROOT/.agents/skills"/*/; do
    ln -sfn "../../.agents/skills/$(basename "$d")" "$TARGET/.cline/skills/$(basename "$d")"
  done
  say "symlinks: .cline/skills -> .agents/skills"

  # Cline reads the cross-tool global instructions from ~/.agents/AGENTS.md
  mkdir -p "$HOME/.agents"
  if [ -e "$HOME/.agents/AGENTS.md" ]; then
    say "~/.agents/AGENTS.md ja existe — nao sobrescrito"
  else
    ln -sfn "$TARGET/AGENTS.md" "$HOME/.agents/AGENTS.md"
    say "~/.agents/AGENTS.md -> $TARGET/AGENTS.md"
  fi
fi

echo
echo "pronto. proximo passo:"
echo "  ./scripts/check.sh --target \"$TARGET\""
