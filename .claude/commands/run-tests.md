# Run Tests

Execute test suites, report results, and fix failures. Do not stop until all tests pass.

## Instructions

### Step 1: Determine Scope
Based on user input from `$ARGUMENTS`, run:
- `all` — Everything (default)
- `backend` — Java tests only
- `frontend` — React tests only
- `e2e` — Playwright E2E tests only
- `<specific-file>` — Single test file

### Step 2: Execute Tests

**Backend**:
```bash
cd backend && ./mvnw test 2>&1
```

**Frontend**:
```bash
cd frontend && npm test -- --run 2>&1
```

**E2E**:
```bash
cd frontend && npx playwright test 2>&1
```

**Single backend test**:
```bash
cd backend && ./mvnw test -Dtest=<ClassName> 2>&1
```

**Single frontend test**:
```bash
cd frontend && npm test -- --run --testPathPattern=<pattern> 2>&1
```

### Step 3: Analyze Results
Parse the output for:
- Total pass/fail/skip counts
- Each failing test with full error message and stack trace
- Compilation errors (test won't even run)

### Step 4: Fix Failures — MANDATORY
For EACH failing test:
1. Read the test file
2. Read the code under test
3. Determine if the bug is in the test or the implementation
4. **Fix it** — do not just report it
5. Re-run the specific test to confirm the fix
6. Continue to the next failure

**Repeat until ALL tests pass.** Do not stop at "here are the failures" — fix them.

If a fix requires a design decision, ask the user with `AskUserQuestion`:
> "Test X fails because [reason]. Two approaches to fix: (A) Change implementation to [X], (B) Change test expectation to [Y]. Which approach?"

### Step 5: Re-run Full Suite
After fixing all individual failures:
```bash
bash scripts/run-all-tests.sh
```
Confirm zero failures.

### Step 6: Report
- Total: X passed, Y fixed (was failing), Z skipped
- Each fix applied: what test, what was wrong, what you changed
- Coverage summary (if available)
- Any TODOs discovered during fixing (create Linear issues)

$ARGUMENTS
