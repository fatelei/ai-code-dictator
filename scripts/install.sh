#!/usr/bin/env bash
set -euo pipefail

# AI Code Dictator One-Click Installer
# Usage: bash /path/to/ai-code-dictator/scripts/install.sh [target_repo_dir]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DICTATOR_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="${1:-$(pwd)}"

if [ ! -d "${TARGET_DIR}" ]; then
  echo "[Code Dictator] Error: Target directory '${TARGET_DIR}' does not exist." >&2
  exit 1
fi

TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"
echo "[Code Dictator] Installing into: ${TARGET_DIR}"

# 1. Install Agent Skill for Claude Code & Cursor
echo "[1/3] Installing code-dictator skill..."
mkdir -p "${TARGET_DIR}/.claude/skills" "${TARGET_DIR}/.cursor/skills"
rm -rf "${TARGET_DIR}/.claude/skills/code-dictator" "${TARGET_DIR}/.cursor/skills/code-dictator"
cp -R "${DICTATOR_ROOT}/skills/code-dictator" "${TARGET_DIR}/.claude/skills/code-dictator"
cp -R "${DICTATOR_ROOT}/skills/code-dictator" "${TARGET_DIR}/.cursor/skills/code-dictator"
echo "  -> Installed to .claude/skills/code-dictator and .cursor/skills/code-dictator"

# 2. Detect Tech Stack & Copy Lint Presets
echo "[2/3] Detecting tech stack and deploying lint presets..."
DETECTED_STACKS=()

# Node / TypeScript / React
if [ -f "${TARGET_DIR}/package.json" ]; then
  DETECTED_STACKS+=("node")
  if [ ! -f "${TARGET_DIR}/eslint.dictator.config.mjs" ]; then
    cp "${DICTATOR_ROOT}/presets/eslint.dictator.config.mjs" "${TARGET_DIR}/eslint.dictator.config.mjs"
    echo "  -> [Node/TS] Copied eslint.dictator.config.mjs (import into your eslint.config.mjs)"
  else
    echo "  -> [Node/TS] eslint.dictator.config.mjs already exists, skipped."
  fi
fi

# Python
if [ -f "${TARGET_DIR}/pyproject.toml" ] || [ -f "${TARGET_DIR}/requirements.txt" ] || [ -f "${TARGET_DIR}/setup.py" ]; then
  DETECTED_STACKS+=("python")
  if [ ! -f "${TARGET_DIR}/ruff.dictator.toml" ]; then
    cp "${DICTATOR_ROOT}/presets/ruff.dictator.toml" "${TARGET_DIR}/ruff.dictator.toml"
    echo "  -> [Python] Copied ruff.dictator.toml (run with: ruff check --config ruff.dictator.toml .)"
  else
    echo "  -> [Python] ruff.dictator.toml already exists, skipped."
  fi
fi

# Golang
if [ -f "${TARGET_DIR}/go.mod" ]; then
  DETECTED_STACKS+=("golang")
  if [ ! -f "${TARGET_DIR}/.golangci.yml" ]; then
    cp "${DICTATOR_ROOT}/presets/golangci.dictator.yml" "${TARGET_DIR}/.golangci.yml"
    echo "  -> [Golang] Copied .golangci.yml"
  else
    cp "${DICTATOR_ROOT}/presets/golangci.dictator.yml" "${TARGET_DIR}/golangci.dictator.yml"
    echo "  -> [Golang] Existing .golangci.yml preserved; saved preset as golangci.dictator.yml"
  fi
fi

# Java
if [ -f "${TARGET_DIR}/pom.xml" ] || [ -f "${TARGET_DIR}/build.gradle" ] || [ -f "${TARGET_DIR}/build.gradle.kts" ]; then
  DETECTED_STACKS+=("java")
  if [ ! -f "${TARGET_DIR}/checkstyle-pmd.dictator.xml" ]; then
    cp "${DICTATOR_ROOT}/presets/checkstyle-pmd.dictator.xml" "${TARGET_DIR}/checkstyle-pmd.dictator.xml"
    echo "  -> [Java] Copied checkstyle-pmd.dictator.xml"
  else
    echo "  -> [Java] checkstyle-pmd.dictator.xml already exists, skipped."
  fi
fi

if [ ${#DETECTED_STACKS[@]} -eq 0 ]; then
  echo "  -> Warning: No standard project manifest (package.json, pyproject.toml, go.mod, pom.xml) detected."
fi

# 3. Install Git pre-commit Hook
echo "[3/3] Configuring Git pre-commit hard gate..."
if [ -d "${TARGET_DIR}/.git" ]; then
  HOOK_FILE="${TARGET_DIR}/.git/hooks/pre-commit"
  if [ -f "${HOOK_FILE}" ]; then
    BACKUP_FILE="${HOOK_FILE}.backup.$(date +%Y%m%d%H%M%S)"
    cp "${HOOK_FILE}" "${BACKUP_FILE}"
    echo "  -> Backed up existing pre-commit hook to $(basename "${BACKUP_FILE}")"
  fi

  cat << 'EOF' > "${HOOK_FILE}"
#!/usr/bin/env bash
set -euo pipefail

echo "[Code Dictator] Running zero-tolerance pre-commit checks..."

# Node / TypeScript / React
if [ -f "package.json" ]; then
  if [ -f "tsconfig.json" ]; then
    npx tsc --noEmit
  fi
  if [ -f "eslint.dictator.config.mjs" ]; then
    npx eslint --config eslint.dictator.config.mjs . --max-warnings 0
  elif ls eslint.config.* >/dev/null 2>&1 || ls .eslintrc* >/dev/null 2>&1; then
    npx eslint . --max-warnings 0
  fi
fi

# Python
if [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "ruff.dictator.toml" ]; then
  if command -v ruff >/dev/null 2>&1; then
    if [ -f "ruff.dictator.toml" ]; then
      ruff check --config ruff.dictator.toml .
    else
      ruff check .
    fi
  else
    echo "[Code Dictator] Warning: 'ruff' not installed, skipping Python lint." >&2
  fi
fi

# Golang
if [ -f "go.mod" ]; then
  if command -v golangci-lint >/dev/null 2>&1; then
    if [ -f "golangci.dictator.yml" ]; then
      golangci-lint run --config golangci.dictator.yml
    else
      golangci-lint run
    fi
  else
    echo "[Code Dictator] Warning: 'golangci-lint' not installed, skipping Go lint." >&2
  fi
fi

# Java (Maven / Gradle)
if [ -f "pom.xml" ]; then
  if [ -f "checkstyle-pmd.dictator.xml" ]; then
    mvn -q test-compile checkstyle:check -Dcheckstyle.config.location=checkstyle-pmd.dictator.xml
  else
    mvn -q test-compile checkstyle:check
  fi
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  ./gradlew checkstyleMain --quiet
fi

echo "[Code Dictator] All checks passed!"
EOF

  chmod +x "${HOOK_FILE}"
  echo "  -> Installed executable hook at .git/hooks/pre-commit"
else
  echo "  -> Warning: '${TARGET_DIR}' is not a Git repository (.git not found). Skipped pre-commit hook."
fi

echo ""
echo "[Code Dictator] Setup complete! Your repository is now under zero-tolerance protection."
