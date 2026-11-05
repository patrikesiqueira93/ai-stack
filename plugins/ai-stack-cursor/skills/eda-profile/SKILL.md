---
name: eda-profile
description: Profile a dataset before modeling, charting or writing a pipeline — shape, types, nulls, duplicates, cardinality, distribution, outliers, leakage. Use when the task mentions a CSV, parquet, table, dataset, "analisar os dados", data quality or a first look at a new source.
---

# eda-profile

No model, no chart and no warehouse table before the profile exists.

## Order

1. **Shape** — rows, columns, column types, memory. A "small" dataset that does not fit memory changes the whole plan.
2. **Grain** — one row means what? Say it in one sentence. If you cannot, the dataset is not ready.
3. **Keys** — candidate primary key; duplicates on it; nulls on it.
4. **Per column** — null %, distinct count, min/max, top 5 values, 3 examples. Flag: constant, all-null, high-cardinality ID, mixed type disguised as string.
5. **Time** — if there is a date column: range, gaps, timezone, future dates, duplicates per period.
6. **Numeric distribution** — p50/p90/p99, outliers by IQR, negatives where negatives are impossible.
7. **Leakage** — a column that encodes the target, a date after the event, an ID that is sequential with the label.
8. **Decision** — usable / usable with cleaning steps / not usable. Name the cleaning steps.

## Always run a script, never eyeball

Produce `profile.md` and `profile.json`: the table, the flags, and the cleaning plan.
Reuse `scripts/profile.py`, do not retype pandas code per task.

```bash
python scripts/profile.py data/file.csv --out reports/profile
```

## Checklist

- [ ] Grain written in one sentence
- [ ] Null and distinct counts per column
- [ ] Duplicates on the candidate key counted
- [ ] Date range and timezone stated
- [ ] Leakage columns named
- [ ] Cleaning plan numbered, with the row count each step removes

## Anti-patterns

- `df.describe()` alone and calling it a profile — it ignores strings, dates and keys.
- Dropping nulls before counting them.
- Aggregating before checking grain (double counting).
- Charting before checking scale and outliers.
- Reporting a mean of a distribution with two peaks.
