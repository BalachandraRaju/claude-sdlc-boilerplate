#!/bin/bash
# Post-Bash hook: Run quality checks after git commit commands
# Only triggers on git commit commands, not all bash

INPUT="${TOOL_INPUT:-}"

# Only run after git commit commands
if ! echo "$INPUT" | grep -qE "git commit"; then
  exit 0
fi

echo "--- Post-Commit Quality Check ---"

# Check if backend files were committed
COMMITTED_FILES=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "")

BACKEND_CHANGED=false
FRONTEND_CHANGED=false

if echo "$COMMITTED_FILES" | grep -q "^backend/"; then
  BACKEND_CHANGED=true
fi
if echo "$COMMITTED_FILES" | grep -q "^frontend/"; then
  FRONTEND_CHANGED=true
fi

# Run backend formatting check
if [ "$BACKEND_CHANGED" = true ] && [ -f "backend/mvnw" ]; then
  cd backend
  if ! ./mvnw spotless:check -q 2>&1; then
    echo "WARNING: Backend code formatting issues detected."
    echo "Run: cd backend && ./mvnw spotless:apply"
  fi
  cd ..
fi

# Run frontend lint
if [ "$FRONTEND_CHANGED" = true ] && [ -f "frontend/node_modules/.bin/eslint" ]; then
  cd frontend
  if ! npx eslint src --quiet 2>&1; then
    echo "WARNING: Frontend lint issues detected."
    echo "Run: cd frontend && npm run lint:fix"
  fi
  cd ..
fi

exit 0
