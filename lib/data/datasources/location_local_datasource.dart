import 'package:geolocator_app/cache/db/dao/location_dao.dart';
import 'package:geolocator_app/cache/db/entity/location_entity.dart';

/// Thin wrapper around the Floor DAO so the repository implementation does
/// not depend on persistence details directly.
class LocationLocalDataSource {
  final LocationDao _locationDao;

  const LocationLocalDataSource(this._locationDao);

  Future<int> insertLocation(LocationEntity entity) {
    return _locationDao.insertLocation(entity);
  }

  Future<List<LocationEntity>> getAllLocations() {
    return _locationDao.getAllLocations();
  }

  Future<LocationEntity?> getLatestLocation() {
    return _locationDao.getLatestLocation();
  }

  Future<List<LocationEntity>> getLocationsBySyncStatus(
    String syncStatus, {
    required int limit,
  }) {
    return _locationDao.getLocationsBySyncStatus(syncStatus, limit);
  }

  Future<void> updateSyncStatus(
    int id,
    String syncStatus,
    int syncedAt,
  ) {
    return _locationDao.updateSyncStatus(id, syncStatus, syncedAt);
  }

  Future<void> clearLocations() {
    return _locationDao.clearLocations();
  }

  Future<int> countAllLocations() async {
    return await _locationDao.countAllLocations() ?? 0;
  }

  Future<int> countLocationsBySyncStatus(String syncStatus) async {
    return await _locationDao.countLocationsBySyncStatus(syncStatus) ?? 0;
  }
}
