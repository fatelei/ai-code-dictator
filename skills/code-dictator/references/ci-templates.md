# Full-Stack CI & Git Hook Hard Gates

## GitHub Actions Hard Gate (`.github/workflows/dictator-gate.yml`)

```yaml
name: Code Dictator Gate
on:
  pull_request:
  push:
    branches: [main]

jobs:
  enforce-standards:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # --- Node / TypeScript / React ---
      # - uses: actions/setup-node@v4
      #   with:
      #     node-version: '20'
      # - run: npm ci
      # - run: npx tsc --noEmit
      # - run: npx eslint . --max-warnings 0

      # --- Python ---
      # - uses: astral-sh/setup-uv@v4
      # - run: uvx ruff check .
      # - run: uvx mypy --strict .

      # --- Golang ---
      # - uses: actions/setup-go@v5
      #   with:
      #     go-version: '1.23'
      # - uses: golangci/golangci-lint-action@v6
      #   with:
      #     version: latest
      #     args: --config=presets/golangci.dictator.yml

      # --- Java (Maven) ---
      # - uses: actions/setup-java@v4
      #   with:
      #     distribution: 'temurin'
      #     java-version: '21'
      # - run: mvn -B verify checkstyle:check
```

## Pre-commit Hook (`.git/hooks/pre-commit`)

Run `bash scripts/install.sh` to auto-install this hook, or copy manually:

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[Code Dictator] Running zero-tolerance checks..."

if [ -f "package.json" ]; then
  npx tsc --noEmit
  npx eslint . --max-warnings 0
fi

if [ -f "pyproject.toml" ] || [ -f "ruff.toml" ]; then
  ruff check .
fi

if [ -f "go.mod" ]; then
  golangci-lint run
fi

if [ -f "pom.xml" ]; then
  mvn -q test-compile checkstyle:check
fi

echo "[Code Dictator] Passed."
```
