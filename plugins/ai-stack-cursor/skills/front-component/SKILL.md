---
name: front-component
description: Build or change a React + TypeScript UI component using the project's design tokens, with accessibility and tests. Use when the task names a component, screen, layout, form, table, chart, modal, "tela", "página" or "componente" in the web app.
---

# front-component

## Before writing code

1. Read the nearest `AGENTS.md` and the tokens file (`src/styles/tokens.css` or equivalent).
2. Find one existing component that already solves a similar shape. Copy its structure, not its content.
3. Write the props contract first: what it receives, what it emits, what it never does (fetch, navigate, persist).

## Build order

1. **States** — `loading`, `empty`, `error`, `ready`. A component that only renders `ready` is half a component.
2. **Layout** — flex/grid with gap from tokens. No magic pixel, no negative margin as a fix.
3. **Behaviour** — events up, data down. No `useEffect` fetching a resource the parent already has.
4. **A11y** — semantic element first: `button`, `table`, `dialog`. If a `div` is clickable it needs `role`, `tabIndex` and a keyboard handler.
5. **Test** — one render test per state, one interaction test for the primary action.

## Checklist

- [ ] No hardcoded colour, spacing or font-size — tokens only
- [ ] Keyboard reachable: Tab to it, Enter/Space to act, Escape to close
- [ ] Visible focus ring
- [ ] Long text, empty text and 0 items are handled
- [ ] `aria-label` on icon-only controls
- [ ] Test asserts text the user sees, not the CSS class

## Anti-patterns

- `any` in props, or a props object with twelve optional booleans — split it instead.
- Inline `style={{}}` for something a token already covers.
- Component that owns its own fetch while the parent also fetches the same resource.
- `key={index}` in a list that reorders.
- Animation that ignores `prefers-reduced-motion`.

## Output

Component file, test file, and a screenshot or story if the repo has a preview. Commit as
`cursor(front-component): <what changed>`.
