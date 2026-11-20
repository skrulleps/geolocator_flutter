import 'package:flutter_test/flutter_test.dart';

import 'package:geolocator_app/cache/db/entity/location_entity.dart';
import 'package:geolocator_app/data/mappers/location_mapper.dart';
import 'package:geolocator_app/domain/models/location_model.dart';

void main() {
  const mapper = LocationMapper();

  group('LocationMapper', () {
    test('maps an entity to a model', () {
      final entity = LocationEntity(
        id: 7,
        latitude: -6.2,
        longitude: 106.8,
        accuracy: 4.5,
        altitude: 12.3,
        speed: 1.2,
        heading: 90,
        timestamp: DateTime(2026, 1, 2, 3, 4).millisecondsSinceEpoch,
        createdAt: DateTime(2026, 1, 2, 3, 5).millisecondsSinceEpoch,
        syncStatus: 'synced',
        syncedAt: DateTime(2026, 1, 2, 3, 6).millisecondsSinceEpoch,
      );

      final model = mapper.toModel(entity);

      expect(model.id, 7);
      expect(model.latitude, -6.2);
      expect(model.longitude, 106.8);
      expect(model.accuracy, 4.5);
      expect(model.altitude, 12.3);
      expect(model.speed, 1.2);
      expect(model.heading, 90);
      expect(model.timestamp, DateTime(2026, 1, 2, 3, 4));
      expect(model.createdAt, DateTime(2026, 1, 2, 3, 5));
      expect(model.syncStatus, SyncStatus.synced);
      expect(model.syncedAt, DateTime(2026, 1, 2, 3, 6));
      expect(model.isSynced, isTrue);
    });

    test('maps a model to an entity with pending status', () {
      final model = LocationModel(
        latitude: 1.5,
        longitude: 2.5,
        accuracy: 3,
        altitude: 4,
        speed: 5,
        heading: 6,
        timestamp: DateTime(2026, 5, 6, 7, 8),
        createdAt: DateTime(2026, 5, 6, 7, 9),
      );

      final entity = mapper.toEntity(model);

      expect(entity.id, isNull);
      expect(entity.latitude, 1.5);
      expect(entity.longitude, 2.5);
      expect(entity.timestamp, model.timestamp.millisecondsSinceEpoch);
      expect(entity.createdAt, model.createdAt.millisecondsSinceEpoch);
      expect(entity.syncStatus, 'pending');
      expect(entity.syncedAt, isNull);
    });

    test('unknown sync status is treated as pending', () {
      expect(SyncStatus.fromValue('unexpected'), SyncStatus.pending);
    });
  });
}
