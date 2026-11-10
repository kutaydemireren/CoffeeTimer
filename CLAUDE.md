# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

CoffeeTimer is a free, open-source iOS brewing timer (SwiftUI, iOS 17.6+, Swift 5) that walks the user through a brew step by step. It ships built-in brew methods (V60, Chemex, AeroPress, French Press, ...), custom recipes and methods, and a coffee/water ratio calculator. It is published on the App Store. Default branch is `main`; `develop` also exists.

Dependencies come from Swift Package Manager through the Xcode project (no Package.swift): `firebase-ios-sdk` (Analytics without IDFA, Crashlytics) and `lottie-ios`.

## Build and test

There is one Xcode project (`CoffeeTimer.xcodeproj`), one shared scheme (`CoffeeTimer`) and two targets: the app and `CoffeeTimerTests` (XCTest, `@testable import CoffeeTimer`). No linter, CI or Makefile is configured.

The build needs `CoffeeTimer/iOS/Resources/GoogleService-Info.plist`. It is gitignored, so a fresh clone or worktree fails with "Build input file cannot be found" until you copy it in from an existing checkout. Never commit it.

```sh
# Run all tests
xcodebuild test -project CoffeeTimer.xcodeproj -scheme CoffeeTimer \
  -destination 'platform=iOS Simulator,name=iPhone 17'

# Run one test class or one test method
xcodebuild test -project CoffeeTimer.xcodeproj -scheme CoffeeTimer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:CoffeeTimerTests/RecipeRepositoryImpTests/test_getSelectedRecipe_whenNotExists_shouldReturnNil
# (drop the method name to run the whole class)
```

## Architecture

Layered, protocol-first design. Each layer depends on protocols from the layer below.

- **Domain** (`CoffeeTimer/Entities`, `BrewMethod`, `Recipe`, `RecipeInstructions`, `Timer`): entities plus use cases (`GetBrewMethodsUseCase`, `CreateRecipeFromContextUseCase`, ...) and the repository protocols they call.
- **Data** (`CoffeeTimer/Repository`, `Network`): `*RepositoryImp` implementations, DTOs and mappers (`Repository/Shared/DTOs.swift`, `RecipeMapper`), `Request` types and `NetworkManagerImp`. Local persistence is `StorageImp`, which JSON-encodes `Codable` values into `UserDefaults` (keys such as `selectedRecipe` and `savedRecipes`).
- **Presentation** (`CoffeeTimer/iOS`): SwiftUI views with `ObservableObject` view models under `Scene/<Feature>`. Navigation is done by flow views in `Scene/Flow` (`AppFlowView` is the root). Child view models expose Combine publishers (`didComplete`, `didRequestEdit`) and the parent flow view model subscribes to them to present or dismiss screens.
- **Analytics** (`CoffeeTimer/Analytics`): `AnalyticsTracker` protocol with a Firebase-backed implementation. View models track `AnalyticsEvent`s, and tests in `CoffeeTimerTests/Source/Analytics` assert the events each view model sends.

Brew methods and their step-by-step instructions are remote JSON, not bundled code:
- `data/v0/brew-methods.json` and `data/v0/brew-instructions/<method-id>.json` are the source.
- DEBUG builds fetch them from `raw.githubusercontent.com/.../main/data/v0/...`, so they read whatever is on `main` on GitHub. Release builds fetch from Firebase Hosting (`data/public/v0/...`). See `GetBrewMethodsRequest` and `FetchRecipeInstructionsRequest`.
- `data/public/` is the Firebase Hosting site (coffeetimer.app). Besides the JSON it holds the privacy policy and support pages, including pages for the separate CookingTimer app.

App startup (`CoffeeTimerApp` → `AppDelegate`) runs `AppInitializerImp` first. It applies `Migration`s through `MigrationRunnerImp`, which stores completed migration versions in `UserDefaults`, and only then configures Firebase. To change the persisted recipe format, add a new `Migration` with a higher `version` and register it in `AppInitializer.swift`.

## Conventions

- Every dependency is a protocol (`Foo`) with a concrete `FooImp`. Implementations take their dependencies as init parameters with production defaults (`init(repository: BrewMethodRepository = BrewMethodRepositoryImp())`), and tests inject mocks through those parameters.
- Tests mirror the source layout: `CoffeeTimerTests/Source/...` holds `<Type>ImpTests`, `CoffeeTimerTests/Mock/...` holds hand-written `Mock<Protocol>` classes, and `CoffeeTimerTests/Resources/*.json` holds instruction fixtures loaded through `Utils/loadInstructions.swift`. Test methods are named `test_<method>_when<Condition>_should<Result>`.
- Preview and stub data lives in `CoffeeTimer/Preview Content` (`Entities+Stub.swift`, `Instructions+Stub.swift`).
- Colors come from named assets in `iOS/Resources/Colors.xcassets` (`backgroundPrimary`, `foregroundPrimary`, ...). The app forces the light color scheme.

## Guardrails

- This is a public open-source repository. Never commit anything private: keys, `GoogleService-Info.plist`, personal data or internal notes.
- Never touch App Store Connect, TestFlight, signing or other release tooling.
- Never run `firebase deploy` (from `data/`): it publishes the live brew data and website.
- Edits to `data/v0` take effect for every DEBUG build once they reach `main` on GitHub. Keep the JSON schema backward compatible with the shipped app.
