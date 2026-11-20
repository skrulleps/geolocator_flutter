import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import 'package:geolocator_app/domain/models/location_model.dart';
import 'package:geolocator_app/flavors.dart';
import 'package:geolocator_app/presentation/controllers/tracking_controller.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  static const LatLng _defaultCenter = LatLng(-6.200000, 106.816666);

  final MapController _mapController = MapController();
  LatLng? _lastCenteredPoint;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrackingController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(F.title),
        actions: [
          IconButton(
            tooltip: 'Reload location history',
            onPressed: controller.loadLocations,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        final locations = controller.locations.toList()
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        final mapPoints = locations
            .map(
              (location) => LatLng(
                location.latitude,
                location.longitude,
              ),
            )
            .toList(growable: false);

        final initialCenter =
            mapPoints.isNotEmpty ? mapPoints.last : _defaultCenter;

        _followLatestPoint(initialCenter, mapPoints.isNotEmpty);

        return Column(
          children: [
            Expanded(
              flex: 3,
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.geolocator_app',
                  ),
                  if (mapPoints.isNotEmpty)
                    CircleLayer(
                      circles: [
                        for (final point in mapPoints)
                          CircleMarker(
                            point: point,
                            radius: 3,
                            color: Colors.blue.withValues(alpha: 0.6),
                          ),
                      ],
                    ),
                  if (mapPoints.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: mapPoints,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  if (mapPoints.isNotEmpty)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: mapPoints.last,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStatusCard(controller),
                    const SizedBox(height: 12),
                    _buildMeasurements(controller),
                    const SizedBox(height: 12),
                    _buildActionButtons(context, controller),
                    const SizedBox(height: 12),
                    if (controller.errorMessage.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          controller.errorMessage.value,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    Text(
                      controller.statusMessage.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text(
                          'Recent Locations',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (controller.isLoading.value)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (locations.isEmpty)
                      const Text('No location data yet')
                    else
                      ...locations.reversed.take(5).map(
                            (location) => _buildLocationItem(location),
                          ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  void _followLatestPoint(LatLng latestPoint, bool hasLocations) {
    if (!hasLocations || _lastCenteredPoint == latestPoint) {
      return;
    }

    _lastCenteredPoint = latestPoint;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      try {
        _mapController.move(latestPoint, _mapController.camera.zoom);
      } catch (_) {
        // The map is not attached yet; the next update will recenter it.
      }
    });
  }

  Widget _buildStatusCard(TrackingController controller) {
    final isTracking = controller.isTracking.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 12,
              color: isTracking ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              isTracking ? 'Tracking Active' : 'Tracking Inactive',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            if (controller.isStarting.value)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            if (controller.isSyncing.value)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurements(TrackingController controller) {
    final latest = controller.latestLocation.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatisticCard(
                'Total Locations',
                controller.totalCount.value.toString(),
                Icons.location_on,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatisticCard(
                'Pending Sync',
                controller.pendingCount.value.toString(),
                Icons.cloud_upload,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildBatteryCard(controller),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            dense: true,
            leading: const Icon(Icons.my_location),
            title: Text(
              latest == null
                  ? 'No coordinate recorded yet'
                  : '${latest.latitude.toStringAsFixed(6)}, '
                      '${latest.longitude.toStringAsFixed(6)}',
            ),
            subtitle: Text(
              latest == null
                  ? 'Start tracking to collect the first location'
                  : 'Accuracy: ${latest.accuracy.toStringAsFixed(1)} m | '
                      '${latest.timestamp.toLocal()}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBatteryCard(TrackingController controller) {
    final level = controller.batteryLevel.value;
    final state = controller.batteryState.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              _batteryIcon(level),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              level == null ? '--' : '$level%',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              _formatBatteryState(state),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _batteryIcon(int? level) {
    if (level == null) {
      return Icons.battery_unknown;
    }
    if (level >= 90) {
      return Icons.battery_full;
    }
    if (level >= 60) {
      return Icons.battery_5_bar;
    }
    if (level >= 30) {
      return Icons.battery_3_bar;
    }
    return Icons.battery_1_bar;
  }

  String _formatBatteryState(String state) {
    switch (state) {
      case 'charging':
        return 'Charging';
      case 'full':
        return 'Full';
      case 'discharging':
        return 'Discharging';
      case 'connectedNotCharging':
        return 'Connected';
      default:
        return 'Battery unknown';
    }
  }

  Widget _buildStatisticCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    TrackingController controller,
  ) {
    final isBusy =
        controller.isStarting.value || controller.isTracking.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.isStarting.value
                    ? null
                    : controller.isTracking.value
                        ? controller.stopTracking
                        : controller.startTracking,
                icon: Icon(
                  controller.isTracking.value ? Icons.stop : Icons.play_arrow,
                ),
                label: Text(
                  controller.isTracking.value
                      ? 'Stop Tracking'
                      : 'Start Tracking',
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.isSyncing.value
                    ? null
                    : controller.syncLocations,
                icon: const Icon(Icons.sync),
                label: const Text('Sync Now'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: isBusy
              ? null
              : () => _confirmClearHistory(context, controller),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear Location History'),
        ),
        if (controller.needsSettings.value) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: controller.openAppSettings,
            icon: const Icon(Icons.settings),
            label: const Text('Open App Settings'),
          ),
        ],
      ],
    );
  }

  Future<void> _confirmClearHistory(
    BuildContext context,
    TrackingController controller,
  ) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear location history?'),
        content: const Text(
          'All locally stored locations will be removed. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true) {
      await controller.clearLocations();
    }
  }

  Widget _buildLocationItem(LocationModel location) {
    final date = location.timestamp.toLocal();

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.place),
      title: Text(
        '${location.latitude.toStringAsFixed(6)}, '
        '${location.longitude.toStringAsFixed(6)}',
      ),
      subtitle: Text(
        'Accuracy: ${location.accuracy.toStringAsFixed(1)} m | $date',
      ),
      trailing: Icon(
        location.isSynced ? Icons.cloud_done : Icons.cloud_upload,
        color: location.isSynced ? Colors.green : Colors.orange,
      ),
    );
  }
}
