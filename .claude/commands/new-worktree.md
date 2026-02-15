# New Worktree

Create an isolated git worktree for a feature, so work on different features doesn't conflict.

## Instructions

### Step 1: Determine the Feature Name
Use the feature name from `$ARGUMENTS`. If no argument provided, ask the user:
- "What feature are you working on? This will be used for the branch name (`feature/<name>`) and worktree directory."

### Step 2: Check Prerequisites
- Verify this is a git repository: `git rev-parse --git-dir`
- Verify at least one commit exists: `git rev-parse HEAD`
- If not, tell the user what to do first

### Step 3: Create the Worktree
```bash
bash scripts/worktree-new.sh <feature-name>
```

This creates:
- Branch: `feature/<feature-name>`
- Directory: `../worktrees/<feature-name>/` (sibling to main repo)
- Full copy of the codebase on the new branch

### Step 4: Set Up the Worktree
Tell the user to navigate to the worktree and start Claude Code there:
```bash
cd ../worktrees/<feature-name>
claude
```

### Step 5: Create Feature Scaffolding
In the new worktree, create:
- `docs/prd/PRD-<feature-name>.md` (if it doesn't exist — prompt to generate)
- `docs/implementation/IMPL-<feature-name>.md` (implementation doc — generate after plan mode)
- `docs/diagrams/<feature-name>/` directory for Excalidraw diagrams

### Useful Info
- List all worktrees: `bash scripts/worktree-list.sh`
- Clean up when done: `bash scripts/worktree-cleanup.sh <feature-name>`
- Each worktree is fully independent — you can run different features in parallel
- Worktrees share the same `.git` history — commits from any worktree are visible everywhere

$ARGUMENTS
