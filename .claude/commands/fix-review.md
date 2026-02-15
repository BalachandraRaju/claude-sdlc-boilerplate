# Fix Review Comments

Address code review findings and feedback.

## Instructions

1. **Read Review Findings**: From:
   - User input (passed as argument)
   - Linear issues with `code-review` label
   - Review report in `docs/reviews/`

2. **Categorize by Agent**:
   - Backend issues → `backend-agent`
   - Frontend issues → `frontend-agent`
   - Security issues → `security-agent` (for verification after fix)

3. **Fix in Priority Order**:
   - Blockers first
   - Then Major issues
   - Then Minor issues

4. **Spawn Agents**: Use Task tool to spawn appropriate agents in parallel where fixes are independent.

5. **Verify Each Fix**:
   - Run relevant tests after each fix
   - For security fixes, re-run the security check on affected files

6. **Update Linear**: Mark review issues as resolved, add comments describing the fix.

7. **Report**: Checklist of all review comments with fix status.

$ARGUMENTS
