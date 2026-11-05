# Matriz domínio → ferramenta dona

Cada domínio tem **uma dona**. As outras herdam a skill do núcleo (`.agents/skills/`), mas não são
responsáveis por mantê-la. Ao mudar stack ou convenção, edite `AGENTS.md` e a skill na pasta núcleo — nunca no shim.

| Domínio | Dona | Por quê | Mecanismo que a torna boa nisso |
|---|---|---|---|
| Front end | **Cursor** | Ciclo de edição visual mais curto; preview e subagents no editor | `.cursor/rules/*.mdc` com glob + skill `front-component` + Custom Mode com a skill sempre em contexto |
| Back end | **Claude Code** | Contexto de repo inteiro, refactor em duas fases, hook que barra árvore vermelha | `CLAUDE.md` importando `AGENTS.md` + `.claude/rules/api.md` por caminho + `PostToolUse` guard |
| Full stack | **Cursor + Claude Code** | Cursor desenha a UI; Claude fecha contrato, serviço e teste de contrato | Contrato OpenAPI no repo, skill `api-contract` compartilhada, commit por dona |
| Engenharia de dados | **Antigravity CLI** | Janela grande: schema + SQL + dbt num turno só | `.agents/rules/` com `trigger` + `.agents/mcp_config.json` (Postgres) |
| Análise de dados | **Antigravity CLI** | Lê CSV/parquet e notebook inteiros de uma vez | Skill `eda-profile` + `scripts/profile.py` reaproveitado |
| Ciência de dados | **Claude Code** | Experimento com contrato de reprodutibilidade e revisão estatística | Skill `experiment-design` + subagent revisor + hook exigindo `run.sh` |
| Engenharia de harness | **Claude Code** | Único dos quatro com skills + agents + hooks + MCP num pacote versionado (plugin) | Plugin com `skills/`, `agents/`, `hooks/hooks.json`, `.mcp.json` + skill `agent-harness` |
| LLM Transformer | **Cline** | Trabalho longo e autônomo em Plan/Act com workflow de várias etapas | `.clinerules/workflows/train-transformer.md` + skill `transformer-scratch` |

## Assimetrias reais entre as quatro

> Atualizado para o Antigravity CLI, sucessor do Gemini CLI desde 18/06/2026.

| Ponto | Cursor | Claude Code | Antigravity CLI | Cline |
|---|---|---|---|---|
| Lê `AGENTS.md` | nativo, raiz e subpastas | sim, no lugar do `CLAUDE.md` (v2.1.277+) | nativo (raiz e subpastas) | global em `~/.agents/AGENTS.md` |
| Lê `.agents/skills/` | sim | **não** — symlink em `~/.claude/skills/` | **sim, é o padrão dele** | não — usa `.cline/skills/` |
| Regra por caminho | `.mdc` com `globs` | `.claude/rules/` com `paths` | `.agents/rules/` com `trigger` e `globs` | `.clinerules/` por arquivo |
| Hook bloqueante | hooks de ciclo de vida | `PostToolUse` com exit 2 | hooks de ciclo de vida | hooks |
| Comando nomeado | skill no `/` ou Custom Mode | skill/plugin no `/` | skill no `/` | workflow + skill no `/` |

**Leitura da tabela:** o único que bloqueia o turno com um exit code é o mais direto de auditar.
Nas outras três, proibição em markdown é sugestão — por isso o teste de aceite da entrega 1 é
"a skill aparece sozinha", e o da entrega 3 é "o número mudou", não "o agente obedeceu".

## Manutenção

- Revisar skills a cada mudança de stack (uma linha em `CHANGELOG.md`).
- Skill que não pagou o custo no benchmark da entrega 3 é removida, não "melhorada".
- `AGENTS.md` acima de 200 linhas: mover procedimento para skill, deixar só fato.
