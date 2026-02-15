# Deploy to Staging

Build and deploy the application to the staging environment.

## Instructions

### Pre-Deploy Checks (all must pass)
Run these in parallel:
1. **Tests**: `bash scripts/run-all-tests.sh`
2. **Lint**: `cd backend && ./mvnw spotless:check` AND `cd frontend && npm run lint`
3. **Type check**: `cd frontend && npm run type-check`
4. **Security**: `cd frontend && npm audit --audit-level=high`

If ANY check fails, stop and report the failure. Do NOT proceed with deployment.

### Build
```bash
bash scripts/build-local.sh
```

### Deploy
```bash
bash scripts/deploy-staging.sh
```

### Post-Deploy Verification
1. Check staging health endpoint: `curl -f https://staging.example.com/api/v1/health`
2. Run smoke tests against staging (if Playwright MCP available):
   - Hit key API endpoints
   - Verify frontend loads
   - Check DB connectivity
3. Report deployment status

### On Failure
- Check deployment logs
- If build failed: report build errors
- If deploy failed: report infrastructure errors
- If smoke tests failed: report which checks failed
- Create Linear issue with `deployment` and `staging` labels for tracking

### Update Linear
Mark relevant issues as "In Staging" if that status exists.

$ARGUMENTS
