# Implementation Doc: [Feature Name]

**Author**: [Name/Agent]
**Date**: [Date]
**PRD Reference**: `docs/prd/PRD-<feature>.md`
**Branch**: `feature/<feature-name>`
**Worktree**: `../worktrees/<feature-name>/`
**Status**: In Progress | Complete | Superseded

---

## 1. Overview

Brief summary of what was implemented and why. Link back to the PRD for full requirements.

## 2. Diagrams

Excalidraw diagrams explaining the implementation:

| Diagram | File | Description |
|---------|------|-------------|
| Architecture | `docs/diagrams/<feature>/architecture.excalidraw.json` | System component overview |
| Data Flow | `docs/diagrams/<feature>/data-flow.excalidraw.json` | Request/response flow |
| ER Diagram | `docs/diagrams/<feature>/er-diagram.excalidraw.json` | Database entity relationships |
| Component Tree | `docs/diagrams/<feature>/component-tree.excalidraw.json` | React component hierarchy |

Open `.excalidraw.json` files at https://excalidraw.com or with the VS Code Excalidraw extension.

## 3. Database Changes

### New Tables
```sql
-- List new tables with key columns
```

### Modified Tables
```sql
-- List ALTER TABLE changes
```

### Migration Files
- `V<N>__<description>.sql` — What it does

## 4. Backend Implementation

### New Endpoints
| Method | Path | Description | Auth |
|--------|------|-------------|------|
| | | | |

### Service Layer
- `<ServiceName>` — What it does, key business rules

### Key Design Decisions
- Why this approach was chosen over alternatives

## 5. Frontend Implementation

### New Pages
| Route | Component | Description |
|-------|-----------|-------------|
| | | |

### New Components
| Component | Location | Purpose |
|-----------|----------|---------|
| | | |

### State Management
How state flows for this feature.

## 6. Testing

### Tests Written
| Type | File | Coverage |
|------|------|----------|
| Unit (Backend) | | |
| Unit (Frontend) | | |
| Integration | | |
| E2E | | |

### Edge Cases Covered
- List specific edge cases tested

## 7. Security Considerations

- Auth/authz changes made
- Input validation added
- Any new attack surface

## 8. Files Changed

### New Files
```
backend/src/main/java/com/app/...
frontend/src/...
```

### Modified Files
```
List modified files
```

## 9. How to Test Manually

Step-by-step guide for manual QA:
1. ...
2. ...

## 10. Known Limitations & Future Work

- What's not included in this implementation
- TODOs for future iterations
- Performance considerations for scale

## 11. Lessons Learned

<!--
Record anything unexpected that came up during implementation.
If it's a reusable pattern, also add it to CLAUDE.md "Known Issues & Fixes".
-->
