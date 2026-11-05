# ai-stack v0.2

Kit de contexto, skills e guardrails para Cursor, Claude Code, Antigravity CLI e Cline.

**Um núcleo, quatro camadas finas.** O núcleo (`AGENTS.md` + `.agents/skills/`) é escrito uma vez;
cada ferramenta recebe só o que ela tem de diferente.

## Instalar em plugin (Claude Code)

```
/plugin marketplace add patrikesiqueira93/ai-stack
/plugin install ai-stack@ai-stack-marketplace
```

Instala as 6 skills e o hook `PostToolUse` que barra edição com lint vermelho.
Atualizar depois: `/plugin marketplace update ai-stack-marketplace`.

## Instalar no Cursor (plugin)

O repositório é um marketplace no formato do Cursor (`.cursor-plugin/marketplace.json`).
Em **Customize → Plugins → Add from GitHub**, aponte para `patrikesiqueira93/ai-stack`.
Se ele pedir um plugin único em vez de um marketplace, aponte para `plugins/ai-stack-cursor`.

## Instalar no projeto inteiro (as quatro ferramentas)

```bash
git clone https://github.com/patrikesiqueira93/ai-stack.git
cd ai-stack
./scripts/instalar.sh --all --target ~/projetos/meu-app        # symlink (recomendado)
./scripts/instalar.sh --all --copy --target ~/projetos/meu-app # cópia, sem symlink
./scripts/check.sh --all --target ~/projetos/meu-app
```

Ou por ferramenta: `--cursor`, `--claude`, `--antigravity`, `--cline`, `--gemini` (legado).
Sem `--target`, instala no diretório atual. Arquivos existentes são copiados para `<arquivo>.bak.<timestamp>`.

Instalação manual, sem terminal: use `artifacts/ai-stack-manual.zip` do workspace do Maestro —
41 arquivos, uma pasta por ferramenta, cada uma com `LEIA-ME.md`.

## O que vai para onde

| Ferramenta | Recebe | Lê de |
|---|---|---|
| Núcleo | `AGENTS.md`, `.agents/skills/` | — |
| Cursor | `.cursor/rules/*.mdc` | `AGENTS.md` (nativo) + `.cursor/rules` + `.agents/skills` |
| Claude Code | `CLAUDE.md`, `.claude/rules/`, `.claude/hooks/guard.sh`, `.claude/settings.json` | `CLAUDE.md` → aponta para `AGENTS.md`; skills via symlink em `~/.claude/skills/` ou plugin |
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

v0.2 — instalação por symlink, cópia manual ou plugin/marketplace; quatro ferramentas
reconhecidas; 53 verificações no `check.sh`; plugin validado com `claude plugin validate`.
Falta: teste de fumaça real em cada ferramenta (11/11) e a matriz viva (12/11).

## Estrutura

```
ai-stack/
├── AGENTS.md                   instruções portáveis do projeto
├── .agents/skills/             6 skills (padrão aberto Agent Skills) — fonte única
├── .claude-plugin/             marketplace do Claude Code
├── .cursor-plugin/             marketplace do Cursor
├── plugins/
│   ├── ai-stack-claude/        plugin: skills + hook PostToolUse
│   └── ai-stack-cursor/        plugin: skills + 3 regras
├── shims/                      camada por ferramenta (cursor, claude, antigravity, gemini, cline)
├── scripts/
│   ├── instalar.sh             instala por ferramenta, com backup
│   ├── check.sh                53 verificações, exit 1 em falha
│   └── sync-plugins.sh         regenera plugins/ a partir do núcleo
└── docs/MATRIZ.md              domínio → ferramenta dona
```

`plugins/` é gerado: rode `scripts/sync-plugins.sh` depois de editar `.agents/skills/` ou os shims.
