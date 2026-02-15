# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Full-stack SDLC boilerplate: **Java 21 + Spring Boot 3** backend, **React 18 + TypeScript** frontend, **PostgreSQL** database. Designed for multi-agent Claude Code workflows covering the entire software development lifecycle.

## Build & Run Commands

### Backend (Java/Spring Boot)
```bash
cd backend && ./mvnw spring-boot:run          # Run backend (port 8080)
cd backend && ./mvnw clean package             # Build JAR
cd backend && ./mvnw test                      # Run all tests
cd backend && ./mvnw test -Dtest=ClassName     # Run single test class
cd backend && ./mvnw test -Dtest=ClassName#methodName  # Run single test method
cd backend && ./mvnw verify                    # Run tests + integration tests
cd backend && ./mvnw spotless:apply            # Format code
cd backend && ./mvnw spotless:check            # Check formatting
```

### Frontend (React/TypeScript)
```bash
cd frontend && npm install                     # Install dependencies
cd frontend && npm run dev                     # Dev server (port 3000)
cd frontend && npm run build                   # Production build
cd frontend && npm test                        # Run all tests
cd frontend && npm test -- --testPathPattern=FileName  # Run single test
cd frontend && npm run lint                    # ESLint
cd frontend && npm run lint:fix                # ESLint auto-fix
cd frontend && npm run type-check              # TypeScript check
```

### Database
```bash
cd backend && ./mvnw flyway:migrate            # Run migrations
cd backend && ./mvnw flyway:info               # Migration status
```

### Deployment
```bash
bash scripts/build-local.sh                    # Build both backend + frontend locally
bash scripts/deploy-staging.sh                 # Deploy to staging environment
bash scripts/deploy-prod.sh                    # Deploy to production (requires confirmation)
```

### Git Worktrees
```bash
bash scripts/worktree-new.sh <feature-name>    # Create worktree for a feature branch
bash scripts/worktree-list.sh                  # List all active worktrees
bash scripts/worktree-cleanup.sh <feature-name>  # Remove worktree after merge
```

### Full Stack
```bash
bash scripts/setup.sh                          # First-time setup
bash scripts/run-all-tests.sh                  # All tests (backend + frontend)
bash scripts/sonar-scan.sh                     # SonarQube analysis
```

## Architecture

### Backend (`backend/`)
- **Spring Boot 3** with Java 21, Maven wrapper
- **Layered architecture**: Controller -> Service -> Repository -> Model
- **`com.app.common`** — Standard API response types: `ApiResponse`, `ApiError`, `PagedResponse`, `PaginationParams`, `ErrorCode`, `GlobalExceptionHandler`
- **`com.app.controller`** — REST endpoints, request validation
- **`com.app.service`** — Business logic, transaction management
- **`com.app.repository`** — Spring Data JPA repositories
- **`com.app.model`** — JPA entities and DTOs
- **`com.app.config`** — Spring configuration beans
- **`com.app.security`** — Spring Security, JWT auth
- **`src/main/resources/db/migration/`** — Flyway SQL migrations (V1__, V2__ naming)
- Tests mirror source structure under `src/test/java/`

### Frontend (`frontend/`)
- **React 18 + TypeScript + Vite**
- **`src/pages/`** — Route-level components
- **`src/components/`** — Reusable UI components
- **`src/types/`** — TypeScript types: `api.ts` (ApiResponse, ApiError, PagedResponse, PaginationParams)
- **`src/services/`** — API client functions (Axios + `unwrapResponse` + `extractError`)
- **`src/hooks/`** — Custom React hooks
- **`src/utils/`** — Pure utility functions
- API base URL configured via `VITE_API_URL` env var

### Database
- PostgreSQL with Flyway migrations
- Connection configured in `backend/src/main/resources/application.yml`

---

## Critical Rules — READ FIRST

### 0. Use Git Worktrees for Feature Isolation
**Before starting any new feature**, ask the user:
> "Should I create a git worktree for this feature? This gives you an isolated branch + directory so parallel features don't conflict."

If yes, run: `bash scripts/worktree-new.sh <feature-name>`
This creates `feature/<feature-name>` branch in `../worktrees/<feature-name>/`.

