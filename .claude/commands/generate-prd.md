# Generate PRD

Generate a Product Requirements Document for a feature.

## Instructions

You are orchestrating PRD generation. Follow these steps:

1. **Gather Input**: Ask the user for:
   - Feature name and brief description
   - Target users
   - Key problem being solved
   - Any specific requirements or constraints

2. **Research**: If a Linear project exists, fetch existing issues and context using the Linear MCP tools.

3. **Generate PRD**: Use the Task tool to spawn a `prd-agent` to:
   - Read the template from `docs/templates/prd-template.md`
   - Generate a comprehensive PRD
   - Save it to `docs/prd/PRD-<feature-name>.md`

4. **Create Linear Issues**: Use Linear MCP to:
   - Create a project (if one doesn't exist)
   - Create issues for each user story/requirement
   - Label them appropriately (prd, feature, story, task)
   - Set priorities based on PRD

5. **Report**: Show the user:
   - Link to the generated PRD
   - Summary of Linear issues created
   - Any open questions or ambiguities

$ARGUMENTS
