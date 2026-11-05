# AGENTS.md — ai-stack core

Portable instructions for Cursor, Claude Code, Antigravity CLI and Cline.
`docs/MATRIZ.md` says which tool owns which domain.

## Stack

- Web: TypeScript 5.x `strict`, React 19 + Vite, Node 22. No custom bundler.
- Data: Python 3.12, `uv`, pandas/polars, DuckDB, dbt for the warehouse layer.
- DB: Postgres 16 local via Docker.
- Tests: vitest (web), pytest (python), contract tests against the OpenAPI file.
- Runner: every repo has a Makefile with `dev|test|lint|build`. Never invent another entry point.

## Definition of done (any task)

1. `make lint && make test` green locally.
2. The diff touches only the files the task needs.
3. New behaviour has one test that fails without the change.
4. No secret, token, credential or customer data in the diff — ever.
5. Commit message names the tool and the skill: `cursor(front-component): add invoice table`.

## Conventions

- Code, identifiers, branches and commits in English. Product copy in pt-BR.
- Errors: typed result or exception with a code, never a bare string.
- Logs: structured JSON, one line per event, no PII.
- Dependencies: justify in the PR; no new dependency for something under 40 lines.

## Prohibited

- Force-push to `main` or rewriting history on a shared branch.
- Editing `.github/`, `infra/` or `migrations/` without an explicit request.
- Disabling a test, a lint rule, a type check, or using `--no-verify` to make something pass.
- Sending repository content, datasets or user data to any endpoint that is not a configured tool.

## Skills

Procedure lives in `.agents/skills/<name>/SKILL.md`, loaded on demand.

- **front-component** — React/TS UI with tokens, accessibility and tests
- **api-contract** — HTTP contract first: OpenAPI, error model, contract tests
- **eda-profile** — dataset profile before any model or dashboard
- **experiment-design** — split, metric, baseline, seeds, eval report
- **agent-harness** — tool schema, loop, guardrails, 5 evals, traces
- **transformer-scratch** — char-level transformer: tokenizer, attention, train, sample

When a task matches a skill's description, load that skill before writing code.
