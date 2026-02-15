# SDLC Workflow — Multi-Agent Orchestration

This document describes how the agents, skills, and tools work together across the software development lifecycle.

## Agent Roster

| Agent | Role | Tools | MCP Servers |
|-------|------|-------|-------------|
| `prd-agent` | PRD generation, requirements | Read/Write, WebSearch | Linear, Figma |
| `architect-agent` | System design, DB schema, API design, diagrams | Read/Write | - |
| `backend-agent` | Java/Spring Boot implementation | Bash, Read/Write/Edit | PostgreSQL |
| `frontend-agent` | React/TypeScript implementation, mockups | Bash, Read/Write/Edit | Playwright, Figma, Browser |
| `test-agent` | Test generation, execution, browser automation | Bash, Read/Write | Playwright, Browser |
| `security-agent` | Security review and scanning | Bash, Read/Grep, WebSearch | Linear, Playwright |
| `review-agent` | Code review, PRD review, quality | Bash, Read/Grep | Linear |
| `devops-agent` | CI/CD, Docker, deployment | Bash, Read/Write | Linear |

## Critical Rules (ALL agents follow these)

1. **Plan Mode First** — Enter `EnterPlanMode` when requirements are unclear or task is non-trivial
2. **PRD is Source of Truth** — Always read `docs/prd/` before doing anything. Ask if no PRD exists.
3. **Ask, Don't Assume** — Use `AskUserQuestion` with concrete options. Never guess.
4. **Update CLAUDE.md + Memory** — Record new instructions/issues in both CLAUDE.md and memory.md
5. **Implementation Depth** — Never stop at high-level. Trace every action from button click to DB and back.
6. **Handle TODOs Immediately** — Resolve now or create Linear issue reference `TODO(LIN-123)`
7. **Update CLAUDE.md + Memory on New Instructions** — Every new user instruction updates both files
8. **Browser Automation After Every UI Test** — Use Playwright MCP to verify every UI change visually
9. **Uniform API Format** — All endpoints use `ApiResponse<T>`, all errors via `GlobalExceptionHandler`

## Pipeline Phases

