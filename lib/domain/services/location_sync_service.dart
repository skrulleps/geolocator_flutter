import 'package:geolocator_app/domain/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';

class SyncResult {
  final int uploadedCount;
  final int batchCount;
  final bool skipped;
  final String? errorMessage;

  const SyncResult({
    this.uploadedCount = 0,
    this.batchCount = 0,
    this.skipped = false,
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null;

  const SyncResult.skipped()
      : uploadedCount = 0,
        batchCount = 0,
        skipped = true,
        errorMessage = null;
}

class LocationSyncService {
  static const int defaultBatchSize = 100;
  static const Duration defaultSyncInterval = Duration(minutes: 1);

  final LocationRepository _repository;
  final LocationRemoteDataSource _remoteDataSource;
  final int batchSize;

  bool _isSyncing = false;

  LocationSyncService(
    this._repository,
    this._remoteDataSource, {
    this.batchSize = defaultBatchSize,
  });

  bool get isSyncing => _isSyncing;

  /// Uploads pending records in batches.
  ///
  /// Records are only marked as synced after the simulated backend accepts the
  /// batch. Failed batches are left pending so a later run can retry them.
  Future<SyncResult> syncPendingLocations() async {
    if (_isSyncing) {
      return const SyncResult.skipped();
    }

    _isSyncing = true;

    var uploadedCount = 0;
    var batchCount = 0;

    try {
      while (true) {
        final pending = await _repository.getPendingLocations(
          limit: batchSize,
        );

        if (pending.isEmpty) {
          break;
        }

        try {
          await _remoteDataSource.uploadLocations(pending);
        } catch (error) {
          return SyncResult(
            uploadedCount: uploadedCount,
            batchCount: batchCount,
            errorMessage: error.toString(),
          );
        }

        for (final location in pending) {
          final id = location.id;
          if (id == null) {
            continue;
          }
          await _repository.markAsSynced(id);
        }

        uploadedCount += pending.length;
        batchCount += 1;

        if (pending.length < batchSize) {
          break;
        }
      }

      return SyncResult(
        uploadedCount: uploadedCount,
        batchCount: batchCount,
      );
    } finally {
      _isSyncing = false;
    }
  }
}
