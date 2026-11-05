# Changelog

## v0.2 — 2026-11-05

**Mudança de rota: Gemini CLI → Antigravity CLI.**
Em 18/06/2026 o Gemini CLI parou de atender contas individuais (Google AI Pro, Ultra e tier
gratuito). Sobrevive só com licença Code Assist Enterprise ou API key do AI Studio. O
substituto lê `.agents/skills/` nativamente, o que simplificou o kit.

- Novo shim `shims/antigravity/`: 3 regras em `.agents/rules/` com frontmatter `trigger`
  obrigatório (arquivo sem trigger válido é descartado em silêncio) + `.agents/mcp_config.json`.
- `instalar.sh`: flags `--antigravity` e `--copy` (instala copiando em vez de symlink).
- `check.sh`: entende os dois modos de instalação (symlink e cópia manual); valida o `trigger`
  das regras do Antigravity; só julga as regras que ele mesmo instala, não as do usuário.
- `shims/gemini/`: o shim antigo fica disponível para quem tem API key.

## v0.1 — 2026-11-05

Primeiro esqueleto funcional. Instala e é reconhecido pelas quatro ferramentas.

**Núcleo**
- `AGENTS.md` (47 linhas): stack, definition of done, convenções, proibições.
- 6 skills em `.agents/skills/`: front-component, api-contract, eda-profile,
  experiment-design, agent-harness, transformer-scratch.
- `eda-profile/scripts/profile.py`: profiler de dataset testado (CSV/TSV/parquet/JSONL).

**Shims**
- Cursor: 3 regras `.mdc` (1 alwaysApply, 2 por glob) + symlink de skills.
- Claude Code: `CLAUDE.md` importando `AGENTS.md`, 2 regras path-scoped,
  hook `PostToolUse` que bloqueia em lint vermelho, skills por symlink global.
- Gemini CLI: `GEMINI.md`, extensão com MCP Postgres, 2 comandos TOML.
- Cline: 2 regras, 2 workflows, symlink de skills, `~/.agents/AGENTS.md`.

**Scripts**
- `instalar.sh`: por ferramenta ou `--all`, com backup de arquivo existente.
- `check.sh`: 54 verificações, exit 1 em falha. Testado positivo e negativo.

**Pendente**
- Teste de fumaça real nas quatro ferramentas (skill aparece no `/` e é achada sozinha).
