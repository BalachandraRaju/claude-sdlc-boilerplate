#!/bin/bash
# Pre-Write/Edit hook: Prevent writing to protected files
# Receives file path info via TOOL_INPUT env var

INPUT="${TOOL_INPUT:-}"

# Protected file patterns - block writes to these
PROTECTED_PATTERNS=(
  "\.env$"
  "\.env\.prod"
  "\.env\.production"
  "credentials\.json"
  "secrets\.json"
  "\.pem$"
  "\.key$"
  "id_rsa"
  "\.claude/hooks/"  # Prevent agents from modifying hooks
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern"; then
    echo "BLOCKED: Writing to protected file matching pattern: $pattern"
    echo "These files may contain secrets or security-critical configuration."
    echo "Create/edit these files manually."
    exit 1
  fi
done

# Warn (but don't block) on migration file edits
if echo "$INPUT" | grep -qiE "db/migration/V[0-9]"; then
  echo "WARNING: Editing existing Flyway migration. Migrations should be immutable once committed."
  echo "Consider creating a new migration file instead."
  # Don't exit 1 — just warn
fi

exit 0
