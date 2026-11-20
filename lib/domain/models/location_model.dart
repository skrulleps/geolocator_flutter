/// Synchronization state of a locally stored location record.
enum SyncStatus {
  pending,
  synced;

  static SyncStatus fromValue(String value) {
    return value == SyncStatus.synced.name
        ? SyncStatus.synced
        : SyncStatus.pending;
  }

  String get value => name;
}

/// Application-level representation of a collected location.
///
/// This model must stay independent of Floor and SQLite.
class LocationModel {
  final int? id;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double altitude;
  final double speed;
  final double heading;
  final DateTime timestamp;
  final DateTime createdAt;
  final SyncStatus syncStatus;
  final DateTime? syncedAt;

  const LocationModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.createdAt,
    this.syncStatus = SyncStatus.pending,
    this.syncedAt,
  });

  bool get isSynced => syncStatus == SyncStatus.synced;

  LocationModel copyWith({
    int? id,
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    DateTime? createdAt,
    SyncStatus? syncStatus,
    DateTime? syncedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }
}
