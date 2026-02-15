#!/bin/bash
# Deploy to production environment
# REQUIRES manual confirmation
set -e

echo "=== Deploy to Production ==="
echo ""
echo "⚠⚠⚠  PRODUCTION DEPLOYMENT  ⚠⚠⚠"
echo ""

# Safety check — require explicit confirmation
if [ "$1" != "--confirm" ]; then
  echo "This will deploy to PRODUCTION and affect live users."
  echo ""
  read -p "Type 'deploy-prod' to confirm: " CONFIRMATION
  if [ "$CONFIRMATION" != "deploy-prod" ]; then
    echo "Deployment cancelled."
    exit 1
  fi
fi

# Configuration
PROD_HOST="${PROD_HOST:-app.example.com}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-your-registry.com}"
APP_NAME="${APP_NAME:-myapp}"
VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

echo ""
echo "Version: $VERSION"
echo "Target: $PROD_HOST"

# Step 1: Final checks
echo ""
echo "--- Final Pre-Deploy Checks ---"
if [ -f "scripts/run-all-tests.sh" ]; then
  bash scripts/run-all-tests.sh || { echo "  ✗ Tests failed. Aborting production deploy."; exit 1; }
fi

# Step 2: Tag the release
echo ""
echo "--- Tagging Release ---"
git tag -a "v$VERSION" -m "Production release $VERSION" 2>/dev/null || echo "  Tag already exists"

# Step 3: Build and push
echo ""
echo "--- Building Production Images ---"
echo "  ⚠ TODO: Add your production build commands here"
echo "  Examples:"
echo "    docker build --target production -t $DOCKER_REGISTRY/$APP_NAME-backend:$VERSION backend/"
echo "    docker push $DOCKER_REGISTRY/$APP_NAME-backend:$VERSION"

# Step 4: Deploy
echo ""
echo "--- Deploying ---"
echo "  ⚠ TODO: Add your production deployment commands here"
echo "  Examples:"
echo "    kubectl set image deployment/$APP_NAME backend=$DOCKER_REGISTRY/$APP_NAME-backend:$VERSION --namespace=production"
echo "    aws ecs update-service --cluster production --service $APP_NAME --force-new-deployment"

# Step 5: Health check
echo ""
echo "--- Health Check ---"
echo "  Waiting 30 seconds for startup..."
sleep 30
if curl -sf "https://$PROD_HOST/api/v1/health" > /dev/null 2>&1; then
  echo "  ✓ Production is healthy"
else
  echo "  ⚠ Health check failed!"
  echo "  Consider rolling back: bash scripts/rollback-prod.sh"
fi

echo ""
echo "=== Production Deployment Complete ==="
echo "URL: https://$PROD_HOST"
echo "Version: $VERSION"
