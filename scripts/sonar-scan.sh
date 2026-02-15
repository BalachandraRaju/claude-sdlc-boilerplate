#!/bin/bash
# Run SonarQube analysis
# Prerequisites: SonarQube server running, sonar-scanner installed
set -e

SONAR_HOST="${SONAR_HOST_URL:-http://localhost:9000}"
SONAR_TOKEN="${SONAR_TOKEN:-}"
PROJECT_KEY="${SONAR_PROJECT_KEY:-claude-sdlc}"

echo "=== SonarQube Analysis ==="
echo "Host: $SONAR_HOST"
echo "Project: $PROJECT_KEY"

if [ -z "$SONAR_TOKEN" ]; then
  echo "⚠ SONAR_TOKEN not set. Set it via: export SONAR_TOKEN=your_token"
  echo "Attempting without authentication..."
fi

# Backend analysis with Maven
echo ""
echo "=== Backend Analysis ==="
if [ -f "backend/mvnw" ]; then
  cd backend
  ./mvnw clean verify sonar:sonar \
    -Dsonar.host.url="$SONAR_HOST" \
    -Dsonar.projectKey="${PROJECT_KEY}-backend" \
    ${SONAR_TOKEN:+-Dsonar.token="$SONAR_TOKEN"} \
    -q 2>&1
  echo "  ✓ Backend analysis complete"
  cd ..
else
  echo "  ⚠ Skipped — no Maven wrapper"
fi

# Frontend analysis with sonar-scanner
echo ""
echo "=== Frontend Analysis ==="
if command -v sonar-scanner &> /dev/null && [ -f "frontend/package.json" ]; then
  cd frontend
  sonar-scanner \
    -Dsonar.host.url="$SONAR_HOST" \
    -Dsonar.projectKey="${PROJECT_KEY}-frontend" \
    -Dsonar.sources=src \
    -Dsonar.tests=tests \
    -Dsonar.javascript.lcov.reportPaths=coverage/lcov.info \
    ${SONAR_TOKEN:+-Dsonar.token="$SONAR_TOKEN"} \
    2>&1
  echo "  ✓ Frontend analysis complete"
  cd ..
else
  echo "  ⚠ Skipped — sonar-scanner not installed or no package.json"
fi

echo ""
echo "=== Analysis Complete ==="
echo "View results at: $SONAR_HOST/dashboard?id=$PROJECT_KEY"
