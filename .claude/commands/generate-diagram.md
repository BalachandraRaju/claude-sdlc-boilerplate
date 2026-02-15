# Generate Excalidraw Diagram

Generate an Excalidraw diagram to visually explain architecture, data flow, or implementation design.

## Instructions

### Step 1: Determine What to Diagram
Based on `$ARGUMENTS` or by asking the user, identify the diagram type:
- **Architecture** — System components, layers, and their relationships
- **Data Flow** — How data moves through the system (request → controller → service → DB → response)
- **Entity Relationship** — Database tables and their relationships
- **Sequence** — Step-by-step interaction between components for a specific flow
- **Component Tree** — React component hierarchy
- **API Flow** — Frontend → API → Backend → DB round-trip
- **Deployment** — Infrastructure and deployment architecture

### Step 2: Read Context
- Read the relevant PRD from `docs/prd/`
- Read the implementation doc from `docs/implementation/` if it exists
- Read relevant source code to understand actual implementation

### Step 3: Generate the Excalidraw JSON
Create the diagram as an Excalidraw-compatible JSON file. Use the structure from `docs/templates/excalidraw-template.json`.

Key guidelines for generating Excalidraw elements:
- Use **rectangles** for components/services/classes (type: "rectangle")
- Use **diamonds** for decision points (type: "diamond")
- Use **ellipses** for start/end points (type: "ellipse")
- Use **arrows** for data flow / relationships (type: "arrow")
- Use **text** labels on every shape (type: "text")
- Use consistent colors:
  - Blue (`#1971c2`) for backend components
  - Green (`#2f9e44`) for frontend components
  - Orange (`#e8590c`) for database/storage
  - Purple (`#7048e8`) for external services
  - Red (`#e03131`) for security boundaries
  - Gray (`#868e96`) for infrastructure
- Arrange elements left-to-right or top-to-bottom for flow diagrams
- Use grouping for related components (group IDs)
- Keep spacing consistent (100px between elements)

### Step 4: Save the Diagram
Save to: `docs/diagrams/<feature-name>/<diagram-type>.excalidraw.json`

Also generate a text description of the diagram in the same directory:
`docs/diagrams/<feature-name>/<diagram-type>.md`

This markdown companion file should contain:
- A text description of what the diagram shows
- Key design decisions illustrated
- Reference to the PRD/implementation doc sections the diagram covers

### Step 5: Update Implementation Doc
If an implementation doc exists at `docs/implementation/IMPL-<feature>.md`, add a reference to the new diagram in the "Diagrams" section.

### Step 6: Report
Tell the user:
- Where the diagram was saved
- How to open it: "Open the `.excalidraw.json` file at https://excalidraw.com or in VS Code with the Excalidraw extension"
- What the diagram shows

$ARGUMENTS
