# Repository Guidelines

## Quick Reference

- See @README.md for project overview.
- -scheme "AgentOrange" is release version pointing to live supabase  

## For Daily Development

### Overview

- iOS 26 SwiftUI app targeting iPhone, iPad, macOS (Designed for iPad)
- Minimum deployment: iOS 26
- Swift 6.3 with strict concurrency
- Use SwiftUI throughout - no UIKit unless absolutely necessary
- Use Apple's newest Swift Testing framework
- Strict MVVM architecture
- Use xcrun mcpbridge `BuildProject` for compilation, not shell commands, or
- `xcodebuildmcp simulator build --scheme "AgentOrange(Develop)" --project-path AgentOrange.xcodeproj --simulator-name "iPhone 17" --derived-data-path "build/"`
- If above fails, use: `xcodebuild -project AgentOrange.xcodeproj -scheme "AgentOrange(Develop)" -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath "build/" build 2>&1 | grep -E 'error:|BUILD (SUCCEEDED|FAILED)|\*\* BUILD' | head -20`
- Do NOT use `-destination 'generic/platform=iOS Simulator` with xcodebuild, always use `-destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath "build/"`
- Previews available via `RenderPreview`
- For unit tests, use `RunAllTests` or `RunSomeTests`

### Project Structure & Module Organization

- The SwiftUI MVVM app source lives in `AgentOrange/`, organised by feature under `Modules/` (for example `Dashboard`, `Circle`, `Journal`).
- Shared services and utilities are in `Services/` and `Utils/`; keep reusable UI in `Modules/SharedViews`.
- Assets are managed via `Assets.xcassets`, while configuration files such as API endpoints belong in `Config/`.
- Unit and integration tests sit in `AgentOrangeTests/`, with UI flows in `AgentOrangeUITests/`.

### Dependencies

- **FactoryKit**: Dependency injection framework - simplifies testing by allowing service mocking. Mostly used to inject dependencies into ViewModel classes.
- **Firebase Firestore**: Backend integration via `GoogleService-Info-{ENV}.plist` files.
- **Swift Testing**: Apple's modern testing framework using `@Test` and `@Suite` macros.
- **GRDB**: SQLite toolkit for Swift, used for local database management.

### Coding Style & Naming Conventions

- Follow Swift 6.3 style with four-space indentation and descriptive `CamelCase` types.
- Think hard about preventing concurrency issues such as objects crossing actor boundaries and sendability issues.
- Group related views and models by feature inside the matching `Modules/Module` folder.
- Name SwiftUI views with the `*View` suffix, models with `*Model`, viewModels with `*ViewModel`, services with `*ServiceImpl` where the protocol is named `*Service`.
- Keep service protocols in `Services/` and concrete implementations in subfolders named for the dependency.
- Prefer `@MainActor` annotations for UI entry points. If SwiftLint is enabled, run `bundle exec fastlane lint` before pushing and address reported issues.
- Prefer using `FactoryKit` for dependency injection to simplify testing and improve modularity - it allows easy swapping of implementations and clean test setup.

### Why These Patterns?

- **FactoryKit over manual DI**: Eliminates boilerplate, provides `.test` scope for mocking, and maintains compile-time safety.
- **Protocol + Impl naming**: Makes it clear which files define contracts vs implementations, aids navigation.
- **Feature-based modules**: Keeps related code together, reduces merge conflicts, easier to reason about changes.
- **`@MainActor` for UI**: Prevents concurrency bugs by ensuring UI updates happen on the main thread.

### FactoryKit DI Conventions

- Register app dependencies in `AgentOrange/DI/` using `extension Container`; keep factories grouped by domain.
- Resolve stable services and ViewModels from `Container.shared`, but keep runtime context such as IDs, routes, callbacks, and SwiftUI environment values as explicit parameters.
- Scope only true app-wide resources as singletons (`SupabaseClient`, root stores, root coordinator). ViewModels and feature services should remain fresh unless shared state is intentional.
- SwiftUI previews should use FactoryKit preview registrations or `Container.shared.usePreviewMocks()` before constructing dependency-backed views.
- Swift Testing suites should use the FactoryTesting container trait (`.AgentOrangeContainer`) and register mocks on `Container.shared` inside the scoped test.

### Anti-Patterns to Avoid

- Avoid passing `@State` or `@ObservedObject` across actor boundaries - causes Sendable warnings.
- Don't hardcode environment-specific values - use `BuildConfig.swift` and `.xcconfig` files.
- Never commit secrets, .env files, API keys, or certificates - use fastlane match and Keychain.
- Avoid massive ViewModels - split into smaller, focused components or extract business logic to services.
- Don't use force unwrapping (`!`) without clear justification - prefer optional chaining or guard statements.

### Data Model

- Data model documentation found here: /instructions/AgentOrange_Evidence_Data_Model.md
- Sample data for testing in `Resources/SampleData/`.

### Testing Guidelines

- Verify code with unit tests for each module.
- Add feature tests under matching folders in `AgentOrangeTests/` using Apple's Swift Testing framework.
- Use `@Test` and `@Suite` macros from Swift Testing framework instead of XCTest where possible.
- Mock services using FactoryKit's `.test` scope:
  ```swift
  Container.shared.databaseService.register { MockDatabaseService() }
  ```
- Mirror file names with a `Tests` suffix (e.g., `LoginViewModel.swift` → `LoginViewModelTests.swift`).
- UI regressions should be covered in `AgentOrangeUITests/` with XCTest and `XCUIApplication`.
- Ensure fastlane test runs remain green and retain generated coverage reports in `fastlane/test_output/report.html` for review.
- When introducing async code, include expectation-based tests to avoid flaky behaviour.
- Run unit tests before pushing to verify no regressions.

### Debugging & Troubleshooting

- Use OSLog categories defined in `Utils/OSLog+Utils.swift` for structured logging.
- Database inspection: Check `DatabaseServiceImpl` implementation in `Services/Database/`.
- Auth issues: Review `KeychainService` and `CognitoService` logs, verify tokens aren't expired.

## For Reviewing

### Pull Request Review Checklist

- Verify commit subjects follow present tense (e.g., `ADDS: inverter live chart data`) and stay under ~60 characters.
- Config updates in `Config/` need validation - ensure no secrets are committed and environment variables are correctly scoped.
- Check for proper error handling, especially around async/await and database operations.
- Verify new dependencies are necessary and approved - check `Package.resolved` changes.
- Ensure `@MainActor` annotations are present on UI entry points to prevent concurrency issues.

### What to Look For

- **Concurrency safety**: No data races, proper actor isolation, Sendable conformance where needed.
- **Test coverage**: New features have corresponding tests, edge cases covered.
- **Performance**: No obvious performance issues (N+1 queries, unnecessary re-renders).
- **Security**: No hardcoded secrets, proper Keychain usage, secure network calls.
- **Accessibility**: VoiceOver labels, Dynamic Type support, sufficient contrast ratios.
