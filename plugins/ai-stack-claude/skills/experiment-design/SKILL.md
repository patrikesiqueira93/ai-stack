---
name: experiment-design
description: Design and run a data science experiment — split, metric, baseline, seeds, reproducibility and an eval report. Use when the task mentions a model, prediction, accuracy, A/B test, "medir se melhorou", feature, or comparing two approaches with a number.
---

# experiment-design

A result without a baseline and a seed is an anecdote.

## Order

1. **Question** — one sentence, with the decision it informs. "Does X improve Y enough to ship?"
2. **Metric** — one primary, at most two secondary. Define how it is computed, on what split, in what unit. If the metric can be gamed, say how.
3. **Baseline** — the dumbest thing that works: median, majority class, last value, current production. Record its number **before** training.
4. **Split** — by time if the data has time, by group if rows repeat a subject. Never random-split panel data.
5. **Leakage check** — run the `eda-profile` leakage step on the final feature set.
6. **Run** — fixed seed, logged config, one command that reproduces the number.
7. **Report** — baseline vs candidate, delta, confidence interval or spread across >=3 seeds, and the failure cases.

## Reproducibility contract

Every experiment folder carries `config.yaml`, `run.sh`, `metrics.json`, `report.md`.
`run.sh` must reproduce `metrics.json` from raw data with no manual step.

## Checklist

- [ ] Baseline number recorded before any model code
- [ ] Primary metric named and formula written
- [ ] Split rule stated, with the reason
- [ ] Seed fixed and logged; >=3 seeds if the delta is small
- [ ] Delta reported with spread, not a single number
- [ ] Failure cases with 3 examples each
- [ ] `run.sh` reproduces the reported number

## Anti-patterns

- Reporting the best of N runs as "the result".
- Test set touched more than once.
- Metric improved by moving the threshold after seeing the test set.
- "Accuracy" on imbalanced data with no mention of the base rate.
- Notebook as the only artifact — it does not run in CI.
