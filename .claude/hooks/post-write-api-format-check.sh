#!/bin/bash
# Post-Write/Edit hook: Enforce uniform API response format
# Checks that controllers use ApiResponse<T> and frontend uses unwrapResponse/extractError

TOOL_INPUT="${TOOL_INPUT:-}"

FILE_PATH=""
if echo "$TOOL_INPUT" | grep -q '"file_path"'; then
  FILE_PATH=$(echo "$TOOL_INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
  exit 0
fi

ISSUES=""

# --- Backend Controller Check ---
if echo "$FILE_PATH" | grep -qE "controller/.*\.java$|Controller\.java$"; then

  # Check: Controller methods should return ResponseEntity<ApiResponse<...>>
  if grep -nE '@(Get|Post|Put|Delete|Patch)Mapping' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then

    # Methods returning ResponseEntity without ApiResponse
    RAW_RETURNS=$(grep -nE 'ResponseEntity<(?!ApiResponse)' "$FILE_PATH" 2>/dev/null || true)
    if [ -n "$RAW_RETURNS" ]; then
      ISSUES="${ISSUES}\n  WARNING: Controller returns ResponseEntity without ApiResponse wrapper"
      ISSUES="${ISSUES}\n  Use: ResponseEntity<ApiResponse<YourDto>> instead"
      ISSUES="${ISSUES}\n  $RAW_RETURNS"
    fi

    # Methods not using ResponseEntity at all
    RAW_METHODS=$(grep -nE 'public\s+(List|String|Map|Optional|[A-Z][a-z]+Dto)\s+\w+\(' "$FILE_PATH" 2>/dev/null || true)
    if [ -n "$RAW_METHODS" ]; then
      ISSUES="${ISSUES}\n  WARNING: Controller method returns raw type — wrap in ResponseEntity<ApiResponse<T>>"
      ISSUES="${ISSUES}\n  $RAW_METHODS"
    fi

    # Check for try/catch in controllers (should use GlobalExceptionHandler)
    TRYCATCH=$(grep -nE '^\s*try\s*\{' "$FILE_PATH" 2>/dev/null || true)
    if [ -n "$TRYCATCH" ]; then
      ISSUES="${ISSUES}\n  WARNING: try/catch in controller — let GlobalExceptionHandler handle exceptions"
    fi
  fi

  # Check: ApiResponse import present
  if ! grep -qE 'import com\.app\.common\.ApiResponse' "$FILE_PATH" 2>/dev/null; then
    if grep -qE '@(RestController|Controller)' "$FILE_PATH" 2>/dev/null; then
      ISSUES="${ISSUES}\n  WARNING: Controller does not import ApiResponse — all endpoints must use it"
    fi
  fi
fi

# --- Backend Service Check ---
if echo "$FILE_PATH" | grep -qE "service/.*\.java$|Service\.java$"; then

  # Check: List endpoints should use Pageable
  if grep -nE 'List<.*>\s+\w+All\(' "$FILE_PATH" 2>/dev/null | grep -v 'Pageable\|Page<' > /dev/null 2>&1; then
    ISSUES="${ISSUES}\n  WARNING: Service returns List without pagination — use Page<T> with Pageable parameter"
  fi
fi

# --- Frontend Service Check ---
if echo "$FILE_PATH" | grep -qE "services/.*\.(ts|tsx)$"; then
  # Skip the base api.ts file
  if ! echo "$FILE_PATH" | grep -qE "services/api\.ts$"; then

    # Check: Service functions should use unwrapResponse
    if grep -nE 'api\.(get|post|put|delete|patch)' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then
      if ! grep -qE 'unwrapResponse' "$FILE_PATH" 2>/dev/null; then
        ISSUES="${ISSUES}\n  WARNING: API service does not use unwrapResponse() — import from './api'"
      fi
    fi

    # Check: Should import ApiResponse type
    if grep -nE 'api\.(get|post|put|delete|patch)' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then
      if ! grep -qE "ApiResponse" "$FILE_PATH" 2>/dev/null; then
        ISSUES="${ISSUES}\n  WARNING: API service does not type responses as ApiResponse<T>"
      fi
    fi
  fi
fi

# --- Frontend Component Error Handling Check ---
if echo "$FILE_PATH" | grep -qE "(components|pages)/.*\.(ts|tsx)$"; then
  # Check: Components catching errors should use extractError
  if grep -nE 'catch\s*\(' "$FILE_PATH" 2>/dev/null | head -1 > /dev/null; then
    if ! grep -qE 'extractError' "$FILE_PATH" 2>/dev/null; then
      ISSUES="${ISSUES}\n  WARNING: Component catches errors but doesn't use extractError() — import from '../services/api'"
    fi
  fi
fi

if [ -n "$ISSUES" ]; then
  echo "API FORMAT CHECK — issues in $FILE_PATH:"
  echo -e "$ISSUES"
  echo ""
  echo "See CLAUDE.md 'Uniform API Response Format' for the standard."
fi

exit 0
