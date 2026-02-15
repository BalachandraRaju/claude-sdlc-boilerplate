#!/bin/bash
# Pre-Write/Edit hook: Enforce SDLC process before code can be written
# Checks that PRD, test plan, and implementation doc exist before implementation code is written

TOOL_INPUT="${TOOL_INPUT:-}"

# Extract file path from tool input
FILE_PATH=""
if echo "$TOOL_INPUT" | grep -q '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Only check implementation code — skip docs, tests, configs, templates, scripts
case "$FILE_PATH" in
  */docs/*|*/test/*|*/tests/*|*Test.java|*.test.ts|*.test.tsx|*.spec.ts|*.spec.tsx)
    exit 0
    ;;
  */.claude/*|*/scripts/*|*template*|*.md|*.json|*.yml|*.yaml|*.xml|*.sh|*.sql|*.css|*.html)
    exit 0
    ;;
esac

# Only check backend Java source and frontend TypeScript source
IS_BACKEND=false
IS_FRONTEND=false

if echo "$FILE_PATH" | grep -qE "backend/src/main/java/.*\.java$"; then
  IS_BACKEND=true
fi
if echo "$FILE_PATH" | grep -qE "frontend/src/.*\.(ts|tsx)$"; then
  IS_FRONTEND=true
fi

if [ "$IS_BACKEND" = false ] && [ "$IS_FRONTEND" = false ]; then
  exit 0
fi

# Skip common package files that don't need PRDs
case "$FILE_PATH" in
  */common/ApiResponse.java|*/common/ApiError.java|*/common/PagedResponse.java)
    exit 0
    ;;
  */common/PaginationParams.java|*/common/ErrorCode.java|*/common/GlobalExceptionHandler.java)
    exit 0
    ;;
  */config/*|*/security/*|*/Application.java)
    exit 0
    ;;
  */services/api.ts|*/types/api.ts|*/main.tsx|*/App.tsx)
    exit 0
    ;;
esac

# Check: Does at least one PRD exist?
PRD_COUNT=$(find docs/prd -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$PRD_COUNT" = "0" ] || [ ! -d "docs/prd" ]; then
  echo "WARNING: No PRD found in docs/prd/."
  echo "Writing implementation code without a PRD risks building the wrong thing."
  echo "Consider running /generate-prd first."
fi

# Check: Does at least one implementation doc exist?
IMPL_COUNT=$(find docs/implementation -name "IMPL-*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$IMPL_COUNT" = "0" ] || [ ! -d "docs/implementation" ]; then
  echo "WARNING: No implementation doc found in docs/implementation/."
  echo "Create one from the template before implementing."
fi

# Check: Does at least one test plan exist?
TEST_PLAN_COUNT=$(find docs/test-plans -name "TEST-*.md" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TEST_PLAN_COUNT" = "0" ] || [ ! -d "docs/test-plans" ]; then
  echo "WARNING: No test plan found in docs/test-plans/."
  echo "Generate a test plan from the PRD with /generate-tests before implementing."
fi

exit 0
