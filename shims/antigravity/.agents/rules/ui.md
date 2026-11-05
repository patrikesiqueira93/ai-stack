---
trigger: glob
globs: "*.ts, *.tsx, *.jsx, *.css, **/components/**"
description: "UI, components and front end work: tokens, states, accessibility."
---

# Regras de UI

Carregue a skill `front-component` antes de escrever um componente.

- Token de design apenas. Nenhum hex, nenhum espaçamento mágico dentro de um componente.
- Todo componente trata `loading`, `empty`, `error`, `ready`.
- Elemento semântico primeiro: `button`, `table`, `dialog`, `form`. `div` clicável precisa de `role`, `tabIndex` e handler de teclado.
- Controle só de ícone leva `aria-label`.
- Dado desce, evento sobe. Filho não busca o que o pai já tem.
- Um teste de render por estado, um de interação para a ação principal.
- Respeitar `prefers-reduced-motion`.
