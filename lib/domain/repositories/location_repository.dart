import 'package:geolocator_app/domain/models/location_model.dart';

abstract class LocationRepository {
  Future<void> saveLocation(LocationModel location);

  Future<List<LocationModel>> getAllLocations();

  Future<LocationModel?> getLatestLocation();

  Future<List<LocationModel>> getPendingLocations({
    int limit = 100,
  });

  Future<void> markAsSynced(int id);

  Future<void> clearLocations();

  Future<int> countAllLocations();

  Future<int> countPendingLocations();
}
