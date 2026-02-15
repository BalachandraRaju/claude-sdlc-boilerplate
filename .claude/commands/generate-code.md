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

### Step 5: Create Tasks
Break down the feature into tasks:
- Create/update implementation doc (architect-agent, runs first)
- Database migrations (backend-agent, after doc)
- JPA entities and repositories (backend-agent, after migrations)
- Service layer (backend-agent, after entities)
- REST controllers + DTOs (backend-agent, after services)
- API service functions (frontend-agent, after controllers)
- UI components (frontend-agent, parallel with API services)
- Page components (frontend-agent, after UI components)
- Unit tests (test-agent, after implementation)
- Update implementation doc with final state (architect-agent, last)

### Step 6: Spawn Agents
Use the Task tool to spawn:
- `backend-agent` — for Java/Spring Boot code (sequential: migration -> entity -> service -> controller)
- `frontend-agent` — for React/TypeScript code (can start API services after controllers are done)
- `test-agent` — for writing tests (after implementation is complete)

All agents must read `docs/implementation/IMPL-<feature>.md` for context before starting.

### Step 7: Dependency Order
```
Impl Doc + Diagrams
       ↓
DB Migration → Entities → Repositories → Services → Controllers
                                                        ↓
                                            API Services (frontend)
                                                        ↓
                                  Components (frontend) ←→ Pages (frontend)
                                                        ↓
                                                  Tests (all)
                                                        ↓
                                          Update Impl Doc (final)
```

### Step 8: Report
- Summary of all generated files
- Any TODOs or decisions needed
- Link to the implementation doc and diagrams
- Remind user to review the implementation doc

$ARGUMENTS
