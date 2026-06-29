import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../data/models/launch.dart';
import '../widgets/status_badge.dart';
import '../widgets/countdown_widget.dart';

class DetailScreen extends StatelessWidget {
  final Launch launch;

  const DetailScreen({super.key, required this.launch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 20),
                  CountdownWidget(windowStart: launch.windowStart),
                  const SizedBox(height: 24),
                  _sectionLabel('Launch Details'),
                  const SizedBox(height: 10),
                  _buildInfoGrid(context),
                  if (launch.description.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _sectionLabel('Mission Description'),
                    const SizedBox(height: 10),
                    Text(
                      launch.description,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                        height: 1.65,
                      ),
                    ),
                  ],
                  const SizedBox(height: 32),
                  if (launch.hasLocation) _buildDirectionsButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final hasImage = launch.imageUrl != null && launch.imageUrl!.isNotEmpty;
    return SliverAppBar(
      expandedHeight: hasImage ? 220 : 0,
      pinned: true,
      backgroundColor: const Color(0xFF0A0E1A),
      flexibleSpace: hasImage
          ? FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: launch.imageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withValues(alpha: 0.35),
                colorBlendMode: BlendMode.darken,
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                launch.rocketName,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ),
            const SizedBox(width: 12),
            StatusBadge(abbrev: launch.statusAbbrev, name: launch.statusName),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          launch.missionName,
          style: TextStyle(
            fontSize: 15,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
        if (launch.agencyName != null && launch.agencyName!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.business, size: 13, color: Colors.grey),
              const SizedBox(width: 5),
              Text(
                launch.agencyName!,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildInfoGrid(BuildContext context) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('HH:mm z');

    return Column(
      children: [
        _infoRow(Icons.calendar_today, 'Date', dateFormat.format(launch.windowStart)),
        _infoRow(Icons.access_time, 'Launch Window Opens', timeFormat.format(launch.windowStart)),
        if (launch.windowEnd != null)
          _infoRow(Icons.timer_off_outlined, 'Window Closes', timeFormat.format(launch.windowEnd!)),
        _infoRow(Icons.category_outlined, 'Mission Type', launch.missionType),
        _infoRow(Icons.launch, 'Launch Pad', launch.padName),
        _infoRow(Icons.location_on_outlined, 'Location', launch.locationName),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 11,
        letterSpacing: 1.5,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDirectionsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.directions, size: 22),
        label: const Text(
          'Get Directions in Google Maps',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFF6B35),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        onPressed: () => _openDirections(context),
      ),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final lat = launch.latitude!;
    final lng = launch.longitude!;

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng'
      '&travelmode=driving',
    );

    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }
}
