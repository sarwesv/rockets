import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/launch.dart';
import 'status_badge.dart';

class LaunchCard extends StatelessWidget {
  final Launch launch;
  final double? distanceKm;
  final VoidCallback onTap;

  const LaunchCard({
    super.key,
    required this.launch,
    this.distanceKm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy • HH:mm').format(launch.windowStart);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.rocket_launch, color: Color(0xFFFF6B35), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      launch.rocketName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(abbrev: launch.statusAbbrev, name: launch.statusName),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                launch.missionName,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xFF2A2F40), height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Text(
                    dateStr,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  if (distanceKm != null) ...[
                    const Spacer(),
                    const Icon(Icons.near_me, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      _formatDistance(distanceKm!),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 13, color: Colors.grey),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      launch.locationName,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDistance(double km) {
    if (km < 1) return '< 1 km';
    if (km < 1000) return '${km.toInt()} km';
    return '${(km / 1000).toStringAsFixed(1)}k km';
  }
}
