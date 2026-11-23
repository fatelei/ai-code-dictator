# AI Code Dictator

> **Stop babysitting AI agents. Turn every PR review complaint into a hard CI failure.**

A zero-tolerance Agent Skill and hard-enforcement lint preset pack built for **Claude Code**, **Cursor**, **OpenAI Codex**, and **Antigravity** across **TypeScript/React**, **Python**, **Golang**, and **Java**.

---

## Why This Exists

AI coding agents write features fast, but without rigid guardrails, repositories quickly decay into an unmaintainable **"organic architecture"**: bloated abstractions, stale narration comments, swallowed errors (`catch (e) {}` / `_ = err`), leaked goroutines, and broken layer boundaries.

This project combines two battle-tested engineering philosophies:

1. **The "Code Dictator" Mindset**: Zero tolerance for sloppy code—enforce strict, opinionated standards via automated gates rather than endless review debates.
2. **Dune Architecture Principles** (inspired by Lauren Tan, Lead Engineer on Grok Bot):
   - **Hard Constraints Over Soft Prompts**: LLMs forget Markdown instructions, but they cannot bypass a compiler error or a red CI build.
   - **Make the Shortest Path the Best Path**: Use strict feature-colocated directories and import boundaries so even the simplest agent naturally writes compliant code.
   - **Convert Every Review Comment into a Hard Rule**: Never leave the same PR comment twice—turn every recurring failure pattern into an AST lint rule or pre-commit check.

---

## How It Differs from Ordinary Code Review Skills

Most AI review skills act as **disposable soft prompts**—they critique code in one chat session, and the agent repeats the exact same mistake in the next session. **AI Code Dictator** turns your repository into a **self-hardening immune system**:

| Dimension | Ordinary Lint / Review Skill | AI Code Dictator |
| :--- | :--- | :--- |
| **Enforcement** | Soft Markdown suggestions (easily forgotten by LLMs) | Hard compiler, AST lint & `pre-commit` gates (physically blocks bad commits) |
| **Memory & Evolution** | Stateless across sessions | **Config-as-Memory**: every review complaint is crystallized into a permanent AST rule |
| **Target Failure Modes** | Generic formatting & style nitpicks | AI-specific slop: `useEffect` abuse, narration comments, swallowed errors (`_ = err`, empty `catch`), premature interfaces, layer leaks |
| **Team & Multi-Agent Sync** | Manual prompt copy-pasting | One-click `install.sh` + Git-tracked presets enforced across Claude Code, Cursor, Codex & CI |

---

## The Self-Hardening Loop ("Config-as-Memory")

AI Code Dictator does not rely on fragile model memory. Instead, it upgrades your codebase every time you catch an AI mistake:

```text
1. AI writes sloppy code (e.g., `_ = err` or cross-layer import)
        │
        ▼
2. Run Mode 1 (Audit) or reject it in PR review
        │
        ▼
3. Run Mode 2 (Harden): Agent translates the failure into a concrete AST rule
   and appends it to eslint.dictator.config.mjs / .golangci.yml / ruff.dictator.toml
        │
        ▼
4. Git pre-commit & CI permanently block that mistake across all future agents & sessions
