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
1. Generate PRD → `/generate-prd` with `prd-agent`
2. Review PRD → `/review-prd` with `review-agent`
3. **User checkpoint**: Present PRD for approval before proceeding

### Phase 2: Design (Parallel where possible)
4. Create implementation doc from template → `docs/implementation/IMPL-<feature>.md`
5. Architecture design + diagrams → `architect-agent`
   - Architecture diagram → `docs/diagrams/<feature>/architecture.excalidraw.json`
   - Data flow diagram → `docs/diagrams/<feature>/data-flow.excalidraw.json`
   - ER diagram (if new tables) → `docs/diagrams/<feature>/er-diagram.excalidraw.json`
6. UI mockups → `/generate-mockups` with `frontend-agent`
   - Component tree diagram → `docs/diagrams/<feature>/component-tree.excalidraw.json`
7. **User checkpoint**: Present design + diagrams for approval

### Phase 3: Implementation + Testing (Interleaved)
Tests run after EACH implementation step — not deferred to a separate phase.

8. Create team with TeamCreate
9. Create tasks with interleaved test dependencies (see `/launch-team` for the full task list):

   **Backend — build + test each layer**:
   - DB migrations → Entities + Repos → **Repository tests (run now)** → Services → **Service tests (run now)** → Controllers + DTOs → **Integration tests (run now)**

   **Frontend — build + test each layer (starts after controllers)**:
   - API services → **API service tests (run now)** → Components → **Component tests (run now)** → Pages → **E2E tests (run now)**

10. Spawn agents — all agents read `docs/implementation/IMPL-<feature>.md` for context
11. Resolve all TODOs: `/resolve-todos`
12. Run full test suite — all tests must be green before proceeding
13. **User checkpoint**: User reviews implementation + test results

### Phase 4: Quality (Parallel)
14. Code review → `/review-code` with `review-agent`
15. Security review → `/security-review` with `security-agent`
16. Code quality → `/analyze-code` with `review-agent`
17. Fix any findings → `/fix-review`
18. Re-run full test suite after fixes — must stay green
19. **User checkpoint**: User reviews quality findings

### Phase 6: Documentation
22. Update implementation doc with final state:
    - All files changed
    - All endpoints created
    - How to test manually
    - Lessons learned
23. Update diagrams if implementation diverged from design
24. Generate final sequence diagram for key flows

### Phase 7: Deploy
25. Build local → `/build-local`
26. Deploy staging → `/deploy-staging`
27. Deploy production → `/deploy-prod` (user confirmation required)

### Phase 8: Ship
28. Final review pass
29. Update Linear issues to "Done"
30. Generate session summary
31. If using worktree, remind: "Merge when ready: `git checkout main && git merge feature/<feature-name>`"
32. Clean up: `bash scripts/worktree-cleanup.sh <feature-name>` (after merge)

$ARGUMENTS
