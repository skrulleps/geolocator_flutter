import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:geolocator_app/domain/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/domain/models/location_model.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';
import 'package:geolocator_app/domain/services/location_sync_service.dart';

class FakeLocationRepository implements LocationRepository {
  final List<LocationModel> records = [];

  @override
  Future<void> saveLocation(LocationModel location) async {
    records.add(location.copyWith(id: records.length + 1));
  }

  @override
  Future<List<LocationModel>> getAllLocations() async => List.of(records);

  @override
  Future<LocationModel?> getLatestLocation() async =>
      records.isEmpty ? null : records.last;

  @override
  Future<List<LocationModel>> getPendingLocations({
    int limit = 100,
  }) async {
    return records
        .where((record) => !record.isSynced)
        .take(limit)
        .toList(growable: false);
  }

  @override
  Future<void> markAsSynced(int id) async {
    final index = records.indexWhere((record) => record.id == id);
    if (index == -1) {
      throw StateError('Unknown location id: $id');
    }
    records[index] = records[index].copyWith(
      syncStatus: SyncStatus.synced,
      syncedAt: DateTime.now(),
    );
  }

  @override
  Future<void> clearLocations() async {
    records.clear();
  }

  @override
  Future<int> countAllLocations() async => records.length;

  @override
  Future<int> countPendingLocations() async =>
      records.where((record) => !record.isSynced).length;
}

class FakeLocationRemoteDataSource implements LocationRemoteDataSource {
  final List<List<LocationModel>> uploadedBatches = [];
  Completer<void>? gate;
  bool failNextUpload = false;

  @override
  Future<void> uploadLocations(List<LocationModel> locations) async {
    if (gate != null) {
      await gate!.future;
    }
    if (failNextUpload) {
      failNextUpload = false;
      throw const LocationUploadException('Network unavailable');
    }
    uploadedBatches.add(List.of(locations));
  }
}

LocationModel _location(int index) {
  return LocationModel(
    id: index,
    latitude: -6.2 + (index * 0.0001),
    longitude: 106.8 + (index * 0.0001),
    accuracy: 5,
    altitude: 10,
    speed: 0,
    heading: 0,
    timestamp: DateTime(2026, 1, 1).add(Duration(seconds: index)),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  group('LocationSyncService', () {
    test('uploads pending records in batches and marks them synced', () async {
      final repository = FakeLocationRepository();
      for (var i = 1; i <= 205; i++) {
        await repository.saveLocation(_location(i));
      }
      final remote = FakeLocationRemoteDataSource();
      final service = LocationSyncService(
        repository,
        remote,
        batchSize: 100,
      );

      final result = await service.syncPendingLocations();

      expect(result.isSuccess, isTrue);
      expect(result.uploadedCount, 205);
      expect(result.batchCount, 3);
      expect(remote.uploadedBatches.map((batch) => batch.length), [100, 100, 5]);
      expect(await repository.countPendingLocations(), 0);
      expect(
        repository.records.every((record) => record.isSynced),
        isTrue,
      );
    });

    test('keeps pending records when the upload fails', () async {
      final repository = FakeLocationRepository();
      for (var i = 1; i <= 3; i++) {
        await repository.saveLocation(_location(i));
      }
      final remote = FakeLocationRemoteDataSource()..failNextUpload = true;
      final service = LocationSyncService(repository, remote);

      final result = await service.syncPendingLocations();

      expect(result.isSuccess, isFalse);
      expect(result.uploadedCount, 0);
      expect(await repository.countPendingLocations(), 3);
      expect(remote.uploadedBatches, isEmpty);
    });

    test('skips a concurrent synchronization request', () async {
      final repository = FakeLocationRepository();
      await repository.saveLocation(_location(1));
      final remote = FakeLocationRemoteDataSource()
        ..gate = Completer<void>();
      final service = LocationSyncService(repository, remote);

      final firstSync = service.syncPendingLocations();
      final secondResult = await service.syncPendingLocations();

      expect(secondResult.skipped, isTrue);

      remote.gate!.complete();
      final firstResult = await firstSync;

      expect(firstResult.skipped, isFalse);
      expect(firstResult.uploadedCount, 1);
      expect(await repository.countPendingLocations(), 0);
    });

    test('does nothing when there are no pending records', () async {
      final repository = FakeLocationRepository();
      final remote = FakeLocationRemoteDataSource();
      final service = LocationSyncService(repository, remote);

      final result = await service.syncPendingLocations();

      expect(result.isSuccess, isTrue);
      expect(result.uploadedCount, 0);
      expect(remote.uploadedBatches, isEmpty);
    });
  });
}
