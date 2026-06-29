import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';
import '../../data/models/launch.dart';
import '../providers/launch_providers.dart';
import '../widgets/status_badge.dart';
import 'detail_screen.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  static const _defaultCenter = LatLng(28.5, -80.6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final launches = ref.watch(launchesProvider);
    final location = ref.watch(locationProvider);
    final userPos = location.valueOrNull;

    final center = userPos != null
        ? LatLng(userPos.latitude, userPos.longitude)
        : _defaultCenter;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rocket Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          _refreshButton(context, ref, launches),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: userPos != null ? 4.5 : 2.5,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.rockettracker.app',
          ),
          if (userPos != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(userPos.latitude, userPos.longitude),
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                  ),
                ),
              ],
            ),
          launches.when(
            loading: () => const MarkerLayer(markers: []),
            error: (_, __) => const MarkerLayer(markers: []),
            data: (all) => MarkerLayer(
              markers: all
                  .where((l) => l.hasLocation)
                  .map((l) => _launchMarker(context, l))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _refreshButton(BuildContext context, WidgetRef ref, AsyncValue launches) {
    if (launches.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }
    return IconButton(
      icon: const Icon(Icons.refresh),
      tooltip: 'Refresh launches',
      onPressed: () {
        ref.read(launchApiProvider).clearCache();
        ref.invalidate(launchesProvider);
      },
    );
  }

  Marker _launchMarker(BuildContext context, Launch launch) {
    final color = StatusBadge.colorForStatus(launch.statusAbbrev);
    return Marker(
      point: LatLng(launch.latitude!, launch.longitude!),
      width: 44,
      height: 44,
      child: GestureDetector(
        onTap: () => _showPreview(context, launch),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(Icons.rocket_launch, color: color, size: 18),
        ),
      ),
    );
  }

  void _showPreview(BuildContext context, Launch launch) {
    final dateStr = DateFormat('MMM d • HH:mm').format(launch.windowStart);

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.rocket_launch, color: Color(0xFFFF6B35), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      launch.rocketName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  StatusBadge(abbrev: launch.statusAbbrev, name: launch.statusName),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      launch.missionName,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(dateStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            launch.locationName,
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => DetailScreen(launch: launch)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Details & Directions'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
