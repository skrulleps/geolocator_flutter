import 'package:floor/floor.dart';

@Entity(
  tableName: 'location_records',
  indices: [
    Index(value: ['sync_status']),
    Index(value: ['timestamp']),
  ],
)
class LocationEntity {
  @PrimaryKey(autoGenerate: true)
  @ColumnInfo(name: 'id')
  final int? id;

  @ColumnInfo(name: 'latitude')
  final double latitude;

  @ColumnInfo(name: 'longitude')
  final double longitude;

  @ColumnInfo(name: 'accuracy')
  final double accuracy;

  @ColumnInfo(name: 'altitude')
  final double altitude;

  @ColumnInfo(name: 'speed')
  final double speed;

  @ColumnInfo(name: 'heading')
  final double heading;

  @ColumnInfo(name: 'timestamp')
  final int timestamp;

  @ColumnInfo(name: 'created_at')
  final int createdAt;

  @ColumnInfo(name: 'sync_status')
  final String syncStatus;

  @ColumnInfo(name: 'synced_at')
  final int? syncedAt;

  LocationEntity({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.altitude,
    required this.speed,
    required this.heading,
    required this.timestamp,
    required this.createdAt,
    this.syncStatus = 'pending',
    this.syncedAt,
  });
}
