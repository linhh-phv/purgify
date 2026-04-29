#!/bin/bash
set -eo pipefail

# ---------------------------------------------------------------------------
# Usage:
#   Local:  ./scripts/release.sh         (uses macOS Keychain)
#   CI:     APPLE_API_KEY=<p8 content> APPLE_API_KEY_ID=<id> APPLE_API_ISSUER=<issuer> ./scripts/release.sh
# ---------------------------------------------------------------------------

KEY_ID="PFSCV92MBJ"
ISSUER_ID="3d2a1e41-4e36-4831-b4cf-205475ab86b6"
KEYCHAIN_PROFILE="purgify-notary"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_PATH="$SCRIPT_DIR/../.credentials/AuthKey_${KEY_ID}.p8"

PROJECT="Purgify/Purgify.xcodeproj"
SCHEME="Purgify"
ARCHIVE="/tmp/Purgify.xcarchive"
EXPORT_DIR="/tmp/PurgifyExport"
EXPORT_OPTIONS="scripts/ExportOptions.plist"

VERSION=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -showBuildSettings 2>/dev/null | grep MARKETING_VERSION | awk '{print $3}')
BUILD=$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -showBuildSettings 2>/dev/null | grep -w CURRENT_PROJECT_VERSION | awk '{print $3}')
DMG_PATH="/tmp/Purgify-${VERSION}.dmg"

# -- Notarize helper (works in both local and CI mode) --
notarize() {
  local target="$1"
  if [[ -n "$APPLE_API_KEY" ]]; then
    # CI mode: write p8 to temp file, use direct flags
    local tmp_key
    tmp_key=$(mktemp /tmp/AuthKey.XXXXXX.p8)
    echo "$APPLE_API_KEY" > "$tmp_key"
    xcrun notarytool submit "$target" \
      --key "$tmp_key" \
      --key-id "${APPLE_API_KEY_ID:-$KEY_ID}" \
      --issuer "${APPLE_API_ISSUER:-$ISSUER_ID}" \
      --wait
    rm -f "$tmp_key"
  else
    # Local mode: use Keychain profile (setup once on first run)
    if ! xcrun notarytool history --keychain-profile "$KEYCHAIN_PROFILE" --max-date 2000-01-01 > /dev/null 2>&1; then
      echo "==> First-time setup: saving API key to Keychain..."
      xcrun notarytool store-credentials "$KEYCHAIN_PROFILE" \
        --key "$KEY_PATH" \
        --key-id "$KEY_ID" \
        --issuer "$ISSUER_ID"
      echo "==> Keychain profile saved."
      echo ""
    fi
    xcrun notarytool submit "$target" \
      --keychain-profile "$KEYCHAIN_PROFILE" \
      --wait
  fi
}

echo "==> Purgify v${VERSION} (build ${BUILD})"

# 1. Archive
echo "==> Archiving..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
  -configuration Release -archivePath "$ARCHIVE" \
  MACOSX_DEPLOYMENT_TARGET=13.0 \
  clean archive

# 2. Export with Developer ID signing
echo "==> Exporting..."
rm -rf "$EXPORT_DIR"
xcodebuild -exportArchive \
  -archivePath "$ARCHIVE" \
  -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist "$EXPORT_OPTIONS"

APP_PATH="$EXPORT_DIR/Purgify.app"

# 3. Notarize app
echo "==> Notarizing app..."
ditto -c -k --keepParent "$APP_PATH" /tmp/Purgify.zip
notarize /tmp/Purgify.zip
rm /tmp/Purgify.zip

# 4. Staple app
echo "==> Stapling app..."
xcrun stapler staple "$APP_PATH"

# 5. Create DMG
echo "==> Creating DMG..."
rm -rf /tmp/purgify-dmg "$DMG_PATH"
mkdir -p /tmp/purgify-dmg
cp -R "$APP_PATH" /tmp/purgify-dmg/
ln -sf /Applications /tmp/purgify-dmg/Applications
hdiutil create -volname "Purgify" -srcfolder /tmp/purgify-dmg \
  -ov -format UDZO "$DMG_PATH"

# 6. Notarize DMG
echo "==> Notarizing DMG..."
notarize "$DMG_PATH"

# 7. Staple DMG
echo "==> Stapling DMG..."
xcrun stapler staple "$DMG_PATH"

echo ""
echo "==> Done! DMG ready at: $DMG_PATH"
