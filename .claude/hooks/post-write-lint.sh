#!/bin/bash
# Post-Write/Edit hook: Run quick lint checks on modified files
# Receives file info via TOOL_INPUT env var

INPUT="${TOOL_INPUT:-}"
FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"\s*:\s*"[^"]*"' | head -1 | sed 's/.*"file_path"\s*:\s*"//;s/"$//')

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Java files — check compilation
if echo "$FILE_PATH" | grep -qE "\.java$"; then
  if [ -f "backend/mvnw" ]; then
    cd backend 2>/dev/null
    # Quick compile check (no tests)
    ./mvnw compile -q 2>&1 | tail -5
    RESULT=${PIPESTATUS[0]}
    if [ $RESULT -ne 0 ]; then
      echo "LINT WARNING: Java compilation error detected. Check the file."
    fi
    cd - >/dev/null 2>&1
  fi
fi

# TypeScript/JavaScript files — quick ESLint
if echo "$FILE_PATH" | grep -qE "\.(ts|tsx|js|jsx)$"; then
  if [ -f "frontend/node_modules/.bin/eslint" ]; then
    cd frontend 2>/dev/null
    RELATIVE_PATH=$(echo "$FILE_PATH" | sed 's|.*/frontend/||')
    npx eslint "$RELATIVE_PATH" --quiet 2>&1 | tail -5
    cd - >/dev/null 2>&1
  fi
fi

# SQL migration files — basic syntax check
if echo "$FILE_PATH" | grep -qE "\.sql$"; then
  # Check for common SQL issues
  if grep -qiE "DROP TABLE|DROP DATABASE|TRUNCATE" "$FILE_PATH" 2>/dev/null; then
    echo "LINT WARNING: Destructive SQL operation detected in migration. Please verify this is intentional."
  fi
fi

exit 0
