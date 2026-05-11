import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/day.dart';

final dayServiceProvider = Provider<DayService>((ref) {
  return DayService(client: ref.read(dioClientProvider));
});

class DayService {
  final DioClient client;
  DayService({required this.client});

  Future<List<Day>> list(int tripId) async {
    final data = await client.get('/trips/$tripId/days');
    return (data as List<dynamic>).map((e) => Day.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Day>> generate(int tripId) async {
    final data = await client.post('/trips/$tripId/days/generate');
    return (data as List<dynamic>).map((e) => Day.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<DayDetail> getDetail(int tripId, int dayId) async {
    final data = await client.get('/trips/$tripId/days/$dayId');
    return DayDetail.fromJson(data as Map<String, dynamic>);
  }

  Future<Day> create(int tripId, DayCreateReq req) async {
    final data = await client.post('/trips/$tripId/days', data: req.toJson());
    return Day.fromJson(data as Map<String, dynamic>);
  }

  Future<Day> update(int tripId, int dayId, DayCreateReq req) async {
    final data = await client.put('/trips/$tripId/days/$dayId', data: req.toJson());
    return Day.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int tripId, int dayId) async {
    await client.delete('/trips/$tripId/days/$dayId');
  }
}
