---
paths: ["src/api/**", "src/server/**", "app/api/**", "**/*.openapi.yaml", "openapi/**"]
---

# API and server rules

Load the `api-contract` skill. The spec is the deliverable; the handler follows it.

- Update `openapi.yaml` in the same commit as the handler. No spec, no merge.
- One error envelope: `{ "error": { "code", "message", "details" } }`. `code` is stable, `message` is free text.
- Status codes: 201 + `Location` on create, 204 on delete, 409 on conflict, 422 on validation, 429 + `Retry-After`.
- Cursor pagination (`?limit=&cursor=` -> `next_cursor`) for anything that grows.
- Any `POST` that creates money or an external effect takes `Idempotency-Key`.
- Auth in one middleware, before the handler body.
- Never leak stack trace, SQL or internal error text in a response.
- Contract test per endpoint: schema, one happy path, one failure path.
