---
name: api-contract
description: Design or change an HTTP API contract first — OpenAPI, error model, pagination, idempotency — then implement and test against it. Use when the task adds an endpoint, changes a payload, or touches auth, status codes, versioning or API docs.
---

# api-contract

The contract is the deliverable. Code follows it.

## Order (do not skip)

1. **Resource and verb** — noun in plural, verb from HTTP. No `/getUser` and no verb in the path.
2. **Payload** — request and response as schema, not prose. Field names `snake_case` on the wire, mapped at the boundary.
3. **Errors** — one envelope, always the same shape:

```json
{ "error": { "code": "invoice_not_found", "message": "Invoice 42 does not exist", "details": {} } }
```

   `code` is stable and machine-readable; `message` is for humans and may change.
4. **Status codes** — 201 + `Location` on create, 204 on delete, 409 on conflict, 422 on validation, 429 with `Retry-After`.
5. **Pagination** — cursor, not offset, for anything that grows. `?limit=&cursor=`, response carries `next_cursor`.
6. **Idempotency** — any `POST` that creates money or an external effect takes `Idempotency-Key`.
7. **Version** — breaking change means `/v2` or a documented deprecation window. Never silently change a field's type.

## Implementation rules

- Validate input at the boundary with one schema reused by the handler and the docs.
- Never leak internal error text, stack trace or SQL to the response.
- Auth checked before the handler body, in one middleware, not per route by memory.
- Every endpoint gets a contract test: schema + one happy path + one failure path.

## Checklist

- [ ] `openapi.yaml` updated in the same commit as the handler
- [ ] Contract test green against the spec, not against a mock of the spec
- [ ] No field renamed or retyped without a version bump
- [ ] 4xx paths return the envelope, not HTML
- [ ] Timeout and pagination limit documented

## Anti-patterns

- Response shaped by the ORM model leaking internal columns.
- `200` with `{"success": false}`.
- Auth by "the front end won't call it".
- N+1 caused by returning a list without deciding its size.
