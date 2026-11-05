---
trigger: glob
globs: "src/api/**, src/server/**, app/api/**, **/*.openapi.yaml, openapi/**, **/*_api.py"
description: "HTTP API and server code: contract, error envelope, status codes, auth."
---

# Regras de API e servidor

Carregue a skill `api-contract`. A spec é a entrega; o handler obedece a ela.

- `openapi.yaml` atualizado no mesmo commit do handler. Sem spec, sem merge.
- Um envelope de erro: `{ "error": { "code", "message", "details" } }`. `code` é estável, `message` é texto livre.
- Status: 201 + `Location` no create, 204 no delete, 409 em conflito, 422 em validação, 429 + `Retry-After`.
- Paginação por cursor (`?limit=&cursor=` -> `next_cursor`) para tudo que cresce.
- Todo `POST` que cria dinheiro ou efeito externo recebe `Idempotency-Key`.
- Auth em um único middleware, antes do corpo do handler.
- Nunca vazar stack trace, SQL ou erro interno na resposta.
- Um teste de contrato por endpoint: schema, caminho feliz, caminho de falha.
