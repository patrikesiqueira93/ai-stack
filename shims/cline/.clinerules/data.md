# Data and analysis rules

Load `eda-profile` before touching a dataset. Load `experiment-design` before claiming a number improved.

- Grain before everything: one row of this table means what? If you cannot say it, stop and ask.
- Never drop nulls before counting them.
- Never aggregate before checking grain — that is where double counting comes from.
- Chart after checking scale and outliers, not before.
- A number that "improved" needs a baseline, a seed and a spread. Report all three or call it an anecdote.
- SQL: one CTE per logical step, named after the step.
- No `SELECT *` outside an exploratory query.
- Read-only against production. Explore in a scratch schema.
