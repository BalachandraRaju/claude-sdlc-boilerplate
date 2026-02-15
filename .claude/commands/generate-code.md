# Generate Code

Generate implementation code from PRD and architecture documents.

## Instructions

This command orchestrates multi-agent code generation. It spawns parallel agents for backend and frontend work.

### Step 0: Worktree Check
Ask the user using `AskUserQuestion`:
> "Should I create a git worktree for this feature?"
> Options: "Yes, create worktree (Recommended)" / "No, work on current branch"

If yes: `bash scripts/worktree-new.sh <feature-name>`

### Step 1: Read Requirements
- Read the PRD from `docs/prd/`
- Read the architecture doc from `docs/architecture/` if it exists
- Read the existing implementation doc from `docs/implementation/` if it exists

### Step 2: Create Implementation Doc
If no implementation doc exists:
1. Create `docs/implementation/IMPL-<feature>.md` from `docs/templates/implementation-doc-template.md`
2. Fill in Overview, PRD reference, and planned changes

### Step 3: Generate Architecture Diagram
Create at least one Excalidraw diagram showing:
- System components involved
- Data flow for the feature
- Database entity relationships (if new tables)

Save to: `docs/diagrams/<feature>/architecture.excalidraw.json`
Reference it in the implementation doc.

### Step 4: Create Team
Use TeamCreate to set up a code generation team.

### Step 5: Create Tasks (Implementation + Tests Interleaved)
Break down the feature into tasks with test steps after each implementation step:

**Documentation:**
- Create/update implementation doc + diagrams (architect-agent, runs first)

**Backend (implementation + tests interleaved):**
- Database migrations (backend-agent, after doc)
- JPA entities + repositories (backend-agent, after migrations)
- **Repository tests** (test-agent, after entities) ← TEST NOW
- Service layer (backend-agent, after repo tests pass)
- **Service unit tests** (test-agent, after services) ← TEST NOW
- REST controllers + DTOs (backend-agent, after service tests pass)
- **Integration tests** (test-agent, after controllers) ← TEST NOW, verify `ApiResponse` format

**Frontend (implementation + tests interleaved):**
- API service functions (frontend-agent, after controllers)
- **API service tests** (test-agent, after API services) ← TEST NOW, verify `unwrapResponse`/`extractError`
- UI components + hooks (frontend-agent, after API service tests pass)
- **Component tests + browser automation** (test-agent, after components) ← TEST NOW
- Page components + routing (frontend-agent, after component tests pass)
- **E2E Playwright tests + full browser automation** (test-agent, after pages) ← TEST NOW

**Validation:**
- Resolve all TODOs (backend/frontend agents)
- Run full test suite + browser automation (test-agent) ← VALIDATE ALL
- Update implementation doc with final state (architect-agent, last)

### Step 6: Spawn Agents
Use the Task tool to spawn:
- `backend-agent` — for Java/Spring Boot code (sequential: migration -> entity -> service -> controller)
- `frontend-agent` — for React/TypeScript code (starts after controllers are done)
- `test-agent` — writes + runs tests after EACH implementation step (not just at the end)

All agents must read `docs/implementation/IMPL-<feature>.md` for context before starting.

### Step 7: Dependency Order
```
Impl Doc + Diagrams
       ↓
DB Migration → Entities + Repos → [Repo Tests] → Services → [Service Tests]
                                                                   ↓
                                              Controllers + DTOs → [Integration Tests]
                                                                   ↓
                                              API Services → [API Service Tests]
                                                                   ↓
                                              Components → [Component Tests + Browser]
                                                                   ↓
                                              Pages → [E2E Tests + Browser Automation]
                                                                   ↓
                                              Resolve TODOs → [Full Test Suite + Browser]
                                                                   ↓
                                              Update Impl Doc (final)
```

### Step 8: Report
- Summary of all generated files
- Test results: X passed, Y fixed, Z coverage
- Browser automation verification: all pages visually confirmed
- Any remaining TODOs (with Linear issue references)
- Link to the implementation doc and diagrams
- Remind user to review the implementation doc

$ARGUMENTS
