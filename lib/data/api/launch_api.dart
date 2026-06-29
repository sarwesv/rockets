import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/launch.dart';

class LaunchApi {
  static const _baseUrl = 'https://ll.thespacedevs.com/2.3.0';
  static const _timeout = Duration(seconds: 20);
  static const _cacheDuration = Duration(minutes: 10);

  List<Launch>? _cache;
  DateTime? _cacheTime;

  Future<List<Launch>> fetchUpcomingLaunches({int limit = 100}) async {
    if (_cache != null &&
        _cacheTime != null &&
        DateTime.now().difference(_cacheTime!) < _cacheDuration) {
      return _cache!;
    }

    final uri = Uri.parse('$_baseUrl/launch/upcoming/').replace(
      queryParameters: {
        'limit': limit.toString(),
        'format': 'json',
        'ordering': 'window_start',
      },
    );

    final response = await http.get(
      uri,
      headers: {'User-Agent': 'RocketTracker/1.0'},
    ).timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('API error ${response.statusCode}: ${response.reasonPhrase}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>? ?? [])
        .map((e) => Launch.fromJson(e as Map<String, dynamic>))
        .toList();

    _cache = results;
    _cacheTime = DateTime.now();
    return results;
  }

  void clearCache() {
    _cache = null;
    _cacheTime = null;
  }
}
