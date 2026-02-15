#!/bin/bash
# Stop hook: Generate a summary of changes when agent finishes
# This runs when any Claude Code agent stops

SUMMARY_FILE="docs/.last-session-summary.md"

echo "## Session Summary — $(date '+%Y-%m-%d %H:%M')" > "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Git changes since last commit
if git rev-parse --git-dir > /dev/null 2>&1; then
  CHANGED_FILES=$(git diff --name-only 2>/dev/null)
  STAGED_FILES=$(git diff --cached --name-only 2>/dev/null)
  UNTRACKED=$(git ls-files --others --exclude-standard 2>/dev/null)

  if [ -n "$CHANGED_FILES" ] || [ -n "$STAGED_FILES" ] || [ -n "$UNTRACKED" ]; then
    echo "### Files Modified" >> "$SUMMARY_FILE"
    if [ -n "$STAGED_FILES" ]; then
      echo "**Staged:**" >> "$SUMMARY_FILE"
      echo "$STAGED_FILES" | sed 's/^/- /' >> "$SUMMARY_FILE"
    fi
    if [ -n "$CHANGED_FILES" ]; then
      echo "**Unstaged:**" >> "$SUMMARY_FILE"
      echo "$CHANGED_FILES" | sed 's/^/- /' >> "$SUMMARY_FILE"
    fi
    if [ -n "$UNTRACKED" ]; then
      echo "**New:**" >> "$SUMMARY_FILE"
      echo "$UNTRACKED" | sed 's/^/- /' >> "$SUMMARY_FILE"
    fi
  else
    echo "No file changes detected." >> "$SUMMARY_FILE"
  fi
else
  echo "Not a git repository — no change tracking available." >> "$SUMMARY_FILE"
fi

echo ""
echo "Session summary written to $SUMMARY_FILE"
exit 0
