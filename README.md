# Purgify

A lightweight macOS menu bar app that cleans developer caches and frees up disk space.

## What it cleans

| Category | Caches | Risk |
|----------|--------|------|
| **Safe** | npm, Yarn, Corepack, Bun, Homebrew, CocoaPods | No impact on projects |
| **Moderate** | Xcode DerivedData, Gradle, Metro | May need rebuild |
| **Caution** | pnpm Store, Docker Images | Review before deleting |

## Requirements

- macOS 14.0+
- Xcode 15+

## Install from source

```bash
git clone https://github.com/phamlinh/purgify.git
cd purgify
open Purgify/Purgify.xcodeproj
```

1. In Xcode, select **My Mac** as the build target
2. Press **Cmd+R** to build and run
3. Purgify appears in the menu bar

> **Note:** Disable **App Sandbox** in Signing & Capabilities for full file system access.

## Features

- Menu bar quick view + full window app
- Categorized by risk level (Safe / Moderate / Caution)
- Vietnamese & English support
- Scan once, clean selectively

## License

MIT
