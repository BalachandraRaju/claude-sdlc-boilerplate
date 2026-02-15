#!/bin/bash
# Hook: Post-write TODO check
# Warns if a file was written/edited containing TODO/FIXME/HACK/XXX without a Linear issue reference

TOOL_INPUT="${TOOL_INPUT:-}"

# Extract file path from tool input
FILE_PATH=""
if echo "$TOOL_INPUT" | grep -q '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-code files
case "$FILE_PATH" in
  *.md|*.json|*.yml|*.yaml|*.xml|*.txt|*.sh|*.env*|*.gitignore)
    exit 0
    ;;
esac

# Check for TODOs without Linear issue references
UNTRACKED_TODOS=$(grep -n -E '(TODO|FIXME|HACK|XXX)' "$FILE_PATH" 2>/dev/null | grep -v -E 'TODO\([A-Z]+-[0-9]+\)' || true)

if [ -n "$UNTRACKED_TODOS" ]; then
  echo "⚠ WARNING: Untracked TODOs found in $FILE_PATH:"
  echo "$UNTRACKED_TODOS"
  echo ""
  echo "Either resolve these TODOs now, or add a Linear issue reference: // TODO(LIN-123): description"
  echo "Run /resolve-todos to scan and fix all TODOs in the codebase."
fi

# Don't block the write — just warn
exit 0