```
┌─────────────────────────────────────────────────────────────────┐
│  Phase 1: REQUIREMENTS                                          │
│  ┌──────────┐    ┌──────────┐                                   │
│  │ PRD Gen  │───→│ PRD Review│───→ User Approval                │
│  │prd-agent │    │review-agt│                                   │
│  │ +Linear  │    │          │                                   │
│  └──────────┘    └──────────┘                                   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 2: DESIGN  (parallel)                                    │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │ Arch Doc │    │ Mockups  │    │ Figma    │                  │
│  │ +Diagrams│    │front-agt │    │ Extract  │                  │
│  │arch-agent│    │          │    │          │                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│         └────────────┼────────────────┘                         │
│                      ↓                                          │
│               User Approval                                     │
├─────────────────────────────────────────────────────────────────┤
│  Phase 3: TEST CASE GENERATION  ← /generate-tests               │
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │ Read PRD │───→│Build Test│───→│Write Test│                  │
│  │acceptance│    │ Matrix:  │    │Plan Doc  │                  │
│  │ criteria │    │criterion │    │          │                  │
│  │          │    │→ tests at│    │docs/test-│                  │
│  │test-agent│    │each layer│    │plans/    │                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│                                                                 │
│  Test matrix maps EACH acceptance criterion to:                 │
│  ┌────────────┬──────────┬──────────┬───────────┬─────────┐    │
│  │ Criterion  │ Unit(BE) │ Unit(FE) │ Integratn │  E2E    │    │
│  ├────────────┼──────────┼──────────┼───────────┼─────────┤    │
│  │ "User can  │ Service  │ Form     │ POST /api │ Fill    │    │
│  │  create    │ Test     │ render + │ → 201     │ form →  │    │
│  │  profile"  │ + Repo   │ submit   │ + DB chk  │ submit →│    │
│  │            │ Test     │ test     │ + headers │ verify  │    │
│  └────────────┴──────────┴──────────┴───────────┴─────────┘    │
│                                                                 │
│  Output: docs/test-plans/TEST-<feature>.md                      │
│  Every cell in the matrix = actual test code to write.          │
│  This plan drives ALL test steps in Phase 4.                    │
│                      ↓                                          │
│               User Approval of test plan                        │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4: IMPLEMENTATION + TESTING (interleaved)                │
│  Test-agent references test plan from Phase 3 at each step.     │
│                                                                 │
│  ┌──────────┐    ┌──────────┐                                   │
│  │DB Migrate│───→│ Entities │ (backend-agent)                   │
│  └──────────┘    │ + Repos  │                                   │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │Repo Tests│ (test-agent) ← from test plan     │
│                  │Testcontrs│                                    │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │ Services │ (backend-agent)                   │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │ Service  │ (test-agent) ← from test plan     │
│                  │  Tests   │                                   │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │Controller│ (backend-agent)                   │
│                  │ + DTOs   │                                   │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │Integrtn  │ (test-agent) ← from test plan     │
│                  │  Tests   │ verify ApiResponse format         │
│                  └────┬─────┘                                   │
│                       ↓                                         │
│  ┌──────────┐    ┌──────────┐                                   │
│  │API Svcs  │───→│ API Svc  │ (test-agent) ← from test plan    │
│  │front-agt │    │  Tests   │                                   │
│  └──────────┘    └────┬─────┘                                   │
│                       ↓                                         │
│  ┌──────────┐    ┌──────────┐                                   │
│  │Components│───→│Component │ (test-agent) ← from test plan    │
│  │ + Hooks  │    │Tests +   │ + Playwright browser automation   │
│  │front-agt │    │Browser   │                                   │
│  └──────────┘    └────┬─────┘                                   │
│                       ↓                                         │
│  ┌──────────┐    ┌──────────┐                                   │
│  │Pages +   │───→│E2E Tests │ (test-agent) ← from test plan    │
│  │ Routing  │    │Playwright│ full browser automation           │
│  │front-agt │    │          │ screenshot + click flows          │
│  └──────────┘    └──────────┘                                   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 5: VALIDATION                                            │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │Resolve   │───→│Verify    │───→│Full Test │───→│Browser   │  │
│  │All TODOs │    │test plan │    │  Suite   │    │Automation│  │
│  │back/front│    │coverage: │    │test-agent│    │Playwright│  │
│  │          │    │every PRD │    │          │    │ verify   │  │
│  │          │    │criterion │    │          │    │          │  │
│  │          │    │has tests │    │          │    │          │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│     All TODOs resolved + all criteria covered + all green       │
├─────────────────────────────────────────────────────────────────┤
│  Phase 6: QUALITY  (all parallel)                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │Code Revw │  │Sec Review│  │SonarQube │                      │
│  │review-agt│  │secur-agt │  │review-agt│                      │
│  └──────────┘  └──────────┘  └──────────┘                      │
│         └──────────┼──────────┘                                 │
│                    ↓                                            │
│              Fix Findings (backend/frontend agents)             │
│                    ↓                                            │
│              Re-run Full Test Suite (must stay green)            │
│                    ↓                                            │
│              Browser Automation (re-verify after fixes)          │
├─────────────────────────────────────────────────────────────────┤
│  Phase 7: DEPLOY                                                │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │Build Locl│───→│  Staging │───→│   Prod   │                  │
│  │devops-agt│    │devops-agt│    │devops-agt│                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│                                   ↑ User confirm required       │
├─────────────────────────────────────────────────────────────────┤
│  Phase 8: SHIP                                                  │
│  ┌──────────┐                                                   │
│  │Final Revw│───→ Update Linear ───→ Update Impl Doc ───→ Done  │
│  │review-agt│                                                   │
│  └──────────┘                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## How to Launch a Multi-Agent Team

### Quick Start
```
/launch-team <feature-name>
```

### Manual Setup (step by step)

**Step 1: Create team**
```
TeamCreate(team_name="user-profile", description="Implementing user profile feature")
```

**Step 2: Create tasks with dependencies (implementation + tests interleaved)**
```
# Phase 0 — Documentation
TaskCreate(subject="Create implementation doc + diagrams", ...)

