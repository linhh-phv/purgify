---
paths:
  - "Purgify/**/Views/**/*.swift"
---

# Figma Workflow

When modifying or creating UI views:
1. Read the Figma design first using `figma-mcp-go` tools (`get_design_context`, `get_node`, `save_screenshots`)
2. Extract colors, spacing, font sizes, corner radius from Figma specs
3. Map Figma colors to semantic macOS colors for Dark Mode
4. If design doesn't exist for the new view, create it in Figma first for user approval
5. After implementation, compare with Figma screenshot visually

Figma file link is defined in CLAUDE.md (design block) — read from there.
