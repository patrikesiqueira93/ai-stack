#!/usr/bin/env bash
# ai-stack check — proves each tool can see its context, its rules and its skills.
# Usage: ./scripts/check.sh --target /path/to/project [--cursor --claude --antigravity --cline]
# Exit 0 = every enabled tool passed. Exit 1 = at least one FAIL.
set -uo pipefail

TARGET=""
DO_ALL=0
DO_CURSOR=0 DO_CLAUDE=0 DO_GEMINI=0 DO_CLINE=0 DO_ANTI=0
FAIL=0 PASS=0

while [ $# -gt 0 ]; do
  case "$1" in
    --all) DO_ALL=1 ;;
    --cursor) DO_CURSOR=1 ;;
    --claude) DO_CLAUDE=1 ;;
    --antigravity) DO_ANTI=1 ;;
    --gemini) DO_GEMINI=1 ;;
    --cline) DO_CLINE=1 ;;
    --target) shift; TARGET="${1:-}" ;;
    -h|--help) sed -n '2,5p' "$0"; exit 0 ;;
    *) echo "argumento desconhecido: $1" >&2; exit 1 ;;
  esac
  shift
done

[ "$DO_ALL" = 1 ] && DO_CURSOR=1 DO_CLAUDE=1 DO_ANTI=1 DO_CLINE=1
[ "$DO_CURSOR$DO_CLAUDE$DO_ANTI$DO_CLINE$DO_GEMINI" = "00000" ] && DO_CURSOR=1 DO_CLAUDE=1 DO_ANTI=1 DO_CLINE=1
TARGET="${TARGET:-$PWD}"
TARGET="$(cd "$TARGET" 2>/dev/null && pwd)" || { echo "target inexistente: $TARGET" >&2; exit 1; }

ok()   { PASS=$((PASS+1)); printf '  ok    %s\n' "$*"; }
bad()  { FAIL=$((FAIL+1)); printf '  FAIL  %s\n' "$*"; }
sect() { printf '\n[%s]\n' "$*"; }

need_file() { [ -s "$TARGET/$1" ] && ok "$1" || bad "$1 ausente ou vazio"; }

