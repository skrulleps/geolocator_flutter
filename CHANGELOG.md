## Unreleased
### Added
- Menambahkan flavor dev, staging, dan production beserta entry point lib/main\_dev.dart, lib/main\_staging.dart, dan lib/main\_production.dart
- Menambahkan konfigurasi flavorizr.yaml dan android/app/flavorizr.gradle.kts untuk applicationId, app name, serta bundle ID per flavor
- Mengisolasi database lokal per flavor melalui gps\_tracking\_<flavor>.db
- CI membangun APK dan AAB release untuk setiap flavor secara paralel

### Changed
- Bootstrap aplikasi sekarang menerima parameter Flavor dan judul aplikasi mengikuti flavor aktif
- GitHub Release hanya mempublikasikan artifact production, sedangkan dev dan staging tersedia sebagai workflow artifact
- Memperbarui README dengan tabel flavor, perintah run/build, dan catatan regenerasi flavorizr

### Fixed
- Menyesuaikan script Gradle hasil FlutterFlavorizr dengan Android Gradle Plugin 9 menggunakan ApplicationExtension dan buildFeatures.resValues