**Worktree rules:**
- Each feature gets its own worktree — work in isolation, merge when done
- Worktrees share git history — commits from any worktree are visible to all
- Clean up after merge: `bash scripts/worktree-cleanup.sh <feature-name>`
- List active worktrees: `bash scripts/worktree-list.sh`

### 1. Plan Mode Is Mandatory for Unclear Requirements
**ALWAYS enter plan mode (`EnterPlanMode`) before writing any code when:**
- Requirements are ambiguous, incomplete, or open to interpretation
- The task touches more than 2 files
- You are unsure about the right approach
- The user gives a vague instruction like "add feature X" without details
- There are multiple valid implementation approaches

**In plan mode, you MUST:**
- Read the relevant PRD from `docs/prd/` first
- Explore existing code to understand current patterns
- Ask the user meaningful clarifying questions using `AskUserQuestion` — never guess
- Present a concrete implementation plan before writing any code

### 2. Always Refer to PRDs
- Before implementing anything, check `docs/prd/` for existing PRDs that cover the feature
- If no PRD exists for a feature, ask the user: "There is no PRD for this feature. Should I generate one first with `/generate-prd`?"
- When in doubt about a requirement, quote the PRD and ask the user to clarify the gap
- Never assume requirements — if the PRD is silent on something, ask

### 3. Generate Implementation Docs + Diagrams for Every Feature
**For every feature you implement**, generate:

**Implementation Doc** (`docs/implementation/IMPL-<feature>.md`):
- Created at the start of implementation, updated as you go
- Records what was built, why, key decisions, files changed, how to test
- Use template at `docs/templates/implementation-doc-template.md`
- Links back to PRD and forward to diagrams

**Excalidraw Diagrams** (`docs/diagrams/<feature>/`):
- Generate at least one diagram per feature: architecture, data flow, or ER diagram
- Use `/generate-diagram` to create `.excalidraw.json` files
- Open at https://excalidraw.com or VS Code Excalidraw extension
- Each diagram has a companion `.md` file describing what it shows
- Colors: Blue=backend, Green=frontend, Orange=database, Purple=external, Red=security

**Reference chain**: PRD → Implementation Doc → Diagrams → Code
Future Claude sessions should read the implementation doc before modifying a feature.

### 4. Update CLAUDE.md on Issues
**Every time you encounter a recurring issue, pattern, or lesson learned, update this file:**
- Add the fix to the "Known Issues & Fixes" section below
- If it's a convention you discovered, add it to "Conventions"
- If it's a tool/command issue, add it to the relevant section
- This keeps future Claude sessions from repeating the same mistakes

### 5. Implementation Depth — Never Stop at High-Level
**Every implementation must be complete end-to-end. Do NOT stop at surface level.**

- Trace every user action from button click → event handler → API call → controller → service → repository → DB → response → UI update
- Implement ALL layers — not just the controller or just the component
- Write actual code for every layer, not TODOs or stubs
- Run tests after EACH implementation step (not just at the end):
  - After entities + migrations → run repository tests
  - After service layer → run service tests
  - After controllers → run integration tests
  - After frontend API services → run service tests
  - After UI components → run component tests
  - After pages → run E2E tests
- If tests fail, fix immediately — never leave red tests and move on
- This applies equally to test generation, code generation, bug fixes, and browser automation

### 6. Handle TODOs Immediately
**Never leave unresolved TODOs in code. Either fix them now or track them.**

- If you write a TODO during implementation, resolve it before moving to the next task
- Run `/resolve-todos` periodically to catch any that slipped through
- The only acceptable TODOs are those with a Linear issue reference: `// TODO(LIN-123): description`
- Deferred TODOs must be logged in the implementation doc under "Known Limitations"
- Categories: missing implementation → implement now, known bug → fix now, missing test → write now, missing validation → add now

### 7. Update CLAUDE.md + Memory on New Instructions
**Whenever the user gives new instructions, conventions, or corrections:**
- Update CLAUDE.md immediately — add the new rule/convention to the relevant section
- Update auto memory at `~/.claude/projects/-Users-apple-Projects-alpha-claude-sdlc/memory/MEMORY.md` — record the instruction so future sessions inherit it
- This is NOT optional. Every new instruction = both files updated.
- If the instruction contradicts an existing rule, update the old rule, don't just add a new one

