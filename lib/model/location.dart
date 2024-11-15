class Location {
  final double lat;
  final double lng;

  Location({
    required this.lat,
    required this.lng,
  });

  factory Location.fromMap(Map<String, dynamic> data) {
    return Location(
      lat: data['lat'] as double,
      lng: data['lng'] as double,
    );
  }
}
