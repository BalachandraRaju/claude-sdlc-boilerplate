# Security Review

Perform a comprehensive security analysis of the codebase.

## Instructions

1. **Spawn Security Agent**: Use the Task tool with `security-agent` to perform a full security review.

2. **Automated Scans**:
   - Backend dependencies: `cd backend && ./mvnw dependency-check:check` (OWASP dependency check)
   - Frontend dependencies: `cd frontend && npm audit`
   - Secrets scan: Check for hardcoded credentials, API keys, tokens

3. **Manual Review Areas**:
   - Authentication flow (JWT generation, validation, refresh)
   - Authorization checks (role-based access on all endpoints)
   - Input validation (all user inputs sanitized)
   - SQL injection (parameterized queries only)
   - XSS prevention (React auto-escaping, no dangerouslySetInnerHTML)
   - CORS configuration
   - CSRF protection
   - Security headers
   - File upload handling (if any)
   - Rate limiting

4. **Create Linear Issues**: For each finding:
   - **Critical/High**: Create issue with `security` + `critical`/`high-priority` labels
   - **Medium/Low**: Create issue with `security` label

5. **Generate Report**: Save to `docs/security/SECURITY-REVIEW-<date>.md` using the security review template.

$ARGUMENTS
