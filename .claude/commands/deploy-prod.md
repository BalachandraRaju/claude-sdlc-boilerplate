# Deploy to Production

Build and deploy the application to the production environment.

## Instructions

### CRITICAL: This requires explicit user confirmation at multiple steps.

### Step 1: Pre-Deploy Validation
Run ALL of these — every single one must pass:
1. `bash scripts/run-all-tests.sh` — All tests green
2. `cd backend && ./mvnw spotless:check` — Code formatted
3. `cd frontend && npm run lint` — No lint errors
4. `cd frontend && npm run type-check` — No type errors
5. `cd frontend && npm audit --audit-level=high` — No high/critical CVEs
6. `cd backend && ./mvnw dependency-check:check` — No high/critical CVEs
7. Check that staging deployment was successful and verified

If ANY check fails, **stop immediately** and report. Do NOT proceed.

### Step 2: User Confirmation (MANDATORY)
Use `AskUserQuestion` to ask:
> "All pre-deploy checks passed. Ready to deploy to PRODUCTION. This will affect live users. Proceed?"
>
> Options: "Yes, deploy to production" / "No, cancel"

**Do NOT proceed without explicit "Yes" from the user.**

### Step 3: Build & Deploy
```bash
bash scripts/build-local.sh
bash scripts/deploy-prod.sh
```

### Step 4: Post-Deploy Verification
1. Check production health: `curl -f https://app.example.com/api/v1/health`
2. Run production smoke tests (read-only operations only)
3. Monitor error rates for 5 minutes if possible

### Step 5: Rollback Plan
If post-deploy checks fail:
- Ask user: "Post-deploy verification failed. Roll back to previous version?"
- If yes: `bash scripts/rollback-prod.sh`
- Create Linear issue with `production` and `incident` labels

### Step 6: Update Linear
Mark relevant issues as "Done" / "Deployed".

$ARGUMENTS
