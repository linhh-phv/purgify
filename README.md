# Purgify

A lightweight macOS menu bar app that scans and cleans developer caches to free up disk space.

## Features

- Menu bar quick view + full window app
- Scans 12 cache types categorized by risk level
- Vietnamese & English language support
- Scan once, clean selectively

## What it cleans

| Risk | Caches | Note |
|------|--------|------|
| **Safe** | npm, Yarn, Yarn Berry, Corepack, Bun, Homebrew, CocoaPods | No impact on projects |
| **Moderate** | Xcode DerivedData, Gradle, Metro | May need rebuild |
| **Caution** | pnpm Store, Docker Images | Review before deleting |

## Install

### Download (recommended)

1. Download `Purgify-1.0.dmg` from [Releases](https://github.com/linhh-phv/purgify/releases)
2. Open the DMG and drag **Purgify** to Applications
3. First launch: right-click the app → **Open** (to bypass Gatekeeper)
4. Purgify appears in the menu bar

### Build from source

Requires macOS 14.0+ and Xcode 15+.

```bash
git clone https://github.com/linhh-phv/purgify.git
cd purgify
open Purgify/Purgify.xcodeproj
```

1. Select **My Mac** as the build target
2. Press **Cmd+R** to build and run

> **Note:** Disable **App Sandbox** in Signing & Capabilities for full file system access.

## Usage

1. Click the Purgify icon in the menu bar to see a summary of detected caches
2. Click **Open Full App** for the detailed view
3. Select the caches you want to clean (safe items are pre-selected)
4. Click **Clean Selected** and confirm

## License

MIT
