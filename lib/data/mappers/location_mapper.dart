import 'package:geolocator_app/cache/db/entity/location_entity.dart';
import 'package:geolocator_app/domain/models/location_model.dart';

class LocationMapper {
  const LocationMapper();

  LocationModel toModel(LocationEntity entity) {
    return LocationModel(
      id: entity.id,
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      speed: entity.speed,
      heading: entity.heading,
      timestamp: DateTime.fromMillisecondsSinceEpoch(entity.timestamp),
      createdAt: DateTime.fromMillisecondsSinceEpoch(entity.createdAt),
      syncStatus: SyncStatus.fromValue(entity.syncStatus),
      syncedAt: entity.syncedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(entity.syncedAt!),
    );
  }

  LocationEntity toEntity(LocationModel model) {
    return LocationEntity(
      id: model.id,
      latitude: model.latitude,
      longitude: model.longitude,
      accuracy: model.accuracy,
      altitude: model.altitude,
      speed: model.speed,
      heading: model.heading,
      timestamp: model.timestamp.millisecondsSinceEpoch,
      createdAt: model.createdAt.millisecondsSinceEpoch,
      syncStatus: model.syncStatus.value,
      syncedAt: model.syncedAt?.millisecondsSinceEpoch,
    );
  }
}