count_skills() {
  local n=0 d
  for d in "$1"/*/; do
    [ -f "$d/SKILL.md" ] || continue
    grep -q '^name:' "$d/SKILL.md" 2>/dev/null || continue
    grep -q '^description:' "$d/SKILL.md" 2>/dev/null || continue
    n=$((n+1))
  done
  printf '%s' "$n"
}

echo "check -> $TARGET"

# ---------- core ----------
sect "core"
need_file "AGENTS.md"
if [ -f "$TARGET/AGENTS.md" ]; then
  lines=$(wc -l < "$TARGET/AGENTS.md" | tr -d ' ')
  [ "$lines" -le 200 ] && ok "AGENTS.md tem $lines linhas (limite 200)" || bad "AGENTS.md com $lines linhas — acima de 200 o modelo para de seguir"
  grep -qi 'definition of done' "$TARGET/AGENTS.md" && ok "secao definition of done" || bad "sem definition of done"
  grep -qi 'prohibited' "$TARGET/AGENTS.md" && ok "secao prohibitions" || bad "sem secao de proibicoes"
fi
n=$(count_skills "$TARGET/.agents/skills")
[ "$n" -ge 6 ] && ok "$n skills no nucleo (.agents/skills)" || bad "so $n skills no nucleo — esperado 6"
for d in "$TARGET/.agents/skills"/*/; do
  [ -d "$d" ] || continue
  name=$(basename "$d")
  if [ -d "$d/scripts" ]; then
    for f in "$d"/scripts/*; do
      [ -f "$f" ] || continue
      case "$f" in
        *.sh) bash -n "$f" 2>/dev/null && ok "skill $name: $(basename "$f") sintaxe" || bad "skill $name: $(basename "$f") erro de sintaxe" ;;
        *.py) python3 -m py_compile "$f" 2>/dev/null && ok "skill $name: $(basename "$f") compila" || bad "skill $name: $(basename "$f") nao compila" ;;
      esac
    done
  fi
  grep -q "^name: $name$" "$d/SKILL.md" 2>/dev/null && ok "skill $name: name bate com o diretorio" || bad "skill $name: frontmatter name nao bate"
  dlen=$(sed -n 's/^description: //p' "$d/SKILL.md" 2>/dev/null | head -1 | wc -c | tr -d ' ')
  [ "$dlen" -ge 60 ] && ok "skill $name: description com $dlen chars" || bad "skill $name: description curta ($dlen) — e o gatilho de descoberta"
done

# ---------- cursor ----------
if [ "$DO_CURSOR" = 1 ]; then
  sect "cursor"
  for name in ui testes proibido; do
    f="$TARGET/.cursor/rules/$name.mdc"
    [ -f "$f" ] || { bad "regra $name.mdc ausente"; continue; }
    head -1 "$f" | grep -q '^---$' && ok "$name.mdc: frontmatter" || bad "$name.mdc: sem frontmatter"
    grep -qE '^(alwaysApply|globs|description):' "$f" && ok "$name.mdc: tipo declarado" || bad "$name.mdc: sem alwaysApply/globs/description"
  done
  always=$(grep -l 'alwaysApply: true' "$TARGET/.cursor/rules"/*.mdc 2>/dev/null | wc -l | tr -d ' ')
  [ "$always" -le 1 ] && ok "$always regra(s) alwaysApply (<=1 e o alvo)" || bad "$always regras alwaysApply — contexto sempre-ativo demais"
  n=$(count_skills "$TARGET/.cursor/skills")
  if [ "$n" -ge 6 ]; then
    ok "$n skills visiveis em .cursor/skills"
    for d in "$TARGET/.cursor/skills"/*; do
      [ -L "$d" ] || continue
      [ -e "$d" ] && ok "symlink $(basename "$d") resolve" || bad "symlink $(basename "$d") quebrado"
    done
  else
    n2=$(count_skills "$TARGET/.agents/skills")
    [ "$n2" -ge 6 ] && ok "$n2 skills lidas nativamente de .agents/skills (sem symlink)" || bad "skills nao encontradas"
  fi
fi

# ---------- claude code ----------
if [ "$DO_CLAUDE" = 1 ]; then
  sect "claude code"
  need_file "CLAUDE.md"
  grep -q '^@AGENTS.md' "$TARGET/CLAUDE.md" 2>/dev/null && ok "CLAUDE.md importa AGENTS.md" || bad "CLAUDE.md nao importa AGENTS.md"
  for name in api harness; do
    f="$TARGET/.claude/rules/$name.md"
    [ -f "$f" ] || { bad "regra $name.md ausente"; continue; }
    grep -q '^paths:' "$f" && ok "$name.md: paths declarados" || bad "$name.md: sem paths"
  done
  [ -x "$TARGET/.claude/hooks/guard.sh" ] && ok "guard.sh executavel" || bad "guard.sh nao executavel"
  if [ -f "$TARGET/.claude/settings.json" ]; then
    python3 -c "import json;json.load(open('$TARGET/.claude/settings.json'))" 2>/dev/null && ok "settings.json e JSON valido" || bad "settings.json invalido"
    grep -q 'PostToolUse' "$TARGET/.claude/settings.json" && ok "hook PostToolUse registrado" || bad "hook PostToolUse ausente"
  else
    bad "settings.json ausente"
  fi
  GLOBAL="${CLAUDE_HOME:-$HOME/.claude}/skills"
  n=0
  for d in "$GLOBAL"/*/; do [ -e "$d/SKILL.md" ] && n=$((n+1)); done
  [ "$n" -ge 6 ] && ok "$n skills no global do Claude ($GLOBAL)" || bad "so $n skills em $GLOBAL — rode instalar.sh --claude"
fi

# ---------- antigravity ----------
if [ "$DO_ANTI" = 1 ]; then
  sect "antigravity"
  n=$(ls "$TARGET/.agents/rules"/*.md 2>/dev/null | wc -l | tr -d ' ')
  [ "$n" -ge 1 ] && ok "$n regra(s) em .agents/rules" || bad ".agents/rules vazio"
  for f in "$TARGET/.agents/rules"/*.md; do
    [ -f "$f" ] || continue
    grep -qE '^trigger: (always_on|model_decision|glob|manual)$' "$f" && ok "$(basename "$f") com trigger valido" || bad "$(basename "$f") sem trigger valido (descartado em silencio)"
  done
  [ -s "$TARGET/.agents/mcp_config.json" ] && ok "mcp_config.json" || bad "mcp_config.json ausente"
  n2=$(count_skills "$TARGET/.agents/skills")
  [ "$n2" -ge 6 ] && ok "$n2 skills em .agents/skills" || bad "skills ausentes"
fi

# ---------- cline ----------
if [ "$DO_CLINE" = 1 ]; then
  sect "cline"
  for name in data model; do
    [ -s "$TARGET/.clinerules/$name.md" ] && ok ".clinerules/$name.md" || bad ".clinerules/$name.md ausente"
  done
  for name in train-transformer profile-dataset; do
    f="$TARGET/.clinerules/workflows/$name.md"
    [ -f "$f" ] || { bad "workflow $name ausente"; continue; }
    grep -qE '^## ' "$f" && ok "workflow $name: passos" || bad "workflow $name: sem passos"
  done
  n=$(count_skills "$TARGET/.cline/skills")
  [ "$n" -ge 6 ] && ok "$n skills em .cline/skills" || bad "so $n skills em .cline/skills"
  if [ -e "$HOME/.agents/AGENTS.md" ]; then
    ok "~/.agents/AGENTS.md presente"
  else
    bad "~/.agents/AGENTS.md ausente — Cline nao ve as instrucoes globais"
  fi
fi

printf '\n%d ok, %d falha(s)\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ] || exit 1
echo "kit instalado e reconhecivel pelas ferramentas habilitadas."
