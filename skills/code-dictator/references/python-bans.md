# Python Backend Dictator Bans

## 1. Zero Blind Exception Swallowing
- **Banned:** `except:` and `except Exception: pass`
- **Required:** Catch specific exceptions (`httpx.TimeoutException`, `ValueError`) and either recover explicitly, log structured context with `logger.exception(...)`, or re-raise.

## 2. Mandatory Type Signatures & Strict Checking
- Every function and method must declare parameter and return type annotations.
- Enforce `mypy --strict` or `pyright` in CI. Avoid `Any` and `# type: ignore` unless wrapping an untyped third-party C extension.

## 3. Complexity & Size Ceilings
- Maximum function length: **50 lines**.
- Maximum cyclomatic complexity (`C901`): **10**.
- Maximum nesting depth: **3 levels** (use guard clauses / early returns).
- Maximum file length: **300 lines** before splitting into cohesive submodules.
