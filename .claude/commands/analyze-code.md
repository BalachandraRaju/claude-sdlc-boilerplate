# Analyze Code Quality

Run code quality analysis using SonarQube and built-in checks.

## Instructions

1. **Run SonarQube** (if configured):
   ```bash
   bash scripts/sonar-scan.sh
   ```

2. **Run Built-in Checks**:
   - Backend formatting: `cd backend && ./mvnw spotless:check`
   - Frontend lint: `cd frontend && npm run lint`
   - Frontend types: `cd frontend && npm run type-check`
   - Dependency audit: `cd frontend && npm audit`

3. **Manual Analysis** — Spawn `review-agent` to check:
   - Code complexity (deeply nested logic, long methods)
   - Code duplication
   - Dead code / unused imports
   - Missing error handling
   - Performance anti-patterns

4. **Report**: Categorized findings:
   - **Bugs**: Likely runtime errors
   - **Vulnerabilities**: Security issues
   - **Code Smells**: Maintainability issues
   - **Coverage**: Test coverage gaps
   - **Duplications**: Repeated code blocks

5. **Create Issues**: For significant findings, create Linear issues with `code-quality` label.

$ARGUMENTS
