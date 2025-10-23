import 'dart:convert';
import 'package:http/http.dart' as http;

class OverpassService {
  static const String baseUrl = 'https://overpass-api.de/api/interpreter';

  Future<Map<String, dynamic>?> fetchData(String query) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'data': query},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error al conectar con Overpass API: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> searchNearby({
    required double lat,
    required double lon,
    required int radius,
    required String tagKey,
    required String tagValue,
  }) async {
    final query =
        '''
[out:json];
(
  node["$tagKey"="$tagValue"](around:$radius,$lat,$lon);
  way["$tagKey"="$tagValue"](around:$radius,$lat,$lon);
  relation["$tagKey"="$tagValue"](around:$radius,$lat,$lon);
);
out center;
    ''';

    final result = await fetchData(query);

    if (result != null && result['elements'] != null) {
      return List<Map<String, dynamic>>.from(result['elements']);
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> searchInBounds({
    required double minLat,
    required double minLon,
    required double maxLat,
    required double maxLon,
    required String tagKey,
    required String tagValue,
  }) async {
    final query =
        '''
[out:json];
(
  node["$tagKey"="$tagValue"]($minLat,$minLon,$maxLat,$maxLon);
  way["$tagKey"="$tagValue"]($minLat,$minLon,$maxLat,$maxLon);
  relation["$tagKey"="$tagValue"]($minLat,$minLon,$maxLat,$maxLon);
);
out center;
    ''';

    final result = await fetchData(query);

    if (result != null && result['elements'] != null) {
      return List<Map<String, dynamic>>.from(result['elements']);
    }

    return [];
  }

  Future<List<Map<String, dynamic>>> searchMultipleTypes({
    required double lat,
    required double lon,
    required int radius,
    required Map<String, List<String>> tags,
  }) async {
    String queries = '';

    tags.forEach((key, values) {
      for (var value in values) {
        queries += 'node["$key"="$value"](around:$radius,$lat,$lon);';
        queries += 'way["$key"="$value"](around:$radius,$lat,$lon);';
      }
    });

    final query = '[out:json];($queries);out center;';

    final result = await fetchData(query);

    if (result != null && result['elements'] != null) {
      return List<Map<String, dynamic>>.from(result['elements']);
    }

    return [];
  }
}
