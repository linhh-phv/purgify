---
paths:
  - "Purgify/**/*.swift"
---

# Swift Conventions

## Project Structure

```
Purgify/Purgify/
├── PurgifyApp.swift
├── Models/          (CacheItem, RiskLevel, CacheDefinitions)
├── ViewModels/      (CacheScannerViewModel)
├── Services/        (CacheScanService protocol + LocalCacheScanService)
├── Managers/        (LocalizationManager)
├── Utilities/       (ByteFormatter)
└── Views/
    ├── Components/  (LanguageToggle)
    ├── MainWindow/  (MainWindowView, SidebarView, ContentListView, ContentRowView,
    │                 DetailPanelView, SubItemsDetailView, EmptyStateView, ScanningView)
    └── MenuBar/     (MenuBarView)
```

## Rules

- Use MVVM pattern: Views → ViewModel → Service
- Views access ViewModel via `@EnvironmentObject`, never create directly
- Service layer uses protocols for testability (`CacheScanService`)
- Use `@MainActor` on ViewModels and Managers
- Use `nonisolated` on Service methods that run off-main-thread
- Use semantic colors: `Color(nsColor: .systemGreen)` not hardcoded hex — for Dark Mode support
- Localization: add keys to both EN and VI dictionaries in `LocalizationManager.swift`
- Use `%1`, `%2` placeholders (not `%@`) when a string has multiple substitutions
- File naming: Views end with `View.swift`, ViewModels end with `ViewModel.swift`
