# Security Review: [Feature/Scope]

**Reviewer**: [Name]
**Date**: [Date]
**Scope**: [What was reviewed]
**Overall Risk**: Critical | High | Medium | Low

---

## 1. Summary

Brief overview of findings.

| Severity | Count |
|----------|-------|
| Critical | 0 |
| High | 0 |
| Medium | 0 |
| Low | 0 |

## 2. Findings

### Finding S-1: [Title]
- **Severity**: Critical | High | Medium | Low
- **Category**: [OWASP category, e.g., A01:2021 Broken Access Control]
- **Location**: `file:line`
- **Description**: What the vulnerability is
- **Impact**: What could happen if exploited
- **Recommendation**: How to fix it
- **Linear Issue**: [Link]

### Finding S-2: [Title]
...

## 3. Checks Performed

- [ ] Authentication review
- [ ] Authorization review (RBAC)
- [ ] Input validation
- [ ] SQL injection
- [ ] XSS prevention
- [ ] CSRF protection
- [ ] CORS configuration
- [ ] Security headers
- [ ] Dependency vulnerabilities
- [ ] Secrets/credential scan
- [ ] File upload security
- [ ] Rate limiting
- [ ] Error handling (no stack traces exposed)
- [ ] Logging (no sensitive data logged)

## 4. Dependency Scan Results

| Dependency | Version | CVE | Severity | Fix Version |
|------------|---------|-----|----------|-------------|
| | | | | |

## 5. Recommendations

Prioritized list of security improvements.

## 6. Sign-off

- [ ] All Critical findings resolved
- [ ] All High findings resolved or accepted with risk
- [ ] Security review approved for deployment