# Phase 1 — Backend (implementation + tests interleaved)
TaskCreate(subject="Write Flyway DB migration", ...)                    # blockedBy: [0]
TaskCreate(subject="Implement JPA entities + repositories", ...)        # blockedBy: [1]
TaskCreate(subject="Write repository tests (Testcontainers)", ...)      # blockedBy: [2] ← TEST
TaskCreate(subject="Implement service layer", ...)                      # blockedBy: [3]
TaskCreate(subject="Write service unit tests", ...)                     # blockedBy: [4] ← TEST
TaskCreate(subject="Implement REST controllers + DTOs", ...)            # blockedBy: [5]
TaskCreate(subject="Write integration tests (HTTP roundtrip)", ...)     # blockedBy: [6] ← TEST

# Phase 2 — Frontend (implementation + tests interleaved)
TaskCreate(subject="Create API service functions", ...)                 # blockedBy: [6]
TaskCreate(subject="Write API service tests", ...)                      # blockedBy: [8] ← TEST
TaskCreate(subject="Build UI components + hooks", ...)                  # blockedBy: [9]
TaskCreate(subject="Write component tests + browser automation", ...)   # blockedBy: [10] ← TEST
TaskCreate(subject="Build page components + routing", ...)              # blockedBy: [11]
TaskCreate(subject="Write E2E Playwright tests + browser verify", ...)  # blockedBy: [12, 7] ← TEST

# Phase 3 — Validation
TaskCreate(subject="Resolve all TODOs in codebase", ...)                # blockedBy: [13]
TaskCreate(subject="Run full test suite + browser automation", ...)     # blockedBy: [14] ← VALIDATE

# Phase 4 — Quality (parallel)
TaskCreate(subject="Code review", ...)                                  # blockedBy: [15]
TaskCreate(subject="Security review", ...)                              # blockedBy: [15]

# Phase 5 — Fixes + Re-test + Final
TaskCreate(subject="Fix review + security findings", ...)               # blockedBy: [16, 17]
TaskCreate(subject="Re-run full test suite + browser verify", ...)      # blockedBy: [18] ← VALIDATE
TaskCreate(subject="Update implementation doc with final state", ...)   # blockedBy: [19]
```

**Step 3: Spawn agents**
Each agent gets spawned with `Task` tool:
```
Task(
  subagent_type="general-purpose",
  team_name="user-profile",
  name="backend-dev",
  prompt="You are the backend-agent. Read .claude/agents/backend-agent.md.
          Read CLAUDE.md for project standards.
          Check TaskList and claim tasks assigned to backend-agent.
          Work through them in order, respecting blockedBy dependencies.",
  mode="bypassPermissions"
)
```

Spawn multiple agents in a single message to run them in parallel:
```
# Send ONE message with multiple Task tool calls:
Task(name="backend-dev", ...)    # Handles backend tasks sequentially
Task(name="frontend-dev", ...)   # Waits for backend, then starts
Task(name="tester", ...)         # Writes + runs tests after EACH implementation step
Task(name="security-rev", ...)   # Waits for all tests green, then reviews
Task(name="code-rev", ...)       # Waits for all tests green, then reviews
```

**Step 4: Agents coordinate via TaskList + SendMessage**
- Agents check `TaskList` to find unblocked tasks
- Agents claim tasks with `TaskUpdate(taskId, owner="backend-dev")`
- Agents mark tasks done with `TaskUpdate(taskId, status="completed")`
- Agents send status via `SendMessage` to team lead
- Team lead sends `SendMessage` to reassign or unblock

**Step 5: Shutdown team**
```
SendMessage(type="shutdown_request", recipient="backend-dev")
SendMessage(type="shutdown_request", recipient="frontend-dev")
# ... for all agents
TeamDelete()
```

## Slash Commands Quick Reference

| Command | Phase | What It Does |
|---------|-------|--------------|
| `/generate-prd` | Requirements | Generate PRD + Linear issues |
| `/review-prd` | Requirements | Review PRD for completeness |
| `/generate-mockups` | Design | React component mockups (+ Figma extraction) |
| `/generate-diagram` | Design | Excalidraw architecture/flow/ER diagrams |
| `/generate-code` | Implementation | Multi-agent code generation with interleaved tests |
| `/generate-tests` | Testing | Test plan + automated tests at every layer |
| `/run-tests` | Testing | Execute all test suites, fix failures |
| `/review-code` | Quality | Code review with findings |
| `/security-review` | Quality | OWASP security analysis |
| `/analyze-code` | Quality | SonarQube + static analysis |
| `/resolve-todos` | Validation | Scan + fix all TODO/FIXME/HACK/XXX |
| `/fix-bugs` | Maintenance | Diagnose and fix bugs |
| `/fix-review` | Quality | Fix review/security findings |
| `/build-local` | Deploy | Build backend + frontend locally |
| `/deploy-staging` | Deploy | Full staging deploy with checks |
| `/deploy-prod` | Deploy | Production deploy (user confirm) |
| `/new-worktree` | Setup | Create isolated feature branch worktree |
| `/launch-team` | All | Spin up full multi-agent team |
| `/full-sdlc` | All | End-to-end pipeline |

## MCP Server Usage by Agent

| MCP Server | Used By | Purpose |
|------------|---------|---------|
| **Linear** | prd-agent, security-agent, review-agent, devops-agent | Issue tracking, PRD management, findings |
| **PostgreSQL** | backend-agent | Schema inspection, data queries |
| **Playwright** | test-agent, frontend-agent, security-agent | Browser automation, E2E tests, screenshots, visual verification |
| **Figma** | prd-agent, frontend-agent | Design tokens, component specs, screen layouts |
| **Browser** | test-agent, frontend-agent | Web page inspection, rendered output |
| **Filesystem** | All agents | Controlled file access for docs |

## Parallel vs Sequential Rules

**Must be sequential** (outputs feed into next step):
- PRD → PRD Review → Approval
- Design Approval → **Test Case Generation (test plan from PRD)** → Implementation
- Test Plan → DB Migration → Entities → Repo Tests → Services → Service Tests → Controllers → Integration Tests
- Test Plan → API Services → API Service Tests → UI Components → Component Tests → Pages → E2E Tests
- Implementation → TODO Resolution → **Verify Test Plan Coverage** → Full Test Suite → Quality Reviews
- Build → Staging → Production

**Can run in parallel** (independent work):
- Architecture Doc + UI Mockups + Figma Extraction
- Code Review + Security Review + Code Quality Analysis
- Backend Tests + Frontend Tests (if on different layers)
- Bug fixes in different files/modules
- Multiple agents working on unrelated tasks

## Hooks Summary

| Hook | Trigger | Action |
|------|---------|--------|
| `pre-bash-guard` | Before Bash | Block `rm -rf`, `DROP DATABASE`, force-push |
| `pre-write-guard` | Before Write/Edit | Block writes to `.env`, `.pem`, secrets |
| `post-write-lint` | After Write/Edit | Java compile check or ESLint |
| `post-write-todo-check` | After Write/Edit | Warn on untracked TODOs (missing Linear ref) |
| `post-commit-quality` | After `git commit` | Spotless + ESLint on committed files |
| `on-stop-summary` | Agent stops | Generate session change summary |
