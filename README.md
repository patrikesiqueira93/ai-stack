# ai-stack v0.2

Kit de contexto, skills e guardrails para Cursor, Claude Code, Antigravity CLI e Cline.

**Um núcleo, quatro camadas finas.** O núcleo (`AGENTS.md` + `.agents/skills/`) é escrito uma vez;
cada ferramenta recebe só o que ela tem de diferente.

## Instalar

```bash
./scripts/instalar.sh --all --target ~/projetos/meu-app       # symlink (recomendado)
./scripts/instalar.sh --all --copy --target ~/projetos/meu-app # cópia, sem symlink
./scripts/check.sh --all --target ~/projetos/meu-app
```

Ou por ferramenta: `--cursor`, `--claude`, `--antigravity`, `--cline`, `--gemini` (legado).
Sem `--target`, instala no diretório atual. Arquivos existentes são copiados para `<arquivo>.bak.<timestamp>`.

Instalação manual (sem terminal): use `artifacts/ai-stack-manual.zip` do workspace do Maestro —
41 arquivos, uma pasta por ferramenta, cada uma com `LEIA-ME.md`.

## O que vai para onde

| Ferramenta | Recebe | Lê de |
|---|---|---|
| Núcleo | `AGENTS.md`, `.agents/skills/` | — |
| Cursor | `.cursor/rules/*.mdc` | `AGENTS.md` (nativo) + `.cursor/rules` + `.agents/skills` |
| Claude Code | `CLAUDE.md`, `.claude/rules/`, `.claude/hooks/guard.sh`, `.claude/settings.json` | `CLAUDE.md` → aponta para `AGENTS.md`; skills via symlink em `~/.claude/skills/` |
| Antigravity CLI | `.agents/rules/*.md`, `.agents/mcp_config.json` | `.agents/skills` (nativo) |
| Gemini CLI (legado) | `GEMINI.md`, `gemini-extension.json`, `commands/*.toml` | `.gemini/skills` e o alias `.agents/skills` |
| Cline | `.clinerules/`, `.clinerules/workflows/` | `.clinerules` + `~/.agents/AGENTS.md` |

## Matriz domínio → ferramenta dona

Ver `docs/MATRIZ.md`. Resumo: front = Cursor, back e harness = Claude Code,
dados/EDA = Antigravity CLI, Transformer = Cline.

## Aviso: Gemini CLI

Em **18/06/2026 o Gemini CLI parou de atender contas individuais** (Google AI Pro, Ultra e tier
gratuito). Sobrevive só com licença Gemini Code Assist Standard/Enterprise ou API key do
Google AI Studio. O substituto é o **Antigravity CLI** (`agy`), que lê `.agents/skills/`
nativamente. O shim antigo fica em `shims/gemini/` para quem tem API key.

## Estado

v0.2 — instalação por symlink ou cópia, quatro ferramentas reconhecidas, 53 verificações
no `check.sh`. Falta: teste de fumaça real em cada ferramenta (11/11) e a matriz viva (12/11).

## Estrutura

```
ai-stack/
├── AGENTS.md                   instruções portáveis do projeto
├── .agents/skills/             6 skills (padrão aberto Agent Skills)
│   └── eda-profile/scripts/    profile.py — profiler de dataset testado
├── shims/
│   ├── cursor/.cursor/rules/   3 regras .mdc
│   ├── claude/                 CLAUDE.md, .claude/rules, hook PostToolUse
│   ├── antigravity/.agents/    rules com trigger + mcp_config.json
│   ├── gemini/                 legado (GEMINI.md, extensão, comandos)
│   └── cline/.clinerules/      regras + workflows
├── scripts/instalar.sh         instala por ferramenta, com backup
├── scripts/check.sh            53 verificações, exit 1 em falha
└── docs/MATRIZ.md              domínio → ferramenta dona
```
