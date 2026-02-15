# Resolve TODOs

Scan the codebase for TODO/FIXME/HACK/XXX comments and resolve them all.

## Instructions

### Step 1: Scan for TODOs
Use Grep to find all TODO markers:
```
Grep pattern="TODO|FIXME|HACK|XXX" in backend/src/ and frontend/src/
```

### Step 2: Categorize Each TODO
For each TODO found, categorize it:

| Category | Action |
|----------|--------|
| **Missing implementation** | Implement the code now |
| **Known bug** | Fix the bug now |
| **Missing test** | Write the test now |
| **Missing validation** | Add the validation now |
| **Missing error handling** | Add error handling now |
| **Performance optimization** | If critical, fix now. If nice-to-have, create Linear issue |
| **Refactoring** | If it blocks correctness, do now. Otherwise create Linear issue |
| **Unclear requirement** | Ask the user with `AskUserQuestion` |

### Step 3: Resolve Each TODO
For each TODO:
1. Read the surrounding code to understand context
2. Read the PRD and implementation doc for the feature
3. **Implement the fix** — do not just create an issue and move on
4. Remove the TODO comment after fixing
5. Run the relevant tests to verify: `cd backend && ./mvnw test -Dtest=<Class>` or `cd frontend && npm test -- --run --testPathPattern=<file>`

### Step 4: For TODOs That Cannot Be Resolved Now
Only defer if:
- It requires infrastructure not yet set up (e.g., "TODO: add Redis caching" when Redis isn't configured)
- It requires a design decision the user hasn't made

For deferred TODOs:
1. Create a Linear issue with label `todo` describing what needs to be done
2. Change the TODO comment to reference the issue: `// TODO(LIN-123): Add Redis caching`
3. Log it in the implementation doc under "Known Limitations"

### Step 5: Verify Zero Residual TODOs
Re-scan:
```
Grep pattern="TODO|FIXME|HACK|XXX" in backend/src/ and frontend/src/
```
The only TODOs remaining should be deferred ones with Linear issue references.

### Step 6: Run Full Tests
```bash
bash scripts/run-all-tests.sh
```
All tests must still pass after TODO resolution.

### Step 7: Report
- Total TODOs found: N
- Resolved: X
- Deferred (with Linear issues): Y
- Tests: all passing

$ARGUMENTS
