# Generate Test Cases

Generate comprehensive, deep test cases and automated tests for a feature. Write complete runnable code, execute it, and fix until green.

## Instructions

This is NOT a surface-level test generator. It produces deep, full-stack tests that cover every layer from button click to database write and back.

### Step 1: Read Everything
- Read the PRD from `docs/prd/` — extract every acceptance criterion
- Read the implementation doc from `docs/implementation/` — understand the flows
- Read the implementation code — every controller, service, repository, component, page
- Read the Excalidraw diagrams — understand the data flow visually

### Step 2: Map Acceptance Criteria to Test Cases
For EACH acceptance criterion in the PRD, create a test matrix:

| Criterion | Unit Test (Backend) | Unit Test (Frontend) | Integration Test | E2E Test |
|-----------|--------------------|--------------------|-----------------|---------|
| "User can create profile" | ProfileServiceTest | ProfileFormTest | POST /api/v1/profiles → 201 | Fill form → submit → verify |
| "Name is required" | shouldFail_whenNameNull | shows validation error | POST with empty name → 400 | Submit empty → see error |

**Every cell in the matrix must have actual test code written.**

### Step 3: Write Backend Tests (spawn test-agent)

**Repository tests** — per repository:
- Test CRUD operations with Testcontainers (real PostgreSQL)
- Test custom query methods
- Test constraint violations (unique, not-null, FK)
- Test pagination and sorting

**Service tests** — per service method:
- Happy path with valid input
- Each validation failure (null, empty, too long, invalid format)
- Entity not found
- Unauthorized access
- Duplicate/conflict scenarios
- Transaction rollback on exception
- Side effects (events published, emails sent)

**Integration tests** — per endpoint:
- Full HTTP roundtrip: request → response with correct status + body
- All status codes: 200, 201, 400, 401, 403, 404, 409
- Request validation: missing fields, wrong types, boundary values
- Auth: no token, expired token, wrong role, valid token
- Response headers: Content-Type, Location (for 201)
- Verify database state after mutation endpoints

**Execute and verify**:
```bash
cd backend && ./mvnw test
```
Fix any failures before proceeding.

### Step 4: Write Frontend Tests (spawn test-agent)

**Service function tests** — per API service:
- Correct endpoint called with correct params
- Auth header included
- Error handling: network error, 401 redirect, 500 error message

**Component tests** — per component:
- All render states: loading, data, empty, error
- User interactions: click, type, select, submit
- Form validation: submit invalid → errors shown → fix → resubmit → success
- Conditional rendering: different data shapes, edge cases
- Accessibility: aria labels, keyboard navigation

**Hook tests** — per custom hook:
- Initial state
- State transitions
- Cleanup on unmount

**Execute and verify**:
```bash
cd frontend && npm test -- --run
```
Fix any failures before proceeding.

### Step 5: Write E2E Tests (Playwright)

**For EACH user flow in the PRD**, write a complete Playwright test that:
1. Starts from a real browser at the application URL
2. Navigates to the relevant page
3. Performs every user action (click, type, select, submit)
4. Verifies every visible response (loading states, success messages, data display)
5. Verifies the action persisted (navigate away and back)
6. Tests the error flow (invalid input → error → fix → retry → success)

**Full-stack trace for a button click**:
```
Click "Save" button
  → onClick handler fires
    → Form validation runs
      → If invalid: error messages appear (test this)
      → If valid: loading spinner shows (test this)
        → API service function called
          → Axios POST to /api/v1/resource
            → Controller receives request
              → DTO validation runs
                → Service method called
                  → Repository.save() called
                    → INSERT INTO database
                  → Response DTO created
                → 201 returned with body
              → Axios resolves
            → Frontend state updates
          → Loading spinner hides (test this)
        → Success toast/message appears (test this)
      → Page redirects or data refreshes (test this)
```

**EVERY arrow in that chain must have test coverage.**

**Execute and verify**:
```bash
cd frontend && npx playwright test
```
Fix any failures.

### Step 6: Run Complete Suite
```bash
bash scripts/run-all-tests.sh
```
All tests must pass. If any fail, fix immediately — do not report partial success.

### Step 7: Coverage Report
- Backend: `cd backend && ./mvnw test jacoco:report` (if JaCoCo configured)
- Frontend: `cd frontend && npm test -- --run --coverage`
- Report coverage percentages per module
- Flag any files with < 80% coverage

### Step 8: Update Implementation Doc
Add test results to `docs/implementation/IMPL-<feature>.md`:
- Test counts: X unit, Y integration, Z E2E
- Coverage percentages
- Edge cases covered
- Any remaining test gaps (with Linear issues)

$ARGUMENTS
