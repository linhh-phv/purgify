.PHONY: run run-release build archive dmg

PROJECT = Purgify/Purgify.xcodeproj
SCHEME = Purgify
DERIVED = /tmp/PurgifyBuild
ARCHIVE = /tmp/Purgify.xcarchive

run:
	@./scripts/run.sh

run-release:
	@./scripts/run.sh Release

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -derivedDataPath $(DERIVED) build

archive:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Release -archivePath $(ARCHIVE) archive

dmg:
	rm -rf /tmp/purgify-dmg /tmp/Purgify-$(VERSION).dmg
	mkdir -p /tmp/purgify-dmg
	cp -R $(ARCHIVE)/Products/Applications/Purgify.app /tmp/purgify-dmg/
	ln -sf /Applications /tmp/purgify-dmg/Applications
	hdiutil create -volname "Purgify" -srcfolder /tmp/purgify-dmg -ov -format UDZO /tmp/Purgify-$(VERSION).dmg
