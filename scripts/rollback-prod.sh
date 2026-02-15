#!/bin/bash
# Rollback production to previous version
set -e

echo "=== Production Rollback ==="
echo ""
echo "⚠ Rolling back production to previous version"

# Get previous version from git tags
CURRENT_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "unknown")
PREVIOUS_TAG=$(git describe --tags --abbrev=0 "$CURRENT_TAG^" 2>/dev/null || echo "unknown")

echo "Current: $CURRENT_TAG"
echo "Rolling back to: $PREVIOUS_TAG"

if [ "$PREVIOUS_TAG" = "unknown" ]; then
  echo "  ✗ Cannot determine previous version. Manual rollback required."
  exit 1
fi

# Safety confirmation
read -p "Type 'rollback' to confirm: " CONFIRMATION
if [ "$CONFIRMATION" != "rollback" ]; then
  echo "Rollback cancelled."
  exit 1
fi

echo ""
echo "--- Rolling Back ---"
echo "  ⚠ TODO: Add your rollback commands here. Examples:"
echo "    kubectl rollout undo deployment/$APP_NAME --namespace=production"
echo "    aws ecs update-service --cluster production --service $APP_NAME --task-definition $APP_NAME:$PREVIOUS_VERSION"

echo ""
echo "=== Rollback Complete ==="
echo "Verify: https://${PROD_HOST:-app.example.com}"
