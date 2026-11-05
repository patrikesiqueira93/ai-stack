---
paths: ["src/harness/**", "src/agent/**", "agent/**", "evals/**", "prompts/**"]
---

# Agent harness rules

Load the `agent-harness` skill.

- Every tool: typed schema, one-sentence purpose, an error the model can act on.
- The loop has max steps, max tokens, max wall-clock and a budget check, each with defined behaviour at the limit.
- Irreversible action requires explicit confirmation.
- Trace every step: tool, args hash, latency, tokens, outcome. No trace, no debugging.
- 5 evals minimum (happy path, ambiguous, tool error, missing permission, adversarial), run by one command.
- Temperature 0 for classification and extraction.
- Never retry a failed tool call with identical arguments.
