#!/bin/bash
# List all active git worktrees with their branch and status
set -e

echo "=== Active Worktrees ==="
echo ""

git worktree list --porcelain | while IFS= read -r line; do
  case "$line" in
    worktree\ *)
      DIR="${line#worktree }"
      ;;
    branch\ *)
      BRANCH="${line#branch refs/heads/}"
      echo "  $BRANCH"
      echo "    Dir: $DIR"
      # Show uncommitted changes count
      CHANGES=$(cd "$DIR" && git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
      if [ "$CHANGES" -gt 0 ]; then
        echo "    Changes: $CHANGES uncommitted files"
      else
        echo "    Changes: clean"
      fi
      echo ""
      ;;
  esac
done
