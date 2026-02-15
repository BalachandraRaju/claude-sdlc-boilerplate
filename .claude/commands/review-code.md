# Code Review

Perform a comprehensive code review on recent changes.

## Instructions

1. **Identify Changes**: Run `git diff` to find what changed, or accept a specific file/directory from the user.

2. **Spawn Review Agent**: Use the Task tool with `review-agent` to:
   - Review code correctness, patterns, and readability
   - Check adherence to project conventions (see CLAUDE.md)
   - Identify performance issues (N+1 queries, unnecessary re-renders)
   - Verify error handling and edge cases

3. **Spawn Security Agent** (parallel): Use the Task tool with `security-agent` to:
   - Check for OWASP Top 10 vulnerabilities in the changes
   - Verify input validation and auth checks
   - Check for sensitive data exposure

4. **Check Tests**: Verify that:
   - New code has corresponding tests
   - Existing tests still pass: `cd backend && ./mvnw test` and `cd frontend && npm test`
   - Coverage hasn't decreased

5. **Generate Review Report**:
   - List findings by severity (Blocker, Major, Minor, Info)
   - Include specific line references and suggested fixes
   - Create Linear issues for Blocker/Major findings

6. **Output**: Present categorized findings to the user.

$ARGUMENTS
