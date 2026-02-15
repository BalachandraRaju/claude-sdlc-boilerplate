#!/bin/bash
# Build both backend and frontend locally
set -e

echo "=== Local Build ==="
FAILED=false

# Backend build
echo ""
echo "=== Backend Build ==="
if [ -f "backend/mvnw" ]; then
  cd backend
  if ./mvnw clean package -DskipTests -q 2>&1; then
    JAR=$(ls target/*.jar 2>/dev/null | head -1)
    if [ -n "$JAR" ]; then
      SIZE=$(du -h "$JAR" | cut -f1)
      echo "  ✓ Backend build successful: $JAR ($SIZE)"
    else
      echo "  ✗ Build ran but no JAR found"
      FAILED=true
    fi
  else
    echo "  ✗ Backend build failed"
    FAILED=true
  fi
  cd ..
else
  echo "  ⚠ Skipped — no Maven wrapper"
fi

# Frontend build
echo ""
echo "=== Frontend Build ==="
if [ -f "frontend/package.json" ]; then
  cd frontend
  npm install --silent 2>&1
  if npm run build 2>&1; then
    if [ -d "dist" ]; then
      SIZE=$(du -sh dist | cut -f1)
      echo "  ✓ Frontend build successful: dist/ ($SIZE)"
    else
      echo "  ✗ Build ran but no dist/ found"
      FAILED=true
    fi
  else
    echo "  ✗ Frontend build failed"
    FAILED=true
  fi
  cd ..
else
  echo "  ⚠ Skipped — no package.json"
fi

echo ""
if [ "$FAILED" = true ]; then
  echo "=== BUILD FAILED ==="
  exit 1
else
  echo "=== BUILD SUCCESSFUL ==="
fi
