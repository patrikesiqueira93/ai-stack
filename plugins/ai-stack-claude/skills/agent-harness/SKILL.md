---
name: agent-harness
description: Build or change the harness of an LLM agent — tool schema, loop, context assembly, guardrails, traces and evals. Use when the task mentions agent, tool calling, prompt loop, "harness", evals, retries, cost per task, or making an agent reliable.
---

# agent-harness

The model is the easy part. The harness is the product.

## Components, in dependency order

1. **Tool schema** — name, one-sentence purpose, typed params with constraints, one example.
   A tool the model cannot misuse is worth three it can. Return errors the model can act on.
2. **Loop** — max steps, max tokens, max wall-clock, and what happens at each limit.
   Every iteration appends a compact observation, never the full tool output.
3. **Context** — system prompt under 1.5k tokens; retrieval returns at most N items with ids;
   history is summarized past a threshold, keeping decisions and open questions.
4. **Guardrails** — allowlist of tools per task, confirmation before anything irreversible,
   timeout per tool, and a budget check before the step that would exceed it.
5. **Trace** — every step logged: input hash, tool, args hash, latency, tokens, outcome. No trace, no debugging.
6. **Evals** — 5 cases minimum: happy path, ambiguous request, tool error, missing permission, and one adversarial.
   Each case has an expected outcome, not an expected exact string.

## Design rules

- One responsibility per tool. If the description needs "and", split it.
- Structured output: JSON schema, validated, retried once on parse failure, then fail loudly.
- Deterministic where possible: temperature 0 for classification and extraction.
- Cost visible: tokens and currency per task in the trace, not per month.
- Model swap is a config change, not a refactor.

## Checklist

- [ ] Every tool has a typed schema and a failure mode the model can recover from
- [ ] Loop has 4 limits and a defined behaviour at each
- [ ] Irreversible action requires confirmation
- [ ] Trace covers input, tools, tokens, latency and outcome
- [ ] 5 evals green, run by one command, in CI
- [ ] Cost per successful task measured

## Anti-patterns

- Ten tools that overlap, so the model picks wrong.
- Retrying a failed call with the same arguments.
- Warning in the prompt instead of a guardrail in the loop.
- Eval that asserts an exact sentence.
- Context that grows until the model forgets the objective.
