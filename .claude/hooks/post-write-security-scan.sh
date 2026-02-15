#!/bin/bash
# Post-Write/Edit hook: Scan for common security anti-patterns
# Catches hardcoded secrets, SQL injection, XSS, and insecure patterns

TOOL_INPUT="${TOOL_INPUT:-}"

FILE_PATH=""
if echo "$TOOL_INPUT" | grep -q '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

# Skip non-code files
case "$FILE_PATH" in
  *.md|*.json|*.yml|*.yaml|*.xml|*.txt|*.sh|*.env*|*.gitignore|*.css|*.html)
    exit 0
    ;;
esac

ISSUES=""

# --- Java Security Checks ---
if echo "$FILE_PATH" | grep -qE "\.java$"; then

  # Hardcoded secrets
  if grep -nE '(password|secret|apiKey|token|api_key)\s*=\s*"[^"]{3,}"' "$FILE_PATH" 2>/dev/null | grep -viE '(test|mock|example|placeholder|TODO)'; then
    ISSUES="${ISSUES}\n  CRITICAL: Possible hardcoded secret/password detected"
  fi

  # SQL string concatenation (injection risk)
  if grep -nE '"\s*\+\s*.*\+\s*".*([Ss][Ee][Ll][Ee][Cc][Tt]|[Ii][Nn][Ss][Ee][Rr][Tt]|[Uu][Pp][Dd][Aa][Tt][Ee]|[Dd][Ee][Ll][Ee][Tt][Ee])' "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  CRITICAL: SQL string concatenation detected — use parameterized queries"
  fi

  # Missing @Valid on controller params
  if grep -nE '@(Post|Put|Patch)Mapping' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then
    if grep -nE '@RequestBody\s+(?!@Valid)' "$FILE_PATH" 2>/dev/null; then
      ISSUES="${ISSUES}\n  WARNING: @RequestBody without @Valid — add input validation"
    fi
  fi

  # Controller returning raw objects instead of ApiResponse
  if grep -nE '@(Get|Post|Put|Delete|Patch)Mapping' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then
    if grep -nE 'public\s+(List|String|Map|[A-Z][a-z]+Dto)\s' "$FILE_PATH" 2>/dev/null | grep -v 'ResponseEntity\|ApiResponse' | head -3; then
      ISSUES="${ISSUES}\n  WARNING: Controller method returns raw object — use ResponseEntity<ApiResponse<T>>"
    fi
  fi

  # @Autowired on fields
  if grep -nE '^\s*@Autowired' "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  WARNING: @Autowired on field — use constructor injection instead"
  fi

fi

# --- TypeScript/React Security Checks ---
if echo "$FILE_PATH" | grep -qE "\.(ts|tsx)$"; then

  # dangerouslySetInnerHTML
  if grep -nE 'dangerouslySetInnerHTML' "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  CRITICAL: dangerouslySetInnerHTML detected — XSS risk"
  fi

  # any type usage
  if grep -nE ':\s*any\b|<any>|as\s+any' "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  WARNING: 'any' type detected — use proper TypeScript types"
  fi

  # Direct axios import in components (should use services)
  if echo "$FILE_PATH" | grep -qE "(components|pages)/.*\.(ts|tsx)$"; then
    if grep -nE "import.*from\s+['\"]axios['\"]" "$FILE_PATH" 2>/dev/null; then
      ISSUES="${ISSUES}\n  WARNING: Direct axios import in component — use service functions from src/services/"
    fi
  fi

  # Hardcoded API URLs
  if grep -nE "(http://|https://)[a-z].*api" "$FILE_PATH" 2>/dev/null | grep -viE '(test|mock|example|localhost|VITE_)'; then
    ISSUES="${ISSUES}\n  WARNING: Hardcoded API URL — use VITE_API_URL environment variable"
  fi

  # console.log left in code
  if grep -nE 'console\.(log|debug|info|warn|error)' "$FILE_PATH" 2>/dev/null | grep -viE '(test|spec)'; then
    ISSUES="${ISSUES}\n  WARNING: console.log in production code — remove before commit"
  fi

  # localStorage for sensitive data
  if grep -nE "localStorage\.setItem\(.*[Pp]assword" "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  CRITICAL: Storing password in localStorage — use secure httpOnly cookies"
  fi

fi

# --- SQL Security Checks ---
if echo "$FILE_PATH" | grep -qE "\.sql$"; then
  if grep -nE 'GRANT\s+ALL' "$FILE_PATH" 2>/dev/null; then
    ISSUES="${ISSUES}\n  WARNING: GRANT ALL detected — use least-privilege permissions"
  fi
fi

# Print results
if [ -n "$ISSUES" ]; then
  echo "SECURITY SCAN — issues found in $FILE_PATH:"
  echo -e "$ISSUES"
  echo ""
  echo "Fix CRITICAL issues before proceeding. See CLAUDE.md 'Security-First Development'."
fi

exit 0
