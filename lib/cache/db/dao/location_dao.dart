import 'package:floor/floor.dart';

import 'package:geolocator_app/cache/db/entity/location_entity.dart';

@dao
abstract class LocationDao {
  @Query('SELECT * FROM location_records ORDER BY timestamp ASC')
  Future<List<LocationEntity>> getAllLocations();

  @Query('SELECT * FROM location_records WHERE id = :id')
  Future<LocationEntity?> getLocationById(int id);

  @Query(
    'SELECT * FROM location_records '
    'WHERE sync_status = :syncStatus '
    'ORDER BY timestamp ASC '
    'LIMIT :limit',
  )
  Future<List<LocationEntity>> getLocationsBySyncStatus(
    String syncStatus,
    int limit,
  );

  @Query(
    'SELECT * FROM location_records ORDER BY timestamp DESC LIMIT 1',
  )
  Future<LocationEntity?> getLatestLocation();

  @Query('SELECT COUNT(*) FROM location_records')
  Future<int?> countAllLocations();

  @Query(
    'SELECT COUNT(*) FROM location_records WHERE sync_status = :syncStatus',
  )
  Future<int?> countLocationsBySyncStatus(String syncStatus);

  @insert
  Future<int> insertLocation(LocationEntity location);

  @update
  Future<void> updateLocation(LocationEntity location);

  @Query(
    'UPDATE location_records '
    'SET sync_status = :syncStatus, synced_at = :syncedAt '
    'WHERE id = :id',
  )
  Future<void> updateSyncStatus(int id, String syncStatus, int syncedAt);

  @delete
  Future<void> deleteLocation(LocationEntity location);

  @Query('DELETE FROM location_records')
  Future<void> clearLocations();
}