**What to record in memory:**
- User preferences ("always use worktrees", "never auto-commit")
- Coding conventions the user explicitly stated
- Architecture decisions ("API must use standard response format")
- Workflow preferences ("always run browser automation after tests")

### 8. Browser Automation After Every Test Step
**Every test step must include Playwright browser verification — not just backend/unit tests.**

After each test step (repository, service, integration, component, E2E):
1. Run the automated test suite for that layer
2. If a UI is involved, also run Playwright MCP to visually verify:
   - Navigate to the relevant page
   - Take a screenshot to confirm rendering
   - Click through the flow to confirm interactivity
   - Verify error states render correctly in the browser
3. This applies to component tests AND E2E tests — both must have real browser verification
4. Use `mcp__playwright__*` tools for browser automation

### 9. Ask Meaningful Questions
When requirements are unclear, DO NOT:
- Guess and implement something that might be wrong
- Ask vague yes/no questions
- Proceed with assumptions

Instead, DO:
- Reference the specific PRD section that's unclear
- Offer 2-3 concrete options with trade-offs
- Ask about edge cases, error handling, and authorization
- Example: "The PRD says 'users can manage their profiles' — does 'manage' include delete? Should deleted profiles be soft-deleted (recoverable) or hard-deleted?"

---

## Coding Standards

### Clean Code Principles
- **Single Responsibility**: Each class/function does one thing. If a method description needs "and", split it
- **Meaningful Names**: `getUserActiveSubscriptions()` not `getData()`. Variable names explain intent
- **Small Functions**: Max ~20 lines. If you need to scroll, extract a method
- **No Magic Numbers/Strings**: Use constants. `MAX_LOGIN_ATTEMPTS = 5` not `if (attempts > 5)`
- **DRY But Not Prematurely**: Duplicate code 2x is OK. At 3x, extract. Don't abstract for hypothetical reuse
- **Fail Fast**: Validate inputs at entry points. Return early on invalid state
- **Immutability by Default**: Use `final` in Java, `const` in TypeScript. Mutate only when necessary

### Uniform API Response Format — MANDATORY
**Every single API endpoint MUST return the same response structure. No exceptions. No variations.**

**Success response:**
```json
{ "success": true, "data": { ... }, "timestamp": "2025-01-01T00:00:00Z" }
```

