---
name: code-dictator
description: Enforce zero-tolerance engineering standards on AI-generated code (React/TS, Python, Golang, Java) and convert recurring PR review feedback into hard static analysis, lint rules, and CI checks. Use whenever the user asks to audit AI code, enforce strict linting ("code dictator"), clean up vibe-coded bloat, or harden a repository so AI agents cannot introduce regressions.
---
# Code Dictator (代码独裁者)

A zero-tolerance engineering gatekeeper designed for AI-assisted development across React/TS, Python, Golang, and Java. Built on a simple premise: **never rely on soft prompts alone to prevent bad code—make the shortest path the best path, and turn every repeated review comment into a hard CI failure.**

## Core Philosophy

1. **Hard Constraints Over Soft Prompts:** Rules in Markdown can be forgotten by an LLM; compiler errors, strict linters, and failing CI checks cannot.
2. **Zero AI Slop:** No dead abstractions, no speculative comments, and no silent error swallowing.
3. **Shortest Path = Best Path:** Enforce strict feature-colocated directory structures and dependency boundaries so any agent editing the repo naturally follows the architecture.

## Mode 1: Zero-Tolerance Code Audit

When asked to review, lint, or clean up code, detect the stack and inspect strictly across these 6 rules (consult the stack-specific file in `references/` when reviewing React, Python, Golang, or Java):

1. **Ban High-Risk Stack Footguns**
   - **React / Frontend (`references/react-bans.md`):** Flag any `useEffect` used for derived state, event chains, or data fetching without explicit external synchronization justification. Flag main-process/Node imports in UI layers.
   - **Python (`references/python-bans.md`):** Flag untyped function signatures, mutable default arguments, and blocking calls inside `async def`.
   - **Golang (`references/golang-bans.md`):** Flag `_ = err` / unchecked errors, fire-and-forget `go func()` without `context.Context` cancellation or `errgroup`, `context.Background()` buried inside request handlers, and premature single-implementation interfaces.
   - **Java (`references/java-bans.md`):** Flag `@Autowired` field injection, `catch (Exception e)` without rethrow/context, `@Transactional` self-invocation or swallowed checked exceptions, raw types, and N+1 ORM queries inside loops.
2. **Ban Useless & Stale Comments**
   - Delete comments that merely narrate what the code does (`// increment counter`) or record temporary prompt history (`// fixed as requested`).
   - Require self-explanatory naming instead of comments. Only keep comments explaining non-obvious external invariants or Go doc comments on exported symbols when required by package policy.
3. **Zero Silent Failures**
   - Reject empty `catch (e) {}`, bare `except Exception: pass`, ignored Go `err` returns, and Java `e.printStackTrace()`. Every error must be wrapped with context, handled with explicit recovery, or propagated.
4. **Anti-Bloat & File Size Ceilings**
   - Flag functions/methods exceeding 50 lines, nesting deeper than 3 levels (require early returns), single-use wrapper classes/interfaces/helpers, and unused imports or parameters.
5. **Strict Type & Boundary Safety**
   - Reject `any`, `@ts-ignore`, Go `any`/`interface{}` abuse where generics or concrete types fit, Java raw collections/unchecked casts, unvalidated external payloads, and hardcoded secrets or magic numbers.
6. **Hallucination & Resource Verification**
   - Verify that every imported package, method signature, and configuration key exists in the target stack. Flag unclosed `resp.Body`, DB rows/connections, file handles, timers, or missing `defer cancel()`.

### Audit Output Format

Lead directly with findings grouped by severity (omit empty sections):

- **BLOCKER (CI Fail):** Bugs, hallucinated APIs, banned stack patterns (`useEffect`, `_ = err`, field injection, cross-layer imports), security risks, or silent error swallowing.
- **WARNING (Refactor Required):** Functions > 50 lines, nesting > 3 levels, goroutine/resource leaks, missing edge cases.
- **SLOP (Delete):** Redundant comments, dead code, and unnecessary interfaces/abstractions.

For each item, state **Location**, **Rule Violated**, and the **Exact Fix**, followed by the complete cleaned code.

## Mode 2: Harden Repo (Convert Soft Rules to Hard CI)

When the user says "turn this review into a lint rule", "harden my repo", or asks how to stop AI agents from repeating the same mistake (consult `references/ci-templates.md`):

1. **Identify the Failure Pattern:** Extract the exact AST pattern, import violation, or structural mistake.
2. **Generate Hard Enforcement:** Output concrete, copy-pasteable configuration for the project's toolchain rather than adding another paragraph to `AGENTS.md`:
   - **JS/TS/React:** Custom `no-restricted-syntax` ESLint rules (e.g., banning `useEffect` or `no-warning-comments`), `eslint-plugin-import/no-restricted-paths` for directory isolation, and `tsc --noEmit --strict`.
   - **Python:** Strict `ruff` rule sets (`F`, `E`, `B`, `C901` complexity limit, `BLE` blind-except ban) and `mypy --strict`.
   - **Golang:** Strict `.golangci.yml` enabling `errcheck`, `wrapcheck`, `govet`, `staticcheck`, `gosec`, `gocognit`, `nestif`, and `depguard` for package import isolation.
   - **Java:** Checkstyle (`IllegalCatch`, `CyclomaticComplexity`, `MethodLength`, `NestedIfDepth`), SpotBugs, and ArchUnit tests enforcing hexagonal/layered package boundaries.
   - **Git / CI Gate:** Write `.git/hooks/pre-commit` (with `chmod +x`) or GitHub Actions snippet that blocks commits/merges on any lint or type error.
3. **Verify Before Finishing:** Run the linter/typechecker or `.git/hooks/pre-commit` to confirm the new rule catches the bad pattern and passes on clean code.
