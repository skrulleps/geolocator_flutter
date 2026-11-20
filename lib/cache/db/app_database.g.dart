// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  LocationDao? _locationDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `location_records` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `latitude` REAL NOT NULL, `longitude` REAL NOT NULL, `accuracy` REAL NOT NULL, `altitude` REAL NOT NULL, `speed` REAL NOT NULL, `heading` REAL NOT NULL, `timestamp` INTEGER NOT NULL, `created_at` INTEGER NOT NULL, `sync_status` TEXT NOT NULL, `synced_at` INTEGER)');
        await database.execute(
            'CREATE INDEX `index_location_records_sync_status` ON `location_records` (`sync_status`)');
        await database.execute(
            'CREATE INDEX `index_location_records_timestamp` ON `location_records` (`timestamp`)');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  LocationDao get locationDao {
    return _locationDaoInstance ??= _$LocationDao(database, changeListener);
  }
}

class _$LocationDao extends LocationDao {
  _$LocationDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _locationEntityInsertionAdapter = InsertionAdapter(
            database,
            'location_records',
            (LocationEntity item) => <String, Object?>{
                  'id': item.id,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'accuracy': item.accuracy,
                  'altitude': item.altitude,
                  'speed': item.speed,
                  'heading': item.heading,
                  'timestamp': item.timestamp,
                  'created_at': item.createdAt,
                  'sync_status': item.syncStatus,
                  'synced_at': item.syncedAt
                }),
        _locationEntityUpdateAdapter = UpdateAdapter(
            database,
            'location_records',
            ['id'],
            (LocationEntity item) => <String, Object?>{
                  'id': item.id,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'accuracy': item.accuracy,
                  'altitude': item.altitude,
                  'speed': item.speed,
                  'heading': item.heading,
                  'timestamp': item.timestamp,
                  'created_at': item.createdAt,
                  'sync_status': item.syncStatus,
                  'synced_at': item.syncedAt
                }),
        _locationEntityDeletionAdapter = DeletionAdapter(
            database,
            'location_records',
            ['id'],
            (LocationEntity item) => <String, Object?>{
                  'id': item.id,
                  'latitude': item.latitude,
                  'longitude': item.longitude,
                  'accuracy': item.accuracy,
                  'altitude': item.altitude,
                  'speed': item.speed,
                  'heading': item.heading,
                  'timestamp': item.timestamp,
                  'created_at': item.createdAt,
                  'sync_status': item.syncStatus,
                  'synced_at': item.syncedAt
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<LocationEntity> _locationEntityInsertionAdapter;

  final UpdateAdapter<LocationEntity> _locationEntityUpdateAdapter;

  final DeletionAdapter<LocationEntity> _locationEntityDeletionAdapter;

  @override
  Future<List<LocationEntity>> getAllLocations() async {
    return _queryAdapter.queryList(
        'SELECT * FROM location_records ORDER BY timestamp ASC',
        mapper: (Map<String, Object?> row) => LocationEntity(
            id: row['id'] as int?,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            accuracy: row['accuracy'] as double,
            altitude: row['altitude'] as double,
            speed: row['speed'] as double,
            heading: row['heading'] as double,
            timestamp: row['timestamp'] as int,
            createdAt: row['created_at'] as int,
            syncStatus: row['sync_status'] as String,
            syncedAt: row['synced_at'] as int?));
  }

  @override
  Future<LocationEntity?> getLocationById(int id) async {
    return _queryAdapter.query('SELECT * FROM location_records WHERE id = ?1',
        mapper: (Map<String, Object?> row) => LocationEntity(
            id: row['id'] as int?,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            accuracy: row['accuracy'] as double,
            altitude: row['altitude'] as double,
            speed: row['speed'] as double,
            heading: row['heading'] as double,
            timestamp: row['timestamp'] as int,
            createdAt: row['created_at'] as int,
            syncStatus: row['sync_status'] as String,
            syncedAt: row['synced_at'] as int?),
        arguments: [id]);
  }

  @override
  Future<List<LocationEntity>> getLocationsBySyncStatus(
    String syncStatus,
    int limit,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM location_records WHERE sync_status = ?1 ORDER BY timestamp ASC LIMIT ?2',
        mapper: (Map<String, Object?> row) => LocationEntity(id: row['id'] as int?, latitude: row['latitude'] as double, longitude: row['longitude'] as double, accuracy: row['accuracy'] as double, altitude: row['altitude'] as double, speed: row['speed'] as double, heading: row['heading'] as double, timestamp: row['timestamp'] as int, createdAt: row['created_at'] as int, syncStatus: row['sync_status'] as String, syncedAt: row['synced_at'] as int?),
        arguments: [syncStatus, limit]);
  }

  @override
  Future<LocationEntity?> getLatestLocation() async {
    return _queryAdapter.query(
        'SELECT * FROM location_records ORDER BY timestamp DESC LIMIT 1',
        mapper: (Map<String, Object?> row) => LocationEntity(
            id: row['id'] as int?,
            latitude: row['latitude'] as double,
            longitude: row['longitude'] as double,
            accuracy: row['accuracy'] as double,
            altitude: row['altitude'] as double,
            speed: row['speed'] as double,
            heading: row['heading'] as double,
            timestamp: row['timestamp'] as int,
            createdAt: row['created_at'] as int,
            syncStatus: row['sync_status'] as String,
            syncedAt: row['synced_at'] as int?));
  }

  @override
  Future<int?> countAllLocations() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM location_records',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<int?> countLocationsBySyncStatus(String syncStatus) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM location_records WHERE sync_status = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [syncStatus]);
  }

  @override
  Future<void> updateSyncStatus(
    int id,
    String syncStatus,
    int syncedAt,
  ) async {
    await _queryAdapter.queryNoReturn(
        'UPDATE location_records SET sync_status = ?2, synced_at = ?3 WHERE id = ?1',
        arguments: [id, syncStatus, syncedAt]);
  }

  @override
  Future<void> clearLocations() async {
    await _queryAdapter.queryNoReturn('DELETE FROM location_records');
  }

  @override
  Future<int> insertLocation(LocationEntity location) {
    return _locationEntityInsertionAdapter.insertAndReturnId(
        location, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateLocation(LocationEntity location) async {
    await _locationEntityUpdateAdapter.update(
        location, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteLocation(LocationEntity location) async {
    await _locationEntityDeletionAdapter.delete(location);
  }
}
