# GEMINI.md

Project instructions live in `AGENTS.md` at the repo root. Read it first.

Skill and data context for this workspace:

- **Data engineering and data analysis are your domain.** Load `eda-profile` before touching a dataset,
  and say the grain of the table in one sentence before writing SQL.
- Skills are discovered from `.gemini/skills/` and from the `.agents/skills/` alias. `scripts/instalar.sh`
  creates the alias when it is missing.
- The extension in `gemini-extension.json` registers the project commands (`/dbt-run`, `/profile`) and the
  Postgres MCP server. `/extensions list` should show it.
- Large input is your advantage: read the whole schema and the whole notebook in one pass instead of
  guessing from three lines.
- SQL: one CTE per logical step, named after the step. No `SELECT *` outside an exploratory query.
- Never write to a production table. Explore in a scratch schema; `migrations/` is off-limits.
- Python notebooks live in `notebooks/`, with the profile output written to `reports/profile.md`.
