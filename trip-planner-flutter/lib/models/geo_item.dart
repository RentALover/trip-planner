class GeoItem {
  final int itemId;
  final String title;
  final String itemType;
  final String location;
  final double lat;
  final double lng;
  final int dayNumber;

  GeoItem({
    required this.itemId, required this.title, required this.itemType,
    required this.location, required this.lat, required this.lng,
    required this.dayNumber,
  });

  factory GeoItem.fromJson(Map<String, dynamic> json) => GeoItem(
    itemId: json['itemId'] as int,
    title: json['title'] as String,
    itemType: (json['itemType'] as String?) ?? 'OTHER',
    location: json['location'] as String,
    lat: (json['lat'] as num).toDouble(),
    lng: (json['lng'] as num).toDouble(),
    dayNumber: json['dayNumber'] as int,
  );
}
