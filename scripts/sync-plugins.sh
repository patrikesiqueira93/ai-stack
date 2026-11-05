#!/usr/bin/env bash
# Regenerate the plugin folders from the single source of truth.
# The repo keeps one copy of each skill (.agents/skills) and each shim (shims/);
# plugins/ is generated so the two marketplaces stay identical to the core.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

for d in "$ROOT/.agents/skills"/*/; do
  name="$(basename "$d")"
  rm -rf "plugins/ai-stack-claude/skills/$name" "plugins/ai-stack-cursor/skills/$name"
  cp -R "$d" "plugins/ai-stack-claude/skills/$name"
  cp -R "$d" "plugins/ai-stack-cursor/skills/$name"
done

cp "$ROOT/shims/claude/.claude/hooks/guard.sh" "plugins/ai-stack-claude/hooks/guard.sh"
chmod +x "plugins/ai-stack-claude/hooks/guard.sh"
for f in "$ROOT/shims/cursor/.cursor/rules"/*.mdc; do
  cp "$f" "plugins/ai-stack-cursor/rules/$(basename "$f")"
done

echo "plugins sincronizados com .agents/skills e shims/"
