import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/launch_providers.dart';
import '../widgets/launch_card.dart';
import 'detail_screen.dart';

class ListScreen extends ConsumerWidget {
  const ListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(filteredLaunchesProvider);
    final location = ref.watch(locationProvider);
    final radius = ref.watch(radiusKmProvider);
    final sortByDist = ref.watch(sortByDistanceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Launches', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(
              sortByDist ? Icons.near_me : Icons.schedule,
              color: sortByDist ? const Color(0xFFFF6B35) : null,
            ),
            tooltip: sortByDist ? 'Sort by date' : 'Sort by distance',
            onPressed: () =>
                ref.read(sortByDistanceProvider.notifier).state = !sortByDist,
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter by radius',
            onPressed: () => _showFilterSheet(context, ref),
          ),
        ],
      ),
      body: filtered.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _errorState(context, ref, e),
        data: (launches) {
          if (launches.isEmpty) {
            return _emptyState(context, location.valueOrNull, radius);
          }
          final pos = location.valueOrNull;
          return RefreshIndicator(
            onRefresh: () async {
              ref.read(launchApiProvider).clearCache();
              ref.invalidate(launchesProvider);
              await ref.read(launchesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: launches.length,
              itemBuilder: (context, i) {
                final launch = launches[i];
                final dist = pos != null
                    ? launch.distanceKmFrom(pos.latitude, pos.longitude)
                    : null;
                return LaunchCard(
                  launch: launch,
                  distanceKm: dist,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DetailScreen(launch: launch)),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Could not load launches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: () {
                ref.read(launchApiProvider).clearCache();
                ref.invalidate(launchesProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState(BuildContext context, dynamic position, double radius) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 56, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No launches found',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              position == null
                  ? 'Enable location access to see launches near you'
                  : 'No launches within ${radius.toInt()} km — try a larger radius',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF141824),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = ref.watch(radiusKmProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search Radius',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${radius.toInt()} km from your location',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            Slider(
              value: radius,
              min: 100,
              max: 10000,
              divisions: 99,
              activeColor: const Color(0xFFFF6B35),
              label: '${radius.toInt()} km',
              onChanged: (v) => ref.read(radiusKmProvider.notifier).state = v,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [500, 1000, 2500, 5000, 10000]
                  .map(
                    (km) => TextButton(
                      onPressed: () =>
                          ref.read(radiusKmProvider.notifier).state = km.toDouble(),
                      style: TextButton.styleFrom(
                        foregroundColor: radius.toInt() == km
                            ? const Color(0xFFFF6B35)
                            : Colors.grey,
                      ),
                      child: Text('${km >= 1000 ? '${km ~/ 1000}k' : km} km'),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