**Error response:**
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": [{ "field": "email", "message": "must be valid", "rejectedValue": "bad" }]
  },
  "timestamp": "2025-01-01T00:00:00Z"
}
```

**Paginated response (inside `data`):**
```json
{ "items": [...], "page": 0, "size": 20, "totalItems": 100, "totalPages": 5 }
```

**Backend implementation** (in `com.app.common`):
- `ApiResponse<T>` — wraps ALL responses. Use `ApiResponse.ok(data)`, `ApiResponse.created(data)`, `ApiResponse.error(error)`
- `ApiError` — standard error with `code`, `message`, `details`. Use `ErrorCode` constants
- `PagedResponse<T>` — paginated data via `PagedResponse.from(springPage)`
- `PaginationParams` — standard query params: `?page=0&size=20&sort=createdAt&direction=desc`
- `GlobalExceptionHandler` — `@RestControllerAdvice` catches ALL exceptions and returns `ApiResponse.error()`
- `ErrorCode` — constants: `VALIDATION_ERROR`, `NOT_FOUND`, `ALREADY_EXISTS`, `UNAUTHORIZED`, `FORBIDDEN`, `BAD_REQUEST`, `INTERNAL_ERROR`

**Frontend implementation** (in `src/types/api.ts` + `src/services/api.ts`):
- `ApiResponse<T>`, `ApiError`, `PagedResponse<T>`, `PaginationParams` — TypeScript types matching backend exactly
- `unwrapResponse(response)` — extracts `data` from success, throws `ApiRequestError` on failure
- `extractError(error)` — converts any error (Axios, network, API) to a consistent `ApiError` object
- `toPaginationQuery(params)` — builds query string from `PaginationParams`

**Rules:**
- Controllers return `ResponseEntity<ApiResponse<T>>` — never raw objects, never `ResponseEntity<String>`
- Frontend service functions call `unwrapResponse()` — never access `response.data` directly
- Frontend error handling uses `extractError()` — never parse Axios errors manually
- Error codes are the same constants in Java and TypeScript — frontend switches on `error.code`
- Pagination uses the same param names everywhere: `page`, `size`, `sort`, `direction`

**API Naming Conventions:**
- Base path: `/api/v1/`
- Resource naming: plural nouns (`/users`, `/profiles`, `/orders`)
- Nested resources: `/users/{userId}/orders`
- Actions: `POST /users/{userId}/activate` (verb only for non-CRUD actions)
- Query/filter: `GET /users?status=active&role=admin`
- Standard CRUD: `GET /resources`, `GET /resources/{id}`, `POST /resources`, `PUT /resources/{id}`, `DELETE /resources/{id}`

### Backend (Java/Spring Boot)
- Constructor injection — never `@Autowired` on fields
- DTOs separate from entities — never expose JPA entities in API responses
- `@Transactional` on service methods, not controllers
- Bean Validation (`@Valid`) on all incoming DTOs
- **All exceptions go through `GlobalExceptionHandler`** — never throw raw exceptions from controllers
- All endpoints return `ResponseEntity<ApiResponse<T>>` with correct HTTP status codes
- No business logic in controllers — controllers are thin wrappers
- Repository methods: use Spring Data query derivation or `@Query` — no raw string concatenation
- All list endpoints accept `PaginationParams` and return `PagedResponse<T>`
- Logging: ERROR for failures, WARN for recoverable, INFO for business events, DEBUG for dev

### Frontend (React/TypeScript)
- Functional components only — no class components
- No `any` type — ever. Type all props, state, API responses
- Named exports only (no default exports)
- API calls only through `src/services/` — never `axios.get()` directly in components
- **All service functions use `unwrapResponse()` to extract data and `extractError()` to handle errors**
- **All error handling uses `ApiError` type** — never parse error shapes ad-hoc
- Handle loading, error, and empty states for every data fetch
- Display error messages from `ApiError.message` — map `ApiError.code` for specific handling (e.g., show field errors for `VALIDATION_ERROR`)
- Custom hooks for shared stateful logic (prefix: `use`)
- Semantic HTML + ARIA labels for accessibility
- No inline styles — use CSS Modules or Tailwind

### Database
- All columns `snake_case`, Java fields `camelCase`
- Flyway migrations are immutable once committed — create new migrations for changes
- Every table has `id` (UUID), `created_at`, `updated_at` columns
- Foreign keys always have corresponding indexes
- Use `TEXT` not `VARCHAR` for PostgreSQL (unless max-length validation is needed)

### Security-First Development
- Input validation on every endpoint — never trust client data
- Parameterized queries only — NEVER concatenate SQL strings
- No secrets in code, logs, or error messages — use env vars
- JWT tokens: short-lived access (15min), longer-lived refresh (7d)
- All endpoints authenticated by default — explicitly opt-out for public endpoints
- CORS restricted to known origins — never `*` in production
- Sanitize all user-generated content before rendering (React does this by default — don't bypass with `dangerouslySetInnerHTML`)

---

## SDLC Workflow

This repo uses Claude Code multi-agent workflows for the full SDLC. Available via slash commands:

| Phase | Command | Agent |
|-------|---------|-------|
| Requirements | `/generate-prd` | prd-agent |
| PRD Review | `/review-prd` | review-agent |
| Design | `/generate-mockups` | frontend-agent |
| Code Generation | `/generate-code` | backend-agent, frontend-agent |
| Test Generation | `/generate-tests` | test-agent |
| Code Review | `/review-code` | review-agent |
| Security Review | `/security-review` | security-agent |
| Code Quality | `/analyze-code` | review-agent |
| Test Execution | `/run-tests` | test-agent |
| Bug Fixes | `/fix-bugs` | backend-agent, frontend-agent |
| Review Fixes | `/fix-review` | backend-agent, frontend-agent |
| Deployment | `/deploy-staging` | devops-agent |
| Deployment | `/deploy-prod` | devops-agent |
| TODO Resolution | `/resolve-todos` | scan + fix all TODOs |
| Worktree | `/new-worktree` | creates isolated feature branch |
| Diagrams | `/generate-diagram` | Excalidraw architecture/flow diagrams |
| Team Launch | `/launch-team` | all agents |
| Full Pipeline | `/full-sdlc` | orchestrator (all agents) |

## Launching Multi-Agent Teams

To run parallel agents for a feature, use `/launch-team <feature>`. This:
1. Creates a team via `TeamCreate`
2. Creates tasks with dependencies via `TaskCreate` + `TaskUpdate` (blockedBy)
3. Spawns agents via `Task` tool with `team_name` and `subagent_type`
4. Agents pick up tasks, communicate via `SendMessage`, mark done via `TaskUpdate`

**Example — implementing a "User Profile" feature:**
```
/launch-team user-profile
```
This spawns:
- `backend-agent` → DB migration, entities, services, controllers (sequential, with tests after each step)
- `test-agent` → writes + runs tests interleaved with backend implementation (repo tests, service tests, integration tests)
- `frontend-agent` → API services, components, pages (starts after controllers done, with tests after each step)
- `test-agent` → writes + runs frontend tests interleaved (component tests, E2E tests)
- `security-agent` + `review-agent` → run in parallel after all code + tests are green

See `docs/workflows/sdlc-workflow.md` for the full pipeline diagram.

## Implementation Docs & Diagrams

Every feature must have:
- **Implementation Doc**: `docs/implementation/IMPL-<feature>.md` — what was built, decisions, files, how to test
- **Excalidraw Diagrams**: `docs/diagrams/<feature>/*.excalidraw.json` — visual architecture/flow/ER diagrams
- **Reference chain**: PRD → Impl Doc → Diagrams → Code

Before modifying any feature, read its implementation doc first. If none exists, create one.

## MCP Integrations

Configured in `.mcp.json`:
- **Linear** — Issue tracking, PRD management, sprint planning
- **PostgreSQL** — Direct DB queries and schema inspection
- **Playwright** — Browser automation, UI testing, screenshot capture
- **Figma** — Design token extraction, component inspection, screen specs
- **Filesystem** — Controlled file access for document generation

## Hooks (Guardrails)

Configured in `.claude/settings.json`:

**Pre-execution (PreToolUse):**
- **pre-bash-guard** — Blocks destructive commands (`rm -rf /`, `DROP DATABASE`, force-push to main, `git reset --hard`, etc.)
- **pre-write-guard** — Blocks writes to secrets files (`.env`, `.pem`, `credentials.json`)
- **pre-code-guard** — Checks that PRD, implementation doc, and test plan exist before writing implementation code (skips docs, tests, configs, common files)

**Post-execution (PostToolUse):**
- **post-write-lint** — Auto-runs Java compile check or ESLint after code edits
- **post-write-todo-check** — Warns if code contains untracked TODOs (missing Linear issue reference)
- **post-write-security-scan** — Scans for hardcoded secrets, SQL injection, XSS, `any` types, `@Autowired` on fields, `dangerouslySetInnerHTML`, direct axios imports in components, hardcoded API URLs, `console.log` in production code, `localStorage` for passwords
- **post-write-api-format-check** — Enforces: controllers use `ApiResponse<T>`, no try/catch in controllers (use `GlobalExceptionHandler`), services use pagination, frontend services use `unwrapResponse()`, frontend components use `extractError()`

**Other:**
- **post-commit-quality** — Runs formatting + lint checks after every commit
- **on-stop-summary** — Generates session summary listing all changed files

**Deny list** — Blocked commands (in settings.json `permissions.deny`):
`rm -rf /`, `rm -rf ~`, `rm -rf .`, `DROP DATABASE`, `DROP TABLE`, `TRUNCATE`, `git push --force`, `git push -f`, `git reset --hard`, `git clean -f`, `git checkout -- .`, `npm publish`, `curl|bash`, `wget|bash`, `chmod 777`

## Known Issues & Fixes

<!--
Add entries here when you encounter recurring issues. Format:
### Issue: [Short description]
**Symptom**: What goes wrong
**Fix**: How to resolve it
**Date**: When it was added
-->

_No known issues yet. Update this section when issues are encountered._
