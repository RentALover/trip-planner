import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/trip.dart';

final tripServiceProvider = Provider<TripService>((ref) {
  return TripService(client: ref.read(dioClientProvider));
});

class TripService {
  final DioClient client;
  TripService({required this.client});

  Future<PageResult<Trip>> list({int page = 1, int size = 10, String? status, String? keyword}) async {
    final params = <String, dynamic>{'page': page, 'size': size};
    if (status != null) params['status'] = status;
    if (keyword != null) params['keyword'] = keyword;
    final data = await client.get('/trips', params: params);
    return PageResult.fromJson(data as Map<String, dynamic>, Trip.fromJson);
  }

  Future<Trip> getById(int id) async {
    final data = await client.get('/trips/$id');
    return Trip.fromJson(data as Map<String, dynamic>);
  }

  Future<Trip> create(TripCreateReq req) async {
    final data = await client.post('/trips', data: req.toJson());
    return Trip.fromJson(data as Map<String, dynamic>);
  }

  Future<Trip> update(int id, TripUpdateReq req) async {
    final data = await client.put('/trips/$id', data: req.toJson());
    return Trip.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await client.delete('/trips/$id');
  }

  Future<Trip> copy(int id) async {
    final data = await client.post('/trips/$id/copy');
    return Trip.fromJson(data as Map<String, dynamic>);
  }

  Future<Trip> updateStatus(int id, String status) async {
    final data = await client.patch('/trips/$id/status', data: {'status': status});
    return Trip.fromJson(data as Map<String, dynamic>);
  }
}
