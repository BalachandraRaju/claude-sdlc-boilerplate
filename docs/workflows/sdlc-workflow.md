# SDLC Workflow — Multi-Agent Orchestration

This document describes how the agents, skills, and tools work together across the software development lifecycle.

## Agent Roster

| Agent | Role | Tools | MCP Servers |
|-------|------|-------|-------------|
| `prd-agent` | PRD generation, requirements | Read/Write, WebSearch | Linear, Figma |
| `architect-agent` | System design, DB schema, API design | Read/Write | - |
| `backend-agent` | Java/Spring Boot implementation | Bash, Read/Write/Edit | PostgreSQL |
| `frontend-agent` | React/TypeScript implementation, mockups | Bash, Read/Write/Edit | Playwright, Figma, Browser |
| `test-agent` | Test generation and execution | Bash, Read/Write | Playwright, Browser |
| `security-agent` | Security review and scanning | Bash, Read/Grep, WebSearch | Linear, Playwright |
| `review-agent` | Code review, PRD review, quality | Bash, Read/Grep | Linear |
| `devops-agent` | CI/CD, Docker, deployment | Bash, Read/Write | Linear |

## Critical Rules (ALL agents follow these)

1. **Plan Mode First** — Enter `EnterPlanMode` when requirements are unclear or task is non-trivial
2. **PRD is Source of Truth** — Always read `docs/prd/` before doing anything. Ask if no PRD exists.
3. **Ask, Don't Assume** — Use `AskUserQuestion` with concrete options. Never guess.
4. **Update CLAUDE.md** — Record recurring issues in "Known Issues & Fixes" section
5. **Clean Code** — Follow CLAUDE.md coding standards. Always.

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
│  │arch-agent│    │front-agt │    │ Extract  │                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│         └────────────┼────────────────┘                         │
│                      ↓                                          │
│               User Approval                                     │
├─────────────────────────────────────────────────────────────────┤
│  Phase 3: IMPLEMENTATION                                        │
│                                                                 │
│  ┌──────────┐                                                   │
│  │DB Migrate│ (backend-agent)                                   │
│  └────┬─────┘                                                   │
│       ↓                                                         │
│  ┌──────────┐                                                   │
│  │ Entities │ (backend-agent)                                   │
│  └────┬─────┘                                                   │
│       ↓                                                         │
│  ┌──────────┐                                                   │
│  │ Services │ (backend-agent)                                   │
│  └────┬─────┘                                                   │
│       ↓                                                         │
│  ┌──────────┐    ┌──────────┐                                   │
│  │Controllers│───→│API Svcs  │ ← frontend starts here           │
│  │backend-agt│   │front-agt │                                   │
│  └──────────┘    └────┬─────┘                                   │
│                       ↓                                         │
│                  ┌──────────┐                                   │
│                  │ UI + Pages│ (frontend-agent)                  │
│                  └──────────┘                                   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 4: QUALITY  (all parallel)                               │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐                      │
│  │Code Revw │  │Sec Review│  │SonarQube │                      │
│  │review-agt│  │secur-agt │  │review-agt│                      │
│  └──────────┘  └──────────┘  └──────────┘                      │
│         └──────────┼──────────┘                                 │
│                    ↓                                            │
│              Fix Findings (backend/frontend agents)             │
├─────────────────────────────────────────────────────────────────┤
│  Phase 5: TESTING                                               │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │Test Gen  │───→│Run Tests │───→│Fix Fails │                  │
│  │test-agent│    │test-agent│    │back/front│                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│                       │                                         │
│                  ┌────┴─────┐                                   │
│                  │E2E Tests │ (Playwright MCP)                  │
│                  │test-agent│                                   │
│                  └──────────┘                                   │
├─────────────────────────────────────────────────────────────────┤
│  Phase 6: DEPLOY                                                │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐                  │
│  │Build Locl│───→│  Staging │───→│   Prod   │                  │
│  │devops-agt│    │devops-agt│    │devops-agt│                  │
│  └──────────┘    └──────────┘    └──────────┘                  │
│                                   ↑ User confirm required       │
├─────────────────────────────────────────────────────────────────┤
│  Phase 7: SHIP                                                  │
│  ┌──────────┐                                                   │
│  │Final Revw│───→ Update Linear ───→ Done                       │
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

**Step 2: Create tasks with dependencies**
```
TaskCreate(subject="Write Flyway DB migration", description="...", activeForm="Writing migration")
TaskCreate(subject="Implement JPA entities", description="...", activeForm="Implementing entities")
TaskUpdate(taskId="2", addBlockedBy=["1"])  # entities blocked by migration
TaskCreate(subject="Implement service layer", description="...", activeForm="Implementing services")
TaskUpdate(taskId="3", addBlockedBy=["2"])  # services blocked by entities
# ... continue for all tasks
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
Task(name="tester", ...)         # Waits for implementation, then tests
Task(name="security-rev", ...)   # Waits for all code, then reviews
Task(name="code-rev", ...)       # Waits for all code, then reviews
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
| `/generate-code` | Implementation | Multi-agent code generation |
| `/generate-tests` | Testing | Test plan + automated tests |
| `/review-code` | Quality | Code review with findings |
| `/security-review` | Quality | OWASP security analysis |
| `/analyze-code` | Quality | SonarQube + static analysis |
| `/run-tests` | Testing | Execute all test suites |
| `/fix-bugs` | Maintenance | Diagnose and fix bugs |
| `/fix-review` | Quality | Fix review/security findings |
| `/build-local` | Deploy | Build backend + frontend locally |
| `/deploy-staging` | Deploy | Full staging deploy with checks |
| `/deploy-prod` | Deploy | Production deploy (user confirm) |
| `/launch-team` | All | Spin up full multi-agent team |
| `/full-sdlc` | All | End-to-end pipeline |

## MCP Server Usage by Agent

| MCP Server | Used By | Purpose |
|------------|---------|---------|
| **Linear** | prd-agent, security-agent, review-agent, devops-agent | Issue tracking, PRD management, findings |
| **PostgreSQL** | backend-agent | Schema inspection, data queries |
| **Playwright** | test-agent, frontend-agent, security-agent | Browser automation, E2E tests, screenshots |
| **Figma** | prd-agent, frontend-agent | Design tokens, component specs, screen layouts |
| **Browser** | test-agent, frontend-agent | Web page inspection, rendered output |
| **Filesystem** | All agents | Controlled file access for docs |

## Parallel vs Sequential Rules

**Must be sequential** (outputs feed into next step):
- PRD → PRD Review → Approval
- DB Migration → Entities → Services → Controllers
- API Services → UI Components (frontend needs API contracts)
- Test Generation → Test Execution → Bug Fix
- Build → Staging → Production

**Can run in parallel** (independent work):
- Architecture Doc + UI Mockups + Figma Extraction
- Code Review + Security Review + Code Quality Analysis
- Backend Tests + Frontend Tests + E2E Tests
- Bug fixes in different files/modules
- Multiple agents working on unrelated tasks

## Hooks Summary

| Hook | Trigger | Action |
|------|---------|--------|
| `pre-bash-guard` | Before Bash | Block `rm -rf`, `DROP DATABASE`, force-push |
| `pre-write-guard` | Before Write/Edit | Block writes to `.env`, `.pem`, secrets |
| `post-write-lint` | After Write/Edit | Java compile check or ESLint |
| `post-commit-quality` | After `git commit` | Spotless + ESLint on committed files |
| `on-stop-summary` | Agent stops | Generate session change summary |
