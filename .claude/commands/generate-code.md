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

### Step 4: Generate Test Plan (BEFORE writing code)
Use `/generate-tests` to create the test plan:
1. Read PRD acceptance criteria — extract every testable requirement
2. Read the implementation doc and diagrams from Steps 2-3
3. Build a **test matrix** — map each acceptance criterion to test cases at each layer:
   - Unit tests (backend): repository + service tests
   - Unit tests (frontend): component + service tests
   - Integration tests: full HTTP roundtrip with `ApiResponse` format verification
   - E2E tests: Playwright browser flows
4. Write the test plan document: `docs/test-plans/TEST-<feature>.md`
5. Every cell in the matrix = actual test code to be written during implementation

### Step 5: Create Team
Use TeamCreate to set up a code generation team.

### Step 6: Create Tasks (Implementation + Tests Interleaved)
Break down the feature into tasks with test steps after each implementation step.
**Test-agent references the test plan from Step 4 at every test step.**

**Test Case Generation:**
- Generate test plan from PRD (test-agent, runs after doc)

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
- Verify test plan coverage — every PRD criterion has passing tests (test-agent)
- Run full test suite + browser automation (test-agent) ← VALIDATE ALL
- Update implementation doc + test plan with final state (architect-agent, last)

### Step 7: Spawn Agents
Use the Task tool to spawn:
- `backend-agent` — for Java/Spring Boot code (sequential: migration -> entity -> service -> controller)
- `frontend-agent` — for React/TypeScript code (starts after controllers are done)
- `test-agent` — writes + runs tests after EACH implementation step (not just at the end)

All agents must read `docs/implementation/IMPL-<feature>.md` for context before starting.

### Step 8: Dependency Order
```
Impl Doc + Diagrams
       ↓
Test Plan Generation (PRD criteria → test matrix → docs/test-plans/)
       ↓
DB Migration → Entities + Repos → [Repo Tests ← from plan]
                                         ↓
                    Services → [Service Tests ← from plan]
                                         ↓
              Controllers + DTOs → [Integration Tests ← from plan]
                                         ↓
                    API Services → [API Service Tests ← from plan]
                                         ↓
                      Components → [Component Tests + Browser ← from plan]
                                         ↓
                           Pages → [E2E Tests + Browser ← from plan]
                                         ↓
              Resolve TODOs → Verify test plan coverage → [Full Suite + Browser]
                                         ↓
                            Update Impl Doc + Test Plan (final)
```

### Step 9: Report
- Summary of all generated files
- Test results: X passed, Y fixed, Z coverage
- Browser automation verification: all pages visually confirmed
- Any remaining TODOs (with Linear issue references)
- Link to the implementation doc and diagrams
- Remind user to review the implementation doc

$ARGUMENTS
