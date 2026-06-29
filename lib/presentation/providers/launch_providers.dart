import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/api/launch_api.dart';
import '../../data/models/launch.dart';

final launchApiProvider = Provider<LaunchApi>((_) => LaunchApi());

final locationProvider = FutureProvider<Position?>((ref) async {
  try {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
    );
  } catch (_) {
    return null;
  }
});

final launchesProvider = FutureProvider<List<Launch>>((ref) {
  return ref.watch(launchApiProvider).fetchUpcomingLaunches();
});

final radiusKmProvider = StateProvider<double>((_) => 1000.0);

final sortByDistanceProvider = StateProvider<bool>((_) => false);

final filteredLaunchesProvider = Provider<AsyncValue<List<Launch>>>((ref) {
  final launchesAsync = ref.watch(launchesProvider);
  final locationAsync = ref.watch(locationProvider);
  final radiusKm = ref.watch(radiusKmProvider);
  final sortByDistance = ref.watch(sortByDistanceProvider);

  return launchesAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (e, s) => AsyncValue.error(e, s),
    data: (launches) {
      final position = locationAsync.valueOrNull;

      List<Launch> filtered;
      if (position != null) {
        filtered = launches.where((l) {
          if (!l.hasLocation) return false;
          final dist = l.distanceKmFrom(position.latitude, position.longitude);
          return dist != null && dist <= radiusKm;
        }).toList();
      } else {
        filtered = List.of(launches);
      }

      if (sortByDistance && position != null) {
        filtered.sort((a, b) {
          final da = a.distanceKmFrom(position.latitude, position.longitude) ?? double.maxFinite;
          final db = b.distanceKmFrom(position.latitude, position.longitude) ?? double.maxFinite;
          return da.compareTo(db);
        });
      } else {
        filtered.sort((a, b) => a.windowStart.compareTo(b.windowStart));
      }

      return AsyncValue.data(filtered);
    },
  );
});
