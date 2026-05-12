# Purgify

A lightweight macOS menu bar app that scans and cleans caches across your Mac — developer tools, browsers, apps, and system — to free up disk space.

<p align="center">
  <a href="https://buymeacoffee.com/decx">
    <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" width="200" alt="Buy Me A Coffee" />
  </a>
</p>

<p align="center">
  <img src=".figma/figma-main-normal.png" width="800" alt="Purgify Main Window" />
</p>

## Features

- Scans **79 cache types** across categories — no permission prompts required by default:
  - **Developer tools** — npm, Yarn, pnpm, Bun, CocoaPods, Xcode DerivedData, SwiftUI Previews, Gradle, Maven, Docker, Cargo, pip, Poetry, Flutter, Go, Terraform, nvm, and more
  - **Browsers** — Chrome, Arc, Firefox, Brave, Edge, Vivaldi, Opera, DuckDuckGo
  - **Media apps** — Spotify, VLC, IINA, Plex
  - **Communication** — Slack, MS Teams, Discord, Zoom, Telegram
  - **Creative** — Adobe Media Cache, Sketch
  - **IDEs & editors** — JetBrains, VS Code, Cursor, Zed, Sublime Text
  - **Productivity** — Raycast, Notion, Obsidian
  - **Games** — Steam
  - **System** — QuickLook, App Store, User Logs, iOS/watchOS/tvOS/visionOS Device Support
- **Mobile VM management** — list and selectively remove stale iOS Simulators, iOS Runtimes, Android AVDs, and Android System Images with last-used dates and sizes
- **User file detection** — surfaces old installers (`.dmg`, `.pkg`), archives (`.zip`, `.tar.gz`, `.rar`), and disc images (`.iso`) in Downloads, Desktop, and Documents so you can safely prune them
- **Advanced scanning** (optional) — unlocks Safari, Mail Downloads, Apple Music, and Diagnostic Reports with Full Disk Access
- **Safe by design — items go to Trash, not permanently erased.** Restore anything you didn't mean to remove directly from Trash
- **Review before cleaning** — a confirmation sheet lists every file and folder that will be moved, with the exact path and a Finder reveal button, before anything is touched
- Risk-based categorization: **Safe**, **Moderate**, **Caution**
- Selective cleaning — choose exactly what to remove
- Progressive scan — results stream in as scanning completes, no waiting
- Menu bar quick view + full 3-column window app
- Vietnamese & English language support
- Dark Mode support

<p align="center">
  <img src=".figma/figma-main-popover.png" width="300" alt="Menu Bar Popover" />
  &nbsp;&nbsp;
  <img src=".figma/settings-compact-advanced-on.png" width="300" alt="Settings" />
</p>

## Requirements

- macOS 13 Ventura or later
- Apple Silicon or Intel Mac

## Install

1. Download the latest `.dmg` from [GitHub Releases](https://github.com/linhh-phv/purgify/releases/latest)
2. Open the DMG and drag **Purgify** to Applications
3. First launch: right-click the app → **Open** (to bypass Gatekeeper)

## Build from Source

```bash
git clone https://github.com/linhh-phv/purgify.git
cd purgify/Purgify
open Purgify.xcodeproj
```

Build and run with **⌘R** in Xcode. No external dependencies required.

## Usage

1. Click the **Purgify** icon in the menu bar to see detected caches
2. Click **Open Full App** for the detailed 3-column view
3. Select caches by risk level, review individual items, and clean selectively
4. A preview sheet lists exactly what will be moved to Trash — confirm or cancel before anything happens
5. Optionally enable **Advanced Scanning** in Settings to unlock 4 additional protected caches

## Architecture

```
Purgify/Purgify/
├── PurgifyApp.swift
├── Models/          (CacheItem, RiskLevel, CacheDefinitions)
├── ViewModels/      (CacheScannerViewModel)
├── Services/        (CacheScanService)
├── Managers/        (LocalizationManager)
├── Utilities/       (ByteFormatter, Color+Brand)
└── Views/
    ├── Components/  (CleanSuccessView, LanguageToggle, PostCleanBanner)
    ├── MainWindow/  (MainWindowView, SidebarView, ContentListView, ContentRowView,
    │                 DetailPanelView, SubItemsDetailView, CleanPreviewSheet,
    │                 EmptyStateView, ScanningView)
    ├── MenuBar/     (MenuBarView)
    └── Settings/    (SettingsView, FDAGuideView)
```

- **Pattern**: MVVM
- **Layout**: 3-column (Sidebar 220px | Content List 400px | Detail Panel 460px)
- **Localization**: All strings in `LocalizationManager.swift` — EN + VI

## Contributing

Pull requests are welcome. For major changes, open an issue first to discuss what you'd like to change.

1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-feature`)
3. Commit your changes
4. Open a pull request

## License

MIT License — see [LICENSE](LICENSE) for details.

Made with ♥ by [Pham Linh](https://github.com/linhh-phv)
