#!/bin/bash
# Deploy to staging environment
# Customize this script for your infrastructure (Docker, K8s, AWS, etc.)
set -e

echo "=== Deploy to Staging ==="

# Configuration — customize these for your setup
STAGING_HOST="${STAGING_HOST:-staging.example.com}"
DOCKER_REGISTRY="${DOCKER_REGISTRY:-your-registry.com}"
APP_NAME="${APP_NAME:-myapp}"
VERSION=$(git rev-parse --short HEAD 2>/dev/null || echo "latest")

echo "Version: $VERSION"
echo "Target: $STAGING_HOST"

# Step 1: Build Docker images (if using Docker)
echo ""
echo "--- Building Docker images ---"
if [ -f "docker-compose.yml" ]; then
  docker compose build --quiet 2>&1
  echo "  ✓ Docker images built"
elif [ -f "backend/Dockerfile" ]; then
  docker build -t "$DOCKER_REGISTRY/$APP_NAME-backend:$VERSION" backend/ 2>&1
  docker build -t "$DOCKER_REGISTRY/$APP_NAME-frontend:$VERSION" frontend/ 2>&1
  echo "  ✓ Docker images built"
else
  echo "  ⚠ No Dockerfile found. Customize this script for your deployment method."
  echo "  Possible options:"
  echo "    - Add a Dockerfile to backend/ and frontend/"
  echo "    - Use docker-compose.yml"
  echo "    - Deploy JAR + static files directly"
  exit 1
fi

# Step 2: Push images
echo ""
echo "--- Pushing images ---"
docker push "$DOCKER_REGISTRY/$APP_NAME-backend:$VERSION" 2>&1 || echo "  ⚠ Push failed — configure DOCKER_REGISTRY"
docker push "$DOCKER_REGISTRY/$APP_NAME-frontend:$VERSION" 2>&1 || echo "  ⚠ Push failed — configure DOCKER_REGISTRY"

# Step 3: Deploy (customize for your orchestrator)
echo ""
echo "--- Deploying to staging ---"
echo "  ⚠ TODO: Add your deployment commands here. Examples:"
echo "    kubectl set image deployment/$APP_NAME backend=$DOCKER_REGISTRY/$APP_NAME-backend:$VERSION"
echo "    aws ecs update-service --cluster staging --service $APP_NAME --force-new-deployment"
echo "    ssh $STAGING_HOST 'docker compose pull && docker compose up -d'"

# Step 4: Health check
echo ""
echo "--- Health Check ---"
echo "  Waiting 10 seconds for startup..."
sleep 10
if curl -sf "https://$STAGING_HOST/api/v1/health" > /dev/null 2>&1; then
  echo "  ✓ Staging is healthy"
else
  echo "  ⚠ Health check failed or endpoint not configured"
  echo "  Verify manually: https://$STAGING_HOST"
fi

echo ""
echo "=== Staging Deployment Complete ==="
echo "URL: https://$STAGING_HOST"
