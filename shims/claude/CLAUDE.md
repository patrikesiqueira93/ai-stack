# CLAUDE.md

Project instructions live in `AGENTS.md` at the repo root — read it first, it is the source of truth
for stack, definition of done, conventions and prohibitions.

@AGENTS.md

## Claude Code specifics

- **Back end and agent harness are your domain.** Contract first (`api-contract` skill), then handler, then test.
- Skills: `.agents/skills/` is symlinked into `~/.claude/skills/` by `scripts/instalar.sh`. If a skill is missing, run it again.
- Path-scoped rules live in `.claude/rules/` and load only for the files they match.
- The `PostToolUse` hook runs lint + test after every write. If it fails, fix it before the next edit — do not continue building on a red tree.
- `make lint && make test` before saying a task is done.
- Refactor: change structure in one commit, behaviour in another. Never both.
