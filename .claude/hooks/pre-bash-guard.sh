#!/bin/bash
# Pre-Bash hook: Block dangerous commands
# This hook receives the tool input via TOOL_INPUT env var

INPUT="${TOOL_INPUT:-}"

# List of dangerous patterns to block
DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf ~"
  "DROP DATABASE"
  "DROP TABLE"
  "TRUNCATE TABLE"
  "DELETE FROM .* WHERE 1"
  "git push.*--force.*main"
  "git push.*--force.*master"
  "chmod -R 777"
  "curl.*|.*sh"
  "wget.*|.*sh"
  "> /dev/sda"
  "mkfs\."
  ":(){:|:&};:"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -qiE "$pattern"; then
    echo "BLOCKED: Dangerous command detected matching pattern: $pattern"
    echo "Command: $INPUT"
    exit 1
  fi
done

# Block commands that modify production environment variables
if echo "$INPUT" | grep -qiE "(PROD|PRODUCTION).*="; then
  echo "BLOCKED: Modifying production environment variables is not allowed."
  exit 1
fi

exit 0
