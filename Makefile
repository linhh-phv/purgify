.PHONY: run run-release build release publish

PROJECT = Purgify/Purgify.xcodeproj
SCHEME = Purgify
DERIVED = /tmp/PurgifyBuild

run:
	@./scripts/run.sh

run-release:
	@./scripts/run.sh Release

build:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -derivedDataPath $(DERIVED) build

release:
	@chmod +x scripts/release.sh && ./scripts/release.sh

publish:
	@chmod +x scripts/publish.sh && ./scripts/publish.sh $(v)
