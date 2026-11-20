import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'package:geolocator_app/domain/models/location_model.dart';
import 'package:geolocator_app/domain/repositories/location_repository.dart';
import 'package:geolocator_app/domain/services/location_sync_service.dart';
import 'package:geolocator_app/domain/services/location_tracking_service.dart';

class TrackingController extends GetxController {
  static const Duration _locationsReloadDelay = Duration(seconds: 1);

  final LocationRepository _repository;
  final LocationTrackingService _trackingService;
  final LocationSyncService _syncService;
  final Battery _battery;

  final isTracking = false.obs;
  final isStarting = false.obs;
  final isSyncing = false.obs;
  final isLoading = false.obs;
  final needsSettings = false.obs;

  final locations = <LocationModel>[].obs;
  final latestLocation = Rxn<LocationModel>();
  final totalCount = 0.obs;
  final pendingCount = 0.obs;

  final batteryLevel = RxnInt();
  final batteryState = 'unknown'.obs;
  final batteryAvailable = false.obs;

  final statusMessage = 'Ready'.obs;
  final errorMessage = ''.obs;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  Timer? _syncTimer;
  Timer? _batteryTimer;
  Timer? _locationsReloadTimer;

  String? _lastSavedPositionKey;

  TrackingController(
    this._repository,
    this._trackingService,
    this._syncService,
  ) : _battery = Battery();

  @override
  void onInit() {
    super.onInit();
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    await loadLocations();
    await refreshBattery();

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen(
      (_) => unawaited(refreshBattery()),
    );

    _batteryTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => unawaited(refreshBattery()),
    );

    _syncTimer = Timer.periodic(
      LocationSyncService.defaultSyncInterval,
      (_) => unawaited(syncLocations(silent: true)),
    );
  }

  Future<void> loadLocations() async {
    isLoading.value = true;
    try {
      final loaded = await _repository.getAllLocations();
      locations.assignAll(loaded);
      totalCount.value = loaded.length;
      pendingCount.value = loaded.where((item) => !item.isSynced).length;
      latestLocation.value = loaded.isEmpty ? null : loaded.last;
    } catch (error) {
      errorMessage.value = 'Failed to load location history: $error';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startTracking() async {
    if (isTracking.value || isStarting.value) {
      return;
    }

    isStarting.value = true;
    errorMessage.value = '';
    needsSettings.value = false;

    try {
      final access = await _trackingService.ensureLocationAccess();

      switch (access) {
        case LocationAccessStatus.serviceDisabled:
          errorMessage.value =
              'Location services are disabled. Enable GPS to start tracking.';
          statusMessage.value = 'Waiting for location services';
          return;
        case LocationAccessStatus.denied:
          errorMessage.value =
              'Location permission is required to start tracking.';
          statusMessage.value = 'Permission denied';
          return;
        case LocationAccessStatus.deniedForever:
          errorMessage.value =
              'Location permission is permanently denied. '
              'Grant it from application settings.';
          statusMessage.value = 'Permission permanently denied';
          needsSettings.value = true;
          return;
        case LocationAccessStatus.grantedWhileInUse:
        case LocationAccessStatus.grantedAlways:
          break;
      }

      try {
        final currentPosition = await _trackingService.getCurrentPosition();
        await _savePosition(currentPosition);
      } catch (_) {
        // The stream can still provide a position even when a single fix
        // times out, so tracking is allowed to continue.
      }

      _positionSubscription = _trackingService.getPositionStream().listen(
        (position) => unawaited(_savePosition(position)),
        onError: (Object error) {
          errorMessage.value = 'Location stream error: $error';
          statusMessage.value = 'Location updates interrupted';
        },
        onDone: () {
          isTracking.value = false;
          statusMessage.value = 'Location stream stopped';
        },
      );

      isTracking.value = true;
      statusMessage.value = access == LocationAccessStatus.grantedAlways
          ? 'Tracking active with background location permission'
          : 'Tracking active in foreground. '
              'Background updates require "Allow all the time" permission.';
    } catch (error) {
      errorMessage.value = 'Failed to start tracking: $error';
      statusMessage.value = 'Tracking failed to start';
    } finally {
      isStarting.value = false;
    }
  }

  Future<void> stopTracking() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    isTracking.value = false;
    statusMessage.value = 'Tracking stopped';
  }

  Future<void> _savePosition(Position position) async {
    final positionKey = '${position.latitude}|${position.longitude}|'
        '${position.timestamp.millisecondsSinceEpoch}';

    if (_lastSavedPositionKey == positionKey) {
      return;
    }
    _lastSavedPositionKey = positionKey;

    final model = LocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
      createdAt: DateTime.now(),
    );

    try {
      await _repository.saveLocation(model);
      latestLocation.value = model;
      _scheduleLocationsReload();
    } catch (error) {
      errorMessage.value = 'Failed to save location: $error';
    }
  }

  /// Avoids a database read for every incoming GPS update.
  void _scheduleLocationsReload() {
    _locationsReloadTimer?.cancel();
    _locationsReloadTimer = Timer(
      _locationsReloadDelay,
      () => unawaited(loadLocations()),
    );
  }

  Future<void> syncLocations({bool silent = false}) async {
    if (isSyncing.value) {
      return;
    }

    isSyncing.value = true;
    if (!silent) {
      errorMessage.value = '';
      statusMessage.value = 'Synchronizing pending locations...';
    }

    try {
      final result = await _syncService.syncPendingLocations();

      if (result.skipped) {
        return;
      }

      await loadLocations();

      if (!result.isSuccess) {
        if (!silent) {
          errorMessage.value =
              'Synchronization failed. Pending records were preserved.';
        }
        statusMessage.value = 'Sync failed';
        return;
      }

      if (result.uploadedCount == 0) {
        statusMessage.value = 'No pending locations to synchronize';
      } else {
        statusMessage.value =
            'Synchronized ${result.uploadedCount} location(s) '
            'in ${result.batchCount} batch(es)';
      }
    } catch (error) {
      if (!silent) {
        errorMessage.value = 'Synchronization failed: $error';
      }
      statusMessage.value = 'Sync failed';
    } finally {
      isSyncing.value = false;
    }
  }

  Future<void> clearLocations() async {
    try {
      await _repository.clearLocations();
      locations.clear();
      latestLocation.value = null;
      totalCount.value = 0;
      pendingCount.value = 0;
      statusMessage.value = 'Location history cleared';
      errorMessage.value = '';
    } catch (error) {
      errorMessage.value = 'Failed to clear location history: $error';
    }
  }

  Future<void> refreshBattery() async {
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;

      batteryLevel.value = level;
      batteryState.value = state.name;
      batteryAvailable.value = true;
    } catch (_) {
      batteryAvailable.value = false;
    }
  }

  Future<void> openAppSettings() async {
    await _trackingService.openAppSettings();
  }

  Future<void> openLocationSettings() async {
    await _trackingService.openLocationSettings();
  }

  @override
  void onClose() {
    _locationsReloadTimer?.cancel();
    _syncTimer?.cancel();
    _batteryTimer?.cancel();
    unawaited(_positionSubscription?.cancel());
    unawaited(_batteryStateSubscription?.cancel());
    super.onClose();
  }
}
