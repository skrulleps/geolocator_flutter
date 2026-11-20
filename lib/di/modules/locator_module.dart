import 'package:get_it/get_it.dart';

import 'package:geolocator_app/domain/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';
import 'package:geolocator_app/domain/services/location_sync_service.dart';
import 'package:geolocator_app/domain/services/location_tracking_service.dart';
import 'package:geolocator_app/presentation/controllers/tracking_controller.dart';

var _locator = GetIt.instance;

Future<void> locatorModule() async {
  _locator.registerLazySingleton<LocationTrackingService>(
    () => LocationTrackingService(),
  );

  _locator.registerLazySingleton<LocationSyncService>(
    () => LocationSyncService(
      _locator<LocationRepository>(),
      _locator<LocationRemoteDataSource>(),
    ),
  );

  _locator.registerLazySingleton<TrackingController>(
    () => TrackingController(
      _locator<LocationRepository>(),
      _locator<LocationTrackingService>(),
      _locator<LocationSyncService>(),
    ),
  );
}
