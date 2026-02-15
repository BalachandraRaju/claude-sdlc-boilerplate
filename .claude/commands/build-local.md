# Build Local

Build both backend and frontend locally and verify everything compiles.

## Instructions

Run the full local build pipeline:

### 1. Backend Build
```bash
cd backend && ./mvnw clean package -DskipTests
```
If this fails, read the error output and fix compilation issues.

### 2. Frontend Build
```bash
cd frontend && npm install && npm run build
```
If this fails, run `npm run type-check` and `npm run lint` to identify the issue.

### 3. Verify Artifacts
- Backend: Check that `backend/target/*.jar` exists
- Frontend: Check that `frontend/dist/` directory has content

### 4. Report
Tell the user:
- Backend build: pass/fail + JAR location
- Frontend build: pass/fail + dist size
- Any warnings that should be addressed

$ARGUMENTS
