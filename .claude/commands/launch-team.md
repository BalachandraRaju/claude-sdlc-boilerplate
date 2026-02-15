# Launch Multi-Agent Team

Spin up a full team of agents to implement a feature in parallel.

## Instructions

This command creates a multi-agent team with proper task dependencies. Agents work in parallel where possible and sequentially where outputs feed into the next step.

### Step 0: Create Git Worktree
Ask the user using `AskUserQuestion`:
> "Should I create a git worktree for this feature? This gives an isolated branch + directory so parallel features don't conflict."
>
> Options: "Yes, create worktree (Recommended)" / "No, work on current branch"

If yes:
```bash
bash scripts/worktree-new.sh <feature-name>
```
Then tell the user:
> "Worktree created at `../worktrees/<feature-name>/`. Navigate there and run `claude` to start working in isolation."

If working in a worktree, all subsequent work happens in that directory.

### Step 1: Understand the Feature
Read the user's feature description from `$ARGUMENTS`. Then:
- Check `docs/prd/` for an existing PRD for this feature
- If no PRD exists, ask: "No PRD found for this feature. Should I generate one first?"
- If PRD exists, read it fully before proceeding
- Check `docs/implementation/` for an existing implementation doc — if found, read it for context

### Step 2: Enter Plan Mode
Use `EnterPlanMode` to design the implementation plan:
- Break the feature into concrete tasks
- Identify which agent handles each task
- Map dependencies (what blocks what)
- Present the plan to the user for approval

### Step 3: Create Implementation Doc + Diagrams
Before writing any code:
1. Create `docs/implementation/IMPL-<feature-name>.md` from template
2. Generate architecture diagram: create `docs/diagrams/<feature-name>/architecture.excalidraw.json`
3. Generate data flow diagram if the feature involves API calls
4. Link diagrams in the implementation doc

### Step 4: Create the Team
After plan approval:
```
TeamCreate:
  team_name: "<feature-name>"
  description: "Implementing <feature-name>"
```

### Step 5: Create Tasks with Dependencies
Use `TaskCreate` for each task, then `TaskUpdate` to set `addBlockedBy` relationships.

**Key principle: Tests are interleaved with implementation, not deferred to a separate phase.**

**Phase 0 — Documentation (runs first)**:
```
Task 0: "Create implementation doc + diagrams"  → architect-agent
```

**Phase 1 — Backend (implementation + tests interleaved)**:
```
Task 1:  "Write Flyway DB migration"                     → backend-agent, blockedBy: [0]
Task 2:  "Implement JPA entities + repositories"          → backend-agent, blockedBy: [1]
Task 3:  "Write repository tests (Testcontainers)"        → test-agent, blockedBy: [2]
Task 4:  "Implement service layer"                        → backend-agent, blockedBy: [3]
Task 5:  "Write service unit tests"                       → test-agent, blockedBy: [4]
Task 6:  "Implement REST controllers + DTOs"              → backend-agent, blockedBy: [5]
Task 7:  "Write integration tests (full HTTP roundtrip)"  → test-agent, blockedBy: [6]
```

**Phase 2 — Frontend (implementation + tests interleaved, starts after controllers)**:
```
Task 8:  "Create API service functions"                   → frontend-agent, blockedBy: [6]
Task 9:  "Write API service tests"                        → test-agent, blockedBy: [8]
Task 10: "Build UI components + hooks"                    → frontend-agent, blockedBy: [9]
Task 11: "Write component tests"                          → test-agent, blockedBy: [10]
Task 12: "Build page components + routing"                → frontend-agent, blockedBy: [11]
Task 13: "Write E2E Playwright tests"                     → test-agent, blockedBy: [12, 7]
```

**Phase 3 — TODO Resolution + Full Test Suite**:
```
Task 14: "Resolve all TODOs in codebase"                  → backend-agent / frontend-agent, blockedBy: [13]
Task 15: "Run full test suite — fix any failures"         → test-agent, blockedBy: [14]
```

**Phase 4 — Quality (parallel, starts after all tests green)**:
```
Task 16: "Code review"                                    → review-agent, blockedBy: [15]
Task 17: "Security review"                                → security-agent, blockedBy: [15]
```

**Phase 5 — Fixes + Final Doc (after reviews)**:
```
Task 18: "Fix review + security findings"                 → backend-agent / frontend-agent, blockedBy: [16, 17]
Task 19: "Re-run full test suite after fixes"             → test-agent, blockedBy: [18]
Task 20: "Update implementation doc with final state"     → architect-agent, blockedBy: [19]
```

### Step 6: Spawn Agents
Use the `Task` tool with `team_name` and `subagent_type` to spawn each agent:

```
# Spawn all agents — they'll pick up unblocked tasks automatically
Task(subagent_type="general-purpose", team_name="<feature>", name="architect",
     prompt="You are architect-agent. Read .claude/agents/architect-agent.md and CLAUDE.md.
             Create implementation doc and Excalidraw diagrams for this feature.
             Check TaskList, claim your tasks, work through them.")

Task(subagent_type="general-purpose", team_name="<feature>", name="backend-dev",
     prompt="You are backend-agent. Read .claude/agents/backend-agent.md and CLAUDE.md.
             Read the implementation doc at docs/implementation/IMPL-<feature>.md for context.
             Check TaskList, claim backend tasks, implement them in order.")

Task(subagent_type="general-purpose", team_name="<feature>", name="frontend-dev",
     prompt="You are frontend-agent. Read .claude/agents/frontend-agent.md and CLAUDE.md.
             Read the implementation doc at docs/implementation/IMPL-<feature>.md for context.
             Check TaskList, claim frontend tasks, implement them in order.")

Task(subagent_type="general-purpose", team_name="<feature>", name="tester",
     prompt="You are test-agent. Read .claude/agents/test-agent.md and CLAUDE.md.
             Check TaskList, claim test tasks, write and run tests.")

Task(subagent_type="general-purpose", team_name="<feature>", name="security-reviewer",
     prompt="You are security-agent. Read .claude/agents/security-agent.md and CLAUDE.md.
             Check TaskList, claim security tasks, perform review.")

Task(subagent_type="general-purpose", team_name="<feature>", name="code-reviewer",
     prompt="You are review-agent. Read .claude/agents/review-agent.md and CLAUDE.md.
             Check TaskList, claim review tasks, perform code review.")
```

### Step 7: Monitor & Coordinate
- Watch for messages from agents (delivered automatically)
- When agents complete tasks, check if downstream tasks are unblocked
- Send messages to agents when their blockers are resolved
- If an agent is stuck, help unblock or reassign

### Step 8: Shutdown
When all tasks are complete:
1. Verify implementation doc is updated with final state (files changed, how to test)
2. Send `shutdown_request` to each agent
3. Update Linear issues to reflect completion
4. Use `TeamDelete` to clean up
5. Report final summary to user
6. Remind: "If working in a worktree, merge when ready: `git checkout main && git merge feature/<feature-name>`"

$ARGUMENTS
