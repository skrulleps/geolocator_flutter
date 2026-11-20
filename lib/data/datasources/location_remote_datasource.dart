import 'package:geolocator_app/domain/datasources/location_remote_datasource.dart';
import 'package:geolocator_app/domain/models/location_model.dart';

/// In-memory stand-in for a production backend.
///
/// It intentionally performs no network request. Failures can be triggered
/// explicitly to evaluate offline-first and retry behavior.
class SimulatedLocationRemoteDataSource implements LocationRemoteDataSource {
  final Duration uploadDelay;

  bool simulateFailure;

  SimulatedLocationRemoteDataSource({
    this.uploadDelay = const Duration(milliseconds: 300),
    this.simulateFailure = false,
  });

  @override
  Future<void> uploadLocations(List<LocationModel> locations) async {
    if (locations.isEmpty) {
      return;
    }

    if (uploadDelay > Duration.zero) {
      await Future<void>.delayed(uploadDelay);
    }

    if (simulateFailure) {
      throw const LocationUploadException(
        'Simulated backend upload failure',
      );
    }
  }
}
