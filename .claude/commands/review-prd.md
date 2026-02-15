# Review PRD

Review an existing Product Requirements Document for completeness and quality.

## Instructions

1. **Find the PRD**: Look in `docs/prd/` for the specified PRD, or list available PRDs for the user to choose.

2. **Spawn Review Agent**: Use the Task tool with `review-agent` to analyze:
   - **Completeness**: All required sections present and filled
   - **Clarity**: No ambiguous language, clear acceptance criteria
   - **Feasibility**: Requirements achievable with Java/Spring Boot + React + PostgreSQL
   - **Testability**: Each requirement has measurable acceptance criteria
   - **Scope**: Clear boundaries, explicit out-of-scope items

3. **Check Linear Alignment**: Verify Linear issues match PRD requirements — flag gaps.

4. **Generate Review Report**: Output findings with severity levels:
   - **Must Fix**: Missing critical sections, ambiguous requirements
   - **Should Fix**: Incomplete acceptance criteria, unclear scope
   - **Suggestion**: Improvements for clarity or completeness

5. **Update Linear**: Create issues for PRD fixes if needed.

$ARGUMENTS
