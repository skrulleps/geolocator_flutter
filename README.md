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

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## Validation

```bash
flutter analyze
flutter test
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release
```

## CI/CD and versioning

The workflow in `.github/workflows/ci.yml` runs on every pull request targeting
`main` and on every push to `main`:

1. Reads the application version from `version:` in `pubspec.yaml`.
2. Runs Floor code generation, `flutter analyze`, and `flutter test`.
3. Builds a release APK and release Android App Bundle.
4. Uploads both files as workflow artifacts.
5. On a push/merge to `main`, creates a GitHub Release tagged with the same
   version as the app, for example `v1.0.0+1`, and attaches the APK and AAB.

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
