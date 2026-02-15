#!/bin/bash
# Run all test suites — backend, frontend, and E2E
set -e

echo "=== Running All Tests ==="
FAILED=false

# Backend tests
echo ""
echo "=== Backend Tests ==="
if [ -f "backend/mvnw" ]; then
  cd backend
  if ./mvnw test 2>&1; then
    echo "  ✓ Backend tests passed"
  else
    echo "  ✗ Backend tests failed"
    FAILED=true
  fi
  cd ..
else
  echo "  ⚠ Skipped — no Maven wrapper"
fi

# Frontend tests
echo ""
echo "=== Frontend Tests ==="
if [ -f "frontend/package.json" ]; then
  cd frontend
  if npm test -- --run 2>&1; then
    echo "  ✓ Frontend tests passed"
  else
    echo "  ✗ Frontend tests failed"
    FAILED=true
  fi
  cd ..
else
  echo "  ⚠ Skipped — no package.json"
fi

# E2E tests
echo ""
echo "=== E2E Tests ==="
if [ -f "frontend/playwright.config.ts" ]; then
  cd frontend
  if npx playwright test 2>&1; then
    echo "  ✓ E2E tests passed"
  else
    echo "  ✗ E2E tests failed"
    FAILED=true
  fi
  cd ..
else
  echo "  ⚠ Skipped — no Playwright config"
fi

echo ""
if [ "$FAILED" = true ]; then
  echo "=== SOME TESTS FAILED ==="
  exit 1
else
  echo "=== ALL TESTS PASSED ==="
fi
