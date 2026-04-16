---
paths:
  - "Purgify/**/Managers/LocalizationManager.swift"
  - "Purgify/**/Views/**/*.swift"
---

# Localization Rules

- All user-facing text MUST use `l10n.t("key")` — never hardcode strings
- Every new key MUST be added in BOTH `.en` and `.vi` dictionaries
- Use `%1`, `%2` for multiple placeholders — NOT `%@` (replaceAll bug)
- Key naming: `section.subsection.name` (e.g. `detail.clean`, `subitem.projects`)
- Cache descriptions should explain: what creates it, what it stores, impact of deleting, effect on existing projects
