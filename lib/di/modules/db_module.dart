import 'package:get_it/get_it.dart';

import 'package:geolocator_app/cache/db/app_database.dart';
import 'package:geolocator_app/cache/db/dao/location_dao.dart';
import 'package:geolocator_app/data/datasources/location_local_datasource.dart';
import 'package:geolocator_app/data/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/data/mappers/location_mapper.dart';
import 'package:geolocator_app/data/repositories/location_repository_impl.dart';
import 'package:geolocator_app/domain/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';
import 'package:geolocator_app/flavors.dart';

var _locator = GetIt.instance;

Future<void> dbModule() async {
  final database = await $FloorAppDatabase
      .databaseBuilder('gps_tracking_${F.name}.db')
      .build();

  _locator.registerSingleton<AppDatabase>(database);
  _locator.registerSingleton<LocationDao>(database.locationDao);

  _locator.registerSingleton<LocationLocalDataSource>(
    LocationLocalDataSource(database.locationDao),
  );

  _locator.registerSingleton<LocationRemoteDataSource>(
    SimulatedLocationRemoteDataSource(),
  );

  _locator.registerSingleton<LocationMapper>(const LocationMapper());

  _locator.registerSingleton<LocationRepository>(
    LocationRepositoryImpl(
      _locator<LocationLocalDataSource>(),
      _locator<LocationMapper>(),
    ),
  );
}
