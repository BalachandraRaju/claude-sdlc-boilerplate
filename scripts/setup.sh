#!/bin/bash
# First-time project setup script
set -e

echo "=== SDLC Project Setup ==="

# Check prerequisites
echo ""
echo "Checking prerequisites..."

check_command() {
  if command -v "$1" &> /dev/null; then
    echo "  ✓ $1 found: $($1 --version 2>&1 | head -1)"
  else
    echo "  ✗ $1 not found — please install it"
    MISSING=true
  fi
}

MISSING=false
check_command java
check_command node
check_command npm
check_command psql
check_command git

if [ "$MISSING" = true ]; then
  echo ""
  echo "Please install missing prerequisites and re-run this script."
  exit 1
fi

# Backend setup
echo ""
echo "=== Backend Setup ==="
if [ -f "backend/mvnw" ]; then
  cd backend
  chmod +x mvnw
  echo "Building backend..."
  ./mvnw clean compile -q
  echo "  ✓ Backend builds successfully"
  cd ..
else
  echo "  ⚠ No Maven wrapper found. Run from project root after backend is scaffolded."
fi

# Frontend setup
echo ""
echo "=== Frontend Setup ==="
if [ -f "frontend/package.json" ]; then
  cd frontend
  echo "Installing frontend dependencies..."
  npm install
  echo "  ✓ Frontend dependencies installed"
  cd ..
else
  echo "  ⚠ No package.json found. Run from project root after frontend is scaffolded."
fi

# Database setup
echo ""
echo "=== Database Setup ==="
if psql -lqt 2>/dev/null | cut -d \| -f 1 | grep -qw myapp; then
  echo "  ✓ Database 'myapp' already exists"
else
  echo "Creating database 'myapp'..."
  createdb myapp 2>/dev/null && echo "  ✓ Database created" || echo "  ⚠ Could not create database. Create it manually: createdb myapp"
fi

# Git setup
echo ""
echo "=== Git Setup ==="
if [ -d ".git" ]; then
  echo "  ✓ Git repository already initialized"
else
  git init
  echo "  ✓ Git repository initialized"
fi

# Make hook scripts executable
echo ""
echo "=== Hook Scripts ==="
chmod +x .claude/hooks/*.sh 2>/dev/null && echo "  ✓ Hook scripts made executable" || echo "  ⚠ No hook scripts found"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Next steps:"
echo "  1. Update .mcp.json with your API keys"
echo "  2. Update backend/src/main/resources/application.yml with DB credentials"
echo "  3. Run: claude to start Claude Code"
echo "  4. Try: /full-sdlc to run the complete SDLC pipeline"
