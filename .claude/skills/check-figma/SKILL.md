---
name: check-figma
description: Check Figma design for a specific screen or component before implementing UI changes
argument-hint: "[screen name or frame ID]"
---

# Check Figma Design

Read the Figma design for the requested screen and extract specs.

Figma file link is defined in CLAUDE.md (design block) — read from there.

Steps:
1. Use `get_pages` to list all pages
2. Use `get_design_context` to find the relevant frame by name (or use frame ID if provided)
3. Use `save_screenshots` to capture the design — save to `.figma/` folder (e.g. `.figma/figma-screen-name.png`)
4. Extract: colors, spacing, font sizes, corner radius, layout
5. Map colors to semantic macOS colors for Dark Mode
6. Report specs to the user
