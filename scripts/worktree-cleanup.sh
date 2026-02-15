#!/bin/bash
# Remove a git worktree after feature is merged/done
# Usage: bash scripts/worktree-cleanup.sh <feature-name>
set -e

FEATURE_NAME="$1"
if [ -z "$FEATURE_NAME" ]; then
  echo "Usage: bash scripts/worktree-cleanup.sh <feature-name>"
  echo ""
  echo "Active worktrees:"
  git worktree list
  exit 1
fi

BRANCH_NAME="feature/${FEATURE_NAME}"
WORKTREE_DIR="../worktrees/${FEATURE_NAME}"

echo "=== Cleaning Up Worktree ==="
echo "Feature: $FEATURE_NAME"
echo "Branch:  $BRANCH_NAME"
echo "Dir:     $WORKTREE_DIR"
echo ""

# Remove worktree
if [ -d "$WORKTREE_DIR" ]; then
  git worktree remove "$WORKTREE_DIR" --force
  echo "  ✓ Worktree removed"
else
  echo "  ⚠ Worktree directory not found, pruning..."
  git worktree prune
fi

# Ask about branch deletion
echo ""
read -p "Delete branch '$BRANCH_NAME'? (y/n): " DELETE_BRANCH
if [ "$DELETE_BRANCH" = "y" ]; then
  git branch -d "$BRANCH_NAME" 2>/dev/null || git branch -D "$BRANCH_NAME"
  echo "  ✓ Branch deleted"
else
  echo "  Branch kept: $BRANCH_NAME"
fi

echo ""
echo "=== Cleanup Complete ==="
echo ""
echo "Remaining worktrees:"
git worktree list
