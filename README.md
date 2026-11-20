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
```

## Known limitations

- The backend is simulated; no network request is performed.
- The one-minute sync timer runs only while the Dart process is alive.
- Background tracking depends on platform permissions and lifecycle rules.
  Force-stopping (Android) or force-quitting (iOS) stops tracking.
- Platform behavior must be verified on physical devices; it is not guaranteed
  by emulators or unit tests.
