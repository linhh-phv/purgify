# Release

Create a new release for Purgify: bump version, build, create DMG, push, and publish GitHub Release.

## Usage

```
/release          # auto-increment patch: 1.0.1 → 1.0.2
/release 1.1.0    # explicit version
/release minor    # bump minor: 1.0.1 → 1.1.0
/release major    # bump major: 1.0.1 → 2.0.0
```

## Steps

1. **Preflight checks**
   - Ensure working tree is clean (`git status`)
   - Ensure on `master` branch
   - Read current `MARKETING_VERSION` from `Purgify/Purgify.xcodeproj/project.pbxproj`
   - Determine new version:
     - No argument or `patch`: increment patch (1.0.1 → 1.0.2)
     - `minor`: increment minor, reset patch (1.0.1 → 1.1.0)
     - `major`: increment major, reset minor+patch (1.0.1 → 2.0.0)
     - Explicit X.Y.Z: use as-is

2. **Bump version**
   - Update `MARKETING_VERSION` to the new version in `Purgify/Purgify.xcodeproj/project.pbxproj` (all occurrences)
   - Increment `CURRENT_PROJECT_VERSION` by 1 from current value (all occurrences)

3. **Build**
   - Archive: `xcodebuild -project Purgify/Purgify.xcodeproj -scheme Purgify -configuration Release -archivePath /tmp/Purgify.xcarchive archive`
   - Verify `** ARCHIVE SUCCEEDED **` in output

4. **Create DMG**
   - Clean previous: `rm -rf /tmp/purgify-dmg /tmp/Purgify-{version}.dmg`
   - Copy app: `cp -R /tmp/Purgify.xcarchive/Products/Applications/Purgify.app /tmp/purgify-dmg/`
   - Add Applications symlink: `ln -sf /Applications /tmp/purgify-dmg/Applications`
   - Create DMG: `hdiutil create -volname "Purgify" -srcfolder /tmp/purgify-dmg -ov -format UDZO /tmp/Purgify-{version}.dmg`
   - Verify version in built app matches expected

5. **Commit & Tag**
   - `git add Purgify/Purgify.xcodeproj/project.pbxproj`
   - `git commit -m "bump version to {version} (build {N})"`
   - `git tag -a v{version} -m "v{version}"`

6. **Push & Release**
   - `git push origin master && git push origin v{version}`
   - Generate release notes from commits since last tag: `git log {prev_tag}..HEAD --oneline`
   - Create GitHub release: `gh release create v{version} /tmp/Purgify-{version}.dmg --title "Purgify v{version}" --notes "{notes}"`

7. **Report**
   - Print the release URL
   - Print DMG file size
   - Print version and build number

## Notes

- If build fails, do NOT commit or tag — fix the issue first
- Release notes should summarize user-facing changes, not internal refactors
- Push and publish immediately without asking for confirmation
