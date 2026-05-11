import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/geo_item.dart';

final geoServiceProvider = Provider<GeoService>((ref) {
  return GeoService(client: ref.read(dioClientProvider));
});

class GeoService {
  final DioClient client;
  GeoService({required this.client});

  Future<List<GeoItem>> geocode(int tripId) async {
    final data = await client.get('/trips/$tripId/geocode');
    return (data as List<dynamic>).map((e) => GeoItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
