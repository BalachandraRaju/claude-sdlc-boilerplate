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

### Phase 3: Implementation + Testing (Interleaved)
Tests run after EACH implementation step — not deferred to a separate phase.

10. Create team with TeamCreate
11. Create tasks with interleaved test dependencies (see `/launch-team` for the full task list):

   **Backend — build + test each layer**:
   - DB migrations → Entities + Repos → **Repository tests (run now)** → Services → **Service tests (run now)** → Controllers + DTOs → **Integration tests (run now)** (verify `ApiResponse` format)

   **Frontend — build + test each layer (starts after controllers)**:
   - API services → **API service tests (run now)** (verify `unwrapResponse`/`extractError`) → Components → **Component tests + browser automation (run now)** → Pages → **E2E Playwright tests + full browser automation (run now)**

12. Spawn agents — all agents read `docs/implementation/IMPL-<feature>.md` for context
13. **User checkpoint**: User reviews implementation progress

### Phase 4: Validation (Test Generation + Browser Automation)
14. Resolve all TODOs: `/resolve-todos` — fix or create Linear issues
15. Generate comprehensive test plan: `/generate-tests` — map every PRD criterion to test cases
16. Run full test suite: `/run-tests` — all backend + frontend + E2E must pass
17. Browser automation validation:
    - Navigate every page with Playwright MCP
    - Screenshot each state (empty, loading, data, error)
    - Verify form submissions end-to-end
    - Verify error display matches `ApiError` format from backend
    - Verify pagination controls work
18. **User checkpoint**: User confirms all tests pass + browser verification looks correct

### Phase 5: Quality (Parallel)
19. Code review → `/review-code` with `review-agent`
20. Security review → `/security-review` with `security-agent`
21. Code quality → `/analyze-code` with `review-agent`
22. Fix any findings → `/fix-review`
23. Re-run full test suite after fixes — must stay green
24. Re-run browser automation — verify fixes didn't break UI
25. **User checkpoint**: User reviews quality findings

### Phase 6: Documentation
26. Update implementation doc with final state:
    - All files changed
    - All endpoints created (with `ApiResponse` format examples)
    - How to test manually
    - Lessons learned
27. Update diagrams if implementation diverged from design
28. Generate final sequence diagram for key flows

### Phase 7: Deploy
29. Build local → `/build-local`
30. Deploy staging → `/deploy-staging`
31. Deploy production → `/deploy-prod` (user confirmation required)

### Phase 8: Ship
32. Final review pass
33. Update Linear issues to "Done"
34. Generate session summary
35. If using worktree, remind: "Merge when ready: `git checkout main && git merge feature/<feature-name>`"
36. Clean up: `bash scripts/worktree-cleanup.sh <feature-name>` (after merge)

$ARGUMENTS
