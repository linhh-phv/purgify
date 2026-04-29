#!/bin/bash
set -e

# ---------------------------------------------------------------------------
# Usage:
#   make publish          # patch: 1.0.4 → 1.0.5
#   make publish v=minor  # minor: 1.0.4 → 1.1.0
#   make publish v=major  # major: 1.0.4 → 2.0.0
#   make publish v=1.2.0  # explicit version
# ---------------------------------------------------------------------------

BUMP="${1:-patch}"
PBXPROJ="Purgify/Purgify.xcodeproj/project.pbxproj"

# -- Preflight --
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: working tree is not clean. Commit or stash changes first."
  exit 1
fi

if [[ "$(git branch --show-current)" != "master" ]]; then
  echo "Error: must be on master branch."
  exit 1
fi

# -- Read current version --
CURRENT=$(grep MARKETING_VERSION "$PBXPROJ" | head -1 | awk '{print $3}' | tr -d ';')
BUILD=$(grep -w CURRENT_PROJECT_VERSION "$PBXPROJ" | head -1 | awk '{print $3}' | tr -d ';')
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

# -- Calculate new version --
case "$BUMP" in
  patch)   NEW_VERSION="$MAJOR.$MINOR.$((PATCH + 1))" ;;
  minor)   NEW_VERSION="$MAJOR.$((MINOR + 1)).0" ;;
  major)   NEW_VERSION="$((MAJOR + 1)).0.0" ;;
  [0-9]*.*) NEW_VERSION="$BUMP" ;;
  *)
    echo "Error: invalid argument '$BUMP'. Use patch, minor, major, or X.Y.Z"
    exit 1
    ;;
esac

NEW_BUILD=$((BUILD + 1))

echo "==> Bumping $CURRENT (build $BUILD) → $NEW_VERSION (build $NEW_BUILD)"

# -- Bump version in pbxproj --
sed -i '' "s/MARKETING_VERSION = $CURRENT;/MARKETING_VERSION = $NEW_VERSION;/g" "$PBXPROJ"
sed -i '' "s/CURRENT_PROJECT_VERSION = $BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" "$PBXPROJ"

# -- Commit & tag --
git add "$PBXPROJ"
git commit -m "bump version to $NEW_VERSION (build $NEW_BUILD)"
git tag -a "v$NEW_VERSION" -m "v$NEW_VERSION"

# -- Push → triggers GitHub Actions --
echo "==> Pushing to GitHub..."
git push origin master && git push origin "v$NEW_VERSION"

echo ""
echo "==> Done! GitHub Actions is building v$NEW_VERSION"
echo "    https://github.com/linhh-phv/purgify/actions"
