import 'dart:math' as math;

class Launch {
  final String id;
  final String name;
  final String rocketName;
  final String missionName;
  final String missionType;
  final String description;
  final DateTime windowStart;
  final DateTime? windowEnd;
  final String statusName;
  final String statusAbbrev;
  final double? latitude;
  final double? longitude;
  final String padName;
  final String locationName;
  final String? imageUrl;
  final String? agencyName;

  const Launch({
    required this.id,
    required this.name,
    required this.rocketName,
    required this.missionName,
    required this.missionType,
    required this.description,
    required this.windowStart,
    this.windowEnd,
    required this.statusName,
    required this.statusAbbrev,
    this.latitude,
    this.longitude,
    required this.padName,
    required this.locationName,
    this.imageUrl,
    this.agencyName,
  });

  factory Launch.fromJson(Map<String, dynamic> json) {
    final pad = (json['pad'] as Map<String, dynamic>?) ?? {};
    final location = (pad['location'] as Map<String, dynamic>?) ?? {};
    final rocket = (json['rocket'] as Map<String, dynamic>?) ?? {};
    final config = (rocket['configuration'] as Map<String, dynamic>?) ?? {};
    final mission = (json['mission'] as Map<String, dynamic>?) ?? {};
    final status = (json['status'] as Map<String, dynamic>?) ?? {};
    final agency = (json['launch_service_provider'] as Map<String, dynamic>?) ?? {};

    return Launch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Launch',
      rocketName: config['name']?.toString() ?? 'Unknown Rocket',
      missionName: mission['name']?.toString() ?? 'Unknown Mission',
      missionType: mission['type']?.toString() ?? 'Unknown',
      description: mission['description']?.toString() ?? '',
      windowStart: DateTime.parse(
        json['window_start']?.toString() ?? DateTime.now().toIso8601String(),
      ).toLocal(),
      windowEnd: json['window_end'] != null
          ? DateTime.tryParse(json['window_end'].toString())?.toLocal()
          : null,
      statusName: status['name']?.toString() ?? 'TBD',
      statusAbbrev: status['abbrev']?.toString() ?? 'TBD',
      latitude: double.tryParse(pad['latitude']?.toString() ?? ''),
      longitude: double.tryParse(pad['longitude']?.toString() ?? ''),
      padName: pad['name']?.toString() ?? 'Unknown Pad',
      locationName: location['name']?.toString() ?? 'Unknown Location',
      imageUrl: json['image']?.toString(),
      agencyName: agency['name']?.toString(),
    );
  }

  bool get hasLocation => latitude != null && longitude != null;
  Duration get timeUntilLaunch => windowStart.difference(DateTime.now());

  double? distanceKmFrom(double userLat, double userLng) {
    if (!hasLocation) return null;
    const r = 6371.0;
    final dLat = _rad(latitude! - userLat);
    final dLng = _rad(longitude! - userLng);
    final sinDLat = math.sin(dLat / 2);
    final sinDLng = math.sin(dLng / 2);
    final a = sinDLat * sinDLat +
        math.cos(_rad(userLat)) * math.cos(_rad(latitude!)) * sinDLng * sinDLng;
    return r * 2 * math.asin(math.sqrt(a));
  }

  static double _rad(double deg) => deg * math.pi / 180;
}
