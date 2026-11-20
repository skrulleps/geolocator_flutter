import 'dart:async';

import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

import 'package:geolocator_app/cache/db/dao/location_dao.dart';
import 'package:geolocator_app/cache/db/entity/location_entity.dart';

part 'app_database.g.dart';

@Database(version: 1, entities: [LocationEntity])
abstract class AppDatabase extends FloorDatabase {
  LocationDao get locationDao;

  /// Removes every locally stored location record.
  ///
  /// Kept on the database for maintenance tasks only. Presentation code must
  /// use the repository instead.
  Future<void> clearDatabase() async {
    await database.execute('DELETE FROM location_records');
  }
}
