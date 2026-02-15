# Fix Bugs

Diagnose and fix reported bugs.

## Instructions

1. **Understand the Bug**: Read the bug report from:
   - User description (passed as argument)
   - Linear issue (fetch via Linear MCP if issue ID provided)
   - Test failure output

2. **Reproduce**: If possible, identify a failing test or create one that demonstrates the bug.

3. **Diagnose**: Read relevant code, trace the execution path, identify root cause.

4. **Fix**: Spawn the appropriate agent:
   - Backend bug → `backend-agent`
   - Frontend bug → `frontend-agent`
   - Both → spawn both in parallel

5. **Verify**:
   - Run existing tests to ensure no regressions
   - Run the reproduction test to confirm the fix
   - If no test existed, write one that covers the bug scenario

6. **Update Linear**: If the bug came from a Linear issue, update its status and add a comment describing the fix.

7. **Report**: Summary of root cause, fix applied, and tests added/updated.

$ARGUMENTS
