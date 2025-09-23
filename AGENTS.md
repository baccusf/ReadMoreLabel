# Repository Guidelines

## Project Structure & Module Organization
- Core source lives in `Sources/ReadMoreLabel/ReadMoreLabel.swift`; keep public APIs small and well-documented.
- XCTest coverage sits in `Tests/ReadMoreLabelTests`, mirroring production types one-for-one.
- The sample app under `Example/ReadMoreLabelExample` exercises UI flows; update it when altering user-facing behaviors.
- CocoaPods support is defined in `ReadMoreLabel.podspec`; update version fields and platform lists during releases.

## Build, Test, and Development Commands
- `swift build` compiles the SwiftPM target; use before sending reviews to confirm the library builds cleanly.
- `swift test` runs the XCTest suite, including layout-dependent cases—run locally before each push.
- `swiftlint lint` enforces the shared `.swiftlint.yml` rules; install via Homebrew (`brew install swiftlint`) if missing.
- `xed Example/ReadMoreLabelExample.xcodeproj` opens the sample app for manual QA in Xcode; select the iOS 16 simulator target.

## Coding Style & Naming Conventions
- Follow Swift’s defaults: four-space indentation, PascalCase types, camelCase members, SCREAMING_SNAKE_CASE for constants.
- Keep files focused; the lint config warns above 800 lines and 100-line functions.
- Observe enabled SwiftLint rules such as `sorted_imports`, `closure_spacing`, and `switch_case_alignment`; prefer `first(where:)` over manual loops.
- Document public APIs with concise `///` comments, especially when expanding the delegate surface.

## Testing Guidelines
- Add new XCTests beside the related code using the `test_<Scenario>` naming pattern for readability.
- Exercise both collapsed and expanded states when modifying truncation logic; mock delegates as in `ReadMoreLabelTests.swift`.
- If a test depends on layout metrics, note any simulator constraints so failures are actionable.
- Aim to maintain or raise current coverage; justify skips in the pull request if UI-driven code cannot be automated.

## Commit & Pull Request Guidelines
- Write imperative, one-line commit subjects (e.g., `Fix truncation layout glitch`); append issue or PR IDs in parentheses when relevant.
- Group related changes—documentation edits should land separately from behavior fixes.
- Before opening a PR, ensure tests, lint, and the example app pass; include screenshots or GIFs for UI adjustments.
- Reference tracked issues, summarise verification steps, and call out any follow-up work to help reviewers plan.
