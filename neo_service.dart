import 'dart:convert';
import 'package:http/http.dart' as http;
import 'neo_asteroid.dart';

const String _apiKey = '8PiTtu5Gob9Udr86kCezGXrOVmnNH8jezACmGAIa';

Future<List<NeoAsteroid>> fetchClosestAsteroids({
  required String date,
}) async {
  final queryParams = <String, String>{
    'start_date': date,
    'end_date': date,
    'api_key': _apiKey ,
  };

  final uri = Uri.https('api.nasa.gov', '/neo/rest/v1/feed', queryParams);
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final neoMap =
        json['near_earth_objects'] as Map<String, dynamic>? ?? {};
    final asteroidList = neoMap[date] as List<dynamic>? ?? const [];

    final asteroids = asteroidList
        .map((item) => NeoAsteroid.fromJson(item as Map<String, dynamic>))
        .toList();

    asteroids.sort((a, b) => a.missDistanceKm.compareTo(b.missDistanceKm));
    return asteroids;
  } else if (response.statusCode == 403) {
    throw Exception('API key no válida o sin permisos en NeoWs (403 Forbidden).');
  } else if (response.statusCode == 429) {
    throw Exception('Has superado el límite de peticiones en NeoWs (429 Too Many Requests).');
  } else {
    throw Exception(
      'Error al consultar NeoWs. Código: ${response.statusCode}\n${response.body}',
    );
  }
}