#!/bin/bash
set -e

CONFIG="${1:-Debug}"
PROJECT="Purgify/Purgify.xcodeproj"
DERIVED="/tmp/PurgifyBuild"

pkill -x Purgify 2>/dev/null || true

echo "Building Purgify ($CONFIG)..."
xcodebuild -project "$PROJECT" -scheme Purgify -configuration "$CONFIG" -derivedDataPath "$DERIVED" build 2>&1 | tail -5

open "$DERIVED/Build/Products/$CONFIG/Purgify.app"
echo "Purgify is running."
