# Workflow: profile a new dataset

## 1. Locate
- Path or connection given. Confirm the file/table exists and its size before loading.

## 2. Load with intent
- Load only the columns you will profile first; report the total column count.
- Note the dtypes pandas/DuckDB inferred and the ones that look wrong.

## 3. Profile
- Run `scripts/profile.py <path>` (reuse it, do not retype pandas code).
- Output `reports/profile.md` and `reports/profile.json`.

## 4. Decide
- State the grain in one sentence.
- List the flags: all-null column, constant column, mixed types, duplicate key, time gap, leakage candidate.
- Write the cleaning plan as numbered steps, each with the row count it removes.

## 5. Handoff
- If a downstream step is asked for, say which columns survived and which were dropped, with the reason.
