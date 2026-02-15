# Generate UI Mockups

Generate React component mockups from PRD or design requirements.

## Instructions

1. **Read Requirements**: Read the PRD from `docs/prd/` or take user input about UI needs.

2. **Spawn Frontend Agent**: Use the Task tool with `frontend-agent` to:
   - Identify all screens/pages needed
   - Design component hierarchy
   - Create mockup components as working React/TSX code

3. **Generate Mockups**:
   - Create mockup files in `docs/mockups/` as `.tsx` files
   - Each mockup should be a working React component with:
     - Responsive layout
     - Placeholder data matching expected API shapes
     - Comments explaining design decisions
     - Basic interactivity (navigation, form handling)

4. **Browser Preview** (if Playwright MCP available):
   - Serve the mockups locally
   - Take screenshots for review
   - Save screenshots to `docs/mockups/screenshots/`

5. **Report**: Present mockups to user with:
   - Component tree overview
   - Screen-by-screen summary
   - Design decisions and alternatives considered

$ARGUMENTS
