#!/bin/bash
# Create a new git worktree for a feature branch
# Usage: bash scripts/worktree-new.sh <feature-name>
set -e

FEATURE_NAME="$1"
if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: bash scripts/worktree-new.sh <feature-name>"
  echo "Example: bash scripts/worktree-new.sh user-profile"
  exit 1
fi

# Sanitize feature name for branch/directory naming
BRANCH_NAME="feature/${FEATURE_NAME}"
WORKTREE_DIR="../worktrees/${FEATURE_NAME}"

# Ensure we're in a git repo
if ! git rev-parse --git-dir > /dev/null 2>&1; then
  echo "Error: Not a git repository. Run 'git init' first."
  exit 1
fi

# Ensure main branch has at least one commit
if ! git rev-parse HEAD > /dev/null 2>&1; then
  echo "Error: No commits yet. Make an initial commit first."
  exit 1
fi

# Check if branch already exists
if git show-ref --verify --quiet "refs/heads/${BRANCH_NAME}"; then
  echo "Branch '${BRANCH_NAME}' already exists."
  echo "Checking if worktree exists..."
  if [ -d "$WORKTREE_DIR" ]; then
    echo "Worktree already exists at: $(cd "$WORKTREE_DIR" && pwd)"
    echo "To enter: cd $WORKTREE_DIR"
    exit 0
  else
    echo "Creating worktree for existing branch..."
    git worktree add "$WORKTREE_DIR" "$BRANCH_NAME"
  fi
else
  # Create new branch and worktree
  echo "Creating branch: $BRANCH_NAME"
  echo "Creating worktree at: $WORKTREE_DIR"
  git worktree add -b "$BRANCH_NAME" "$WORKTREE_DIR"
fi

ABSOLUTE_PATH=$(cd "$WORKTREE_DIR" && pwd)

echo ""
echo "=== Worktree Created ==="
echo "Branch:    $BRANCH_NAME"
echo "Directory: $ABSOLUTE_PATH"
echo ""
echo "Next steps:"
echo "  cd $ABSOLUTE_PATH"
echo "  claude   # Start Claude Code in the worktree"
echo ""
echo "When done:"
echo "  bash scripts/worktree-cleanup.sh $FEATURE_NAME"
echo "  # Or merge: git checkout main && git merge $BRANCH_NAME"
