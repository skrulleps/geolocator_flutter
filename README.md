# GPS Tracking MVP

A Flutter application for researching mobile GPS tracking behavior. It collects
location updates, stores them locally with SQLite (Floor), visualizes the
history on a map, and synchronizes pending records in batches to a simulated
backend.

## Features

- Continuous foreground GPS collection with Android foreground notification.
- Local-first storage using Floor / SQLite.
- Batch synchronization (100 records per batch, one-minute interval while the
  application process is active).
- Pending records survive network failures and application restarts.
- Map with historical points, polyline, and latest position marker.
- Battery percentage and charging state indicators.
- Manual start, stop, sync, and clear-history controls.

## Architecture

```text
Presentation (GetX)
      |
      v
Domain (models, repository contracts, tracking + sync services)
      |
      v
Data (local/remote data sources, mapper, repository implementation)
      |
      v
Cache (Floor entities, DAO, database)
```

Dependency injection is centralized in `lib/di`. See `docs/ARCHITECTURE.md` for
the full structure and rules.

## Flavors

The app has three flavors, defined in `flavorizr.yaml`:

| Flavor | Entry point | Android applicationId | iOS bundle ID |
| --- | --- | --- | --- |
| `dev` | `lib/main_dev.dart` | `com.example.geolocator_app.dev` | `com.example.geolocatorApp.dev` |
| `staging` | `lib/main_staging.dart` | `com.example.geolocator_app.staging` | `com.example.geolocatorApp.staging` |
| `production` | `lib/main_production.dart` | `com.example.geolocator_app` | `com.example.geolocatorApp` |

Run a flavor with:

```bash
flutter run --flavor dev -t lib/main_dev.dart
flutter run --flavor staging -t lib/main_staging.dart
flutter run --flavor production -t lib/main_production.dart
```

Each flavor uses its own local database (`gps_tracking_<flavor>.db`), so dev,
staging, and production data do not mix on the same device. Flavor names and
titles live in `lib/flavors.dart`.

Android configuration is generated into `android/app/flavorizr.gradle.kts` and
wired from `android/app/build.gradle.kts`. If you change `flavorizr.yaml`,
regenerate only the Android processors on Windows:

```bash
dart run flutter_flavorizr -f
```

> **AGP 9 note:** FlutterFlavorizr 2.6.0 emits a Gradle script based on the
> legacy `AppExtension`. This project uses the Android Gradle Plugin 9 DSL, so
> `android/app/flavorizr.gradle.kts` has been adapted to use
> `ApplicationExtension` plus an explicit `buildFeatures { resValues = true }`.
> If you regenerate it, re-apply that adaptation before building. The checked-in
> version is the working configuration.

iOS configuration requires macOS because FlutterFlavorizr also regenerates the
Xcode schemes and the Podfile. On a Mac, run the full default processor set with
`dart run flutter_flavorizr -f` (or `flutter pub run flutter_flavorizr`) after
`flutter pub get`, then verify the generated schemes in Xcode.

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run --flavor dev -t lib/main_dev.dart
```

## Validation

```bash
flutter analyze
flutter test
flutter build apk --debug --flavor dev -t lib/main_dev.dart
flutter build apk --release --flavor production -t lib/main_production.dart
flutter build appbundle --release --flavor production -t lib/main_production.dart
```

## CI/CD and versioning

The workflow in `.github/workflows/ci.yml` runs on every pull request targeting
`main` and on every push to `main`:

1. Reads the application version from `version:` in `pubspec.yaml`.
2. Runs Floor code generation, `flutter analyze`, and `flutter test`.
3. Builds a release APK and release Android App Bundle for `dev`, `staging`,
   and `production` in parallel.
4. Uploads each flavor's files as workflow artifacts.
5. On a push/merge to `main`, creates a GitHub Release tagged with the same
   version as the app, for example `v1.0.0+1`, and attaches the production APK
   and AAB. Dev and staging builds remain available as workflow artifacts only.
   The release body is taken from the matching version section in
   `CHANGELOG.md`, falling back to the `Unreleased` section.

Changelog entries are managed with [Cider](https://pub.dev/packages/cider):

```bash
cider log added "New feature"
cider log changed "Behaviour change"
cider log fixed "Bug fix"
cider release   # moves Unreleased to the current pubspec version
```

To release a new version, update `version:` in `pubspec.yaml` in the pull
request. Android `versionName` and `versionCode` are already derived from that
same value, so the app and the GitHub Release always stay in sync.

The release build currently uses the debug signing configuration defined in
`android/app/build.gradle.kts`. Configure a production keystore before
publishing to Google Play.

## Known limitations

- The backend is simulated; no network request is performed.
- The one-minute sync timer runs only while the Dart process is alive.
- Background tracking depends on platform permissions and lifecycle rules.
  Force-stopping (Android) or force-quitting (iOS) stops tracking.
- Platform behavior must be verified on physical devices; it is not guaranteed
  by emulators or unit tests.
