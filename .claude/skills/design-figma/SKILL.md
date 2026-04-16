---
name: design-figma
description: Create or modify Figma designs for Purgify UI. Use when the user asks to design, draw, update UI, add screens, or modify layouts in Figma.
---

# Design in Figma

Figma file link is defined in CLAUDE.md (design block) — read from there.

## Before Designing

1. Read existing designs using `get_design_context` to understand current style
2. Check `get_styles` for the color palette and typography

## Color Palette

| Token | Light | Usage |
|-------|-------|-------|
| s1 | #ffffff | White / backgrounds |
| s2 | #f5f5f5 | Title bar bg |
| s6 | #1c1c1e | Primary text |
| s7 | #34c759 | Green / Safe |
| s8 | #8e8e93 | Secondary text |
| s9 | #007aff | Accent blue |
| s10 | #e5e5ea | Dividers |
| s11 | #f2f2f7 | Control background |
| s12 | #ff9500 | Orange / Moderate |
| s13 | #ff3b30 | Red / Caution |
| s15 | #fafafa | Content bg |
| s20 | #1264ea | App icon blue |

## Typography

- Title: Inter Bold, 16-22px, #1c1c1e
- Body: Inter Regular, 13px, #3c3c43
- Caption: Inter Regular, 10-12px, #8e8e93
- Labels: Inter Medium, 12-13px

## After Designing

1. Take screenshot with `save_screenshots` — save to `.figma/` folder (e.g. `.figma/figma-screen-name.png`) and show the user
2. Add prototype reactions between related frames
3. Ask user for approval before implementing in code
