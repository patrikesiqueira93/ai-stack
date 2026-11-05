---
trigger: model_decision
description: "Use whenever the task touches a dataset, table, CSV, parquet, SQL, dbt model, notebook or dashboard: grain, nulls, keys, leakage."
---

# Regras de dados

Carregue `eda-profile` antes de tocar num dataset. Carregue `experiment-design` antes de afirmar que um número melhorou.

- Grain antes de tudo: uma linha desta tabela significa o quê? Se não conseguir dizer, pare e pergunte.
- Nunca dropar nulo antes de contar.
- Nunca agregar antes de checar grain — é daí que vem contagem dobrada.
- Gráfico depois de checar escala e outlier, nunca antes.
- Número que "melhorou" precisa de baseline, seed e dispersão. Reporte os três ou chame de anedota.
- SQL: um CTE por passo lógico, com o nome do passo.
- Nada de `SELECT *` fora de consulta exploratória.
- Produção é somente leitura. Explore em schema de rascunho.
