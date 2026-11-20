import 'package:geolocator_app/data/datasources/location_local_datasource.dart';
import 'package:geolocator_app/data/mappers/location_mapper.dart';
import 'package:geolocator_app/domain/models/location_model.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource _localDataSource;
  final LocationMapper _mapper;

  const LocationRepositoryImpl(this._localDataSource, this._mapper);

  @override
  Future<void> saveLocation(LocationModel location) async {
    await _localDataSource.insertLocation(_mapper.toEntity(location));
  }

  @override
  Future<List<LocationModel>> getAllLocations() async {
    final entities = await _localDataSource.getAllLocations();
    return entities.map(_mapper.toModel).toList(growable: false);
  }

  @override
  Future<LocationModel?> getLatestLocation() async {
    final entity = await _localDataSource.getLatestLocation();
    return entity == null ? null : _mapper.toModel(entity);
  }

  @override
  Future<List<LocationModel>> getPendingLocations({
    int limit = 100,
  }) async {
    final entities = await _localDataSource.getLocationsBySyncStatus(
      SyncStatus.pending.value,
      limit: limit,
    );
    return entities.map(_mapper.toModel).toList(growable: false);
  }

  @override
  Future<void> markAsSynced(int id) async {
    await _localDataSource.updateSyncStatus(
      id,
      SyncStatus.synced.value,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Future<void> clearLocations() {
    return _localDataSource.clearLocations();
  }

  @override
  Future<int> countAllLocations() {
    return _localDataSource.countAllLocations();
  }

  @override
  Future<int> countPendingLocations() {
    return _localDataSource.countLocationsBySyncStatus(
      SyncStatus.pending.value,
    );
  }
}
