class OsmPlace {
  final int id;
  final String type;
  final double lat;
  final double lon;
  final Map<String, dynamic> tags;

  OsmPlace({
    required this.id,
    required this.type,
    required this.lat,
    required this.lon,
    required this.tags,
  });

  factory OsmPlace.fromJson(Map<String, dynamic> json) {
    double latitude = json['lat'] ?? json['center']?['lat'] ?? 0.0;
    double longitude = json['lon'] ?? json['center']?['lon'] ?? 0.0;

    return OsmPlace(
      id: json['id'],
      type: json['type'],
      lat: latitude,
      lon: longitude,
      tags: json['tags'] ?? {},
    );
  }

  String get name => tags['name'] ?? 'Sin nombre';
  String? get amenity => tags['amenity'];
  String? get shop => tags['shop'];
  String? get tourism => tags['tourism'];
}
