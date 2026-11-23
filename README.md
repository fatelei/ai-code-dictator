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

~~~text
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
~~~

---

## Repository Structure

~~~text
ai-code-dictator/
├── README.md
├── scripts/
│   └── install.sh                     # One-click installer: detects stack, deploys presets, installs skill & pre-commit hook
├── skills/
│   └── code-dictator/
│       ├── SKILL.md                   # Dual-mode Agent Skill (Zero-Tolerance Audit + Soft-to-Hard CI Generator)
│       └── references/
│           ├── react-bans.md          # React/Electron bans (no useEffect abuse, 16ms frame isolation, feature colocation)
│           ├── python-bans.md         # Python bans (mandatory type hints, no blind except, complexity ceilings)
│           ├── golang-bans.md         # Golang bans (no _ = err, bounded concurrency, no premature interfaces)
│           ├── java-bans.md           # Java/Spring bans (constructor injection only, no swallowed exceptions, N+1 traps)
│           └── ci-templates.md        # GitHub Actions & pre-commit hard gate templates
└── presets/
    ├── eslint.dictator.config.mjs     # Strict ESLint flat config
    ├── ruff.dictator.toml             # Strict Ruff config (C901, BLE, ANN)
    ├── golangci.dictator.yml          # Strict golangci-lint config (errcheck, wrapcheck, contextcheck, bodyclose)
    └── checkstyle-pmd.dictator.xml    # Strict Java Checkstyle ruleset
~~~

---

## Quick Start

### Option 1: One-Click Installation (Recommended)

Run `scripts/install.sh` from your target repository root (or pass the target path as an argument):

~~~bash
bash /path/to/ai-code-dictator/scripts/install.sh .
~~~

The installer automatically:
1. **Installs the Agent Skill** into `.claude/skills/code-dictator` and `.cursor/skills/code-dictator` (also compatible with `.agents/skills/` for Codex and `.agent/skills/` for Antigravity).
2. **Detects Your Tech Stack** (`package.json`, `pyproject.toml`, `go.mod`, `pom.xml`/`build.gradle`) and copies the corresponding strict lint preset without overwriting existing configs.
3. **Mounts a Git `pre-commit` Hook** (backing up any existing hook) to physically block non-compliant commits from humans or AI agents.

### Option 2: Manual Setup

- **Install Skill**: Copy `skills/code-dictator` into your project's `.claude/skills/`, `.cursor/skills/`, `.agents/skills/`, or `.agent/skills/` folder.
- **JS / TS / React**: Import `presets/eslint.dictator.config.mjs` into your `eslint.config.mjs`.
- **Python**: Merge `presets/ruff.dictator.toml` into `pyproject.toml` or `ruff.toml`.
- **Golang**: Copy `presets/golangci.dictator.yml` to `.golangci.yml`.
- **Java**: Point Maven/Gradle Checkstyle to `presets/checkstyle-pmd.dictator.xml`.

---

## Adopting in Existing (Brownfield) Repositories

You do **not** need a greenfield project to use AI Code Dictator. To avoid being overwhelmed by legacy lint errors in an existing codebase, follow the **Boy Scout Rule** (strict on new/modified code, gradual on legacy files):

1. **Audit Diffs Only**: Ask your AI agent to run `code-dictator` specifically on `git diff` or newly added modules so legacy debt stays untouched while new AI output stays clean.
2. **Scope `pre-commit` to Staged Files**: Update your `.git/hooks/pre-commit` to lint only modified files instead of scanning the entire repo:
   - **Python**: `git diff --cached --name-only --diff-filter=ACM | grep '\.py$' | xargs -r ruff check --config ruff.dictator.toml`
   - **JS / TS**: `git diff --cached --name-only --diff-filter=ACM | grep -E '\.(ts|tsx|js|jsx)$' | xargs -r npx eslint --config eslint.dictator.config.mjs --max-warnings 0`
   - **Golang**: `golangci-lint run --new-from-rev=HEAD`
3. **Phase In Rules**: Start by enforcing crash/security blockers (`errcheck`, `BLE`, `no-empty`, `EmptyCatchBlock`), then tighten complexity and function-length ceilings over time.

---

## Usage Prompts

- **Mode 1 — Zero-Tolerance Code Audit**:
  > "Use `code-dictator` to audit the changes I just made. Flag any blockers, hallucinated APIs, silent error swallowing, or AI slop, and provide a cleaned version."
- **Mode 2 — Convert Review Feedback into Hard CI**:
  > "The AI agent keeps using `_ = err` / `useEffect` in this repo. Use `code-dictator` to turn this into a hard lint rule and update our pre-commit check."

---

## License

MIT
