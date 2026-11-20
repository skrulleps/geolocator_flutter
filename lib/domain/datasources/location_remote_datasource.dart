import 'package:geolocator_app/domain/models/location_model.dart';

/// Contract used by the synchronization service to hand a batch of locations
/// to a backend. Implementations belong to the data layer.
abstract class LocationRemoteDataSource {
  Future<void> uploadLocations(List<LocationModel> locations);
}

class LocationUploadException implements Exception {
  final String message;

  const LocationUploadException(this.message);

  @override
  String toString() => 'LocationUploadException: $message';
}
