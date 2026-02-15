# Full SDLC Pipeline

Run the complete software development lifecycle for a feature — from PRD to deployed, tested code.

## Instructions

This is the master orchestration command. It runs the full SDLC pipeline with proper sequencing and parallel execution where possible.

### Phase 0: Setup
1. Ask the user using `AskUserQuestion`:
   > "Should I create a git worktree for this feature? Keeps work isolated from other branches."
   > Options: "Yes, create worktree (Recommended)" / "No, work on current branch"
2. If yes: `bash scripts/worktree-new.sh <feature-name>`

### Phase 1: Requirements (Sequential)
3. Generate PRD → `/generate-prd` with `prd-agent`
4. Review PRD → `/review-prd` with `review-agent`
5. **User checkpoint**: Present PRD for approval before proceeding

### Phase 2: Design (Parallel where possible)
6. Create implementation doc from template → `docs/implementation/IMPL-<feature>.md`
7. Architecture design + diagrams → `architect-agent`
   - Architecture diagram → `docs/diagrams/<feature>/architecture.excalidraw.json`
   - Data flow diagram → `docs/diagrams/<feature>/data-flow.excalidraw.json`
   - ER diagram (if new tables) → `docs/diagrams/<feature>/er-diagram.excalidraw.json`
8. UI mockups → `/generate-mockups` with `frontend-agent`
   - Component tree diagram → `docs/diagrams/<feature>/component-tree.excalidraw.json`
9. **User checkpoint**: Present design + diagrams for approval

### Phase 3: Test Case Generation (BEFORE implementation)
10. Generate test plan from PRD → `/generate-tests` with `test-agent`:
    - Read every acceptance criterion from `docs/prd/`
    - Read the implementation doc and diagrams from Phase 2
    - Build a **test matrix** mapping each criterion to test cases at each layer:

    | Criterion | Unit (Backend) | Unit (Frontend) | Integration | E2E |
    |-----------|---------------|-----------------|-------------|-----|
    | "User can create profile" | ServiceTest | FormTest | POST → 201 | Fill form → submit → verify |
    | "Name is required" | shouldFail_whenNull | shows error | POST empty → 400 | Submit empty → see error |

    - Write the test plan document: `docs/test-plans/TEST-<feature>.md`
    - Every cell in the matrix = actual test code to be written
    - The test plan drives all test steps in Phase 4
11. **User checkpoint**: User reviews and approves test plan before implementation

### Phase 4: Implementation + Testing (Interleaved)
Tests run after EACH implementation step. Test-agent references the test plan from Phase 3 at each step.

12. Create team with TeamCreate
13. Create tasks with interleaved test dependencies (see `/launch-team` for the full task list):

   **Backend — build + test each layer**:
   - DB migrations → Entities + Repos → **Repository tests (run now)** → Services → **Service tests (run now)** → Controllers + DTOs → **Integration tests (run now)** (verify `ApiResponse` format)

   **Frontend — build + test each layer (starts after controllers)**:
   - API services → **API service tests (run now)** (verify `unwrapResponse`/`extractError`) → Components → **Component tests + browser automation (run now)** → Pages → **E2E Playwright tests + full browser automation (run now)**

14. Spawn agents — all agents read `docs/implementation/IMPL-<feature>.md` and `docs/test-plans/TEST-<feature>.md` for context
15. **User checkpoint**: User reviews implementation progress

### Phase 5: Validation (Coverage Check + Browser Automation)
16. Resolve all TODOs: `/resolve-todos` — fix or create Linear issues
17. Verify test plan coverage: cross-check `docs/test-plans/TEST-<feature>.md` — every PRD criterion must have passing tests
18. Run full test suite: `/run-tests` — all backend + frontend + E2E must pass
19. Browser automation validation:
    - Navigate every page with Playwright MCP
    - Screenshot each state (empty, loading, data, error)
    - Verify form submissions end-to-end
    - Verify error display matches `ApiError` format from backend
    - Verify pagination controls work
20. **User checkpoint**: User confirms all tests pass + browser verification looks correct

### Phase 6: Quality (Parallel)
21. Code review → `/review-code` with `review-agent`
22. Security review → `/security-review` with `security-agent`
23. Code quality → `/analyze-code` with `review-agent`
24. Fix any findings → `/fix-review`
25. Re-run full test suite after fixes — must stay green
26. Re-run browser automation — verify fixes didn't break UI
27. **User checkpoint**: User reviews quality findings

### Phase 7: Documentation
28. Update implementation doc with final state:
    - All files changed
    - All endpoints created (with `ApiResponse` format examples)
    - How to test manually
    - Lessons learned
29. Update test plan with actual results and coverage
30. Update diagrams if implementation diverged from design
31. Generate final sequence diagram for key flows

### Phase 8: Deploy
32. Build local → `/build-local`
33. Deploy staging → `/deploy-staging`
34. Deploy production → `/deploy-prod` (user confirmation required)

### Phase 9: Ship
35. Final review pass
36. Update Linear issues to "Done"
37. Generate session summary
38. If using worktree, remind: "Merge when ready: `git checkout main && git merge feature/<feature-name>`"
39. Clean up: `bash scripts/worktree-cleanup.sh <feature-name>` (after merge)

$ARGUMENTS
