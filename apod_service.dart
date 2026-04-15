import 'dart:convert';
import 'package:http/http.dart' as http;
import 'apod_data.dart';

// No subas esta clave a un repositorio público
const String _apiKey = '8PiTtu5Gob9Udr86kCezGXrOVmnNH8jezACmGAIa';

Future<ApodData> fetchApod({String? date}) async {
  final queryParams = <String, String>{
    'api_key': _apiKey,
    'thumbs': 'true',
    if (date != null) 'date': date,
  };

  final uri = Uri.https('api.nasa.gov', '/planetary/apod', queryParams);

  final response = await http.get(uri);

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return ApodData.fromJson(json);
  } else if (response.statusCode == 403) {
    throw Exception('API key no válida o sin permisos (403 Forbidden).');
  } else if (response.statusCode == 429) {
    throw Exception('Has superado el límite de peticiones (429 Too Many Requests).');
  } else {
    throw Exception(
      'Error al consultar la API. Código: ${response.statusCode}\n${response.body}',
    );
  }
}