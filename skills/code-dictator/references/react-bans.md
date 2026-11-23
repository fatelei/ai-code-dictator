# React / Frontend / Electron Dictator Bans

## 1. Ban `useEffect` by Default
AI agents abuse `useEffect` to synchronize state, compute derived values, or chain user events—causing render loops and stale closures.
- **Derived state:** Compute directly during render (`const fullName = `${first} ${last}``).
- **Event responses:** Trigger side effects inside `onClick` / `onSubmit` handlers, not `useEffect`.
- **Data fetching:** Use dedicated query libraries or framework loaders.

## 2. Strict Process & Layer Isolation (16ms Frame Budget)
In Electron or hybrid desktop/web apps, UI threads have a strict 16ms frame budget for 60fps:
- Never import Node/main-process modules (`fs`, `child_process`, `electron-main/*`) inside `renderer/` or `components/`.
- Offload heavy JSON parsing, AST operations, or crypto work to Web Workers or the main process over typed IPC.

## 3. Feature-Colocated Directory Rule
Keep at least 80% of a feature's UI, hooks, types, and helpers inside `src/features/<feature-name>/`. Do not scatter single-feature files across global `utils/`, `hooks/`, and `types/` folders.
