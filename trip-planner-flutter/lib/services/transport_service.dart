import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/transport.dart';

final transportServiceProvider = Provider<TransportService>((ref) {
  return TransportService(client: ref.read(dioClientProvider));
});

class TransportService {
  final DioClient client;
  TransportService({required this.client});

  Future<List<Transport>> list(int dayId) async {
    final data = await client.get('/days/$dayId/transports');
    return (data as List<dynamic>).map((e) => Transport.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Transport> create(int dayId, TransportCreateReq req) async {
    final data = await client.post('/days/$dayId/transports', data: req.toJson());
    return Transport.fromJson(data as Map<String, dynamic>);
  }

  Future<Transport> update(int dayId, int id, TransportUpdateReq req) async {
    final data = await client.put('/days/$dayId/transports/$id', data: req.toJson());
    return Transport.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int dayId, int id) async {
    await client.delete('/days/$dayId/transports/$id');
  }

  Future<Transport?> getBetween(int dayId, int fromItemId, int toItemId) async {
    try {
      final data = await client.get('/days/$dayId/transports/between', params: {
        'fromItemId': fromItemId,
        'toItemId': toItemId,
      });
      if (data == null) return null;
      return Transport.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<TransportLookupResult?> lookup(String type, String number, String? date) async {
    try {
      final data = await client.get('/transport-lookup', params: {
        'type': type, 'number': number, if (date != null) 'date': date,
      });
      if (data == null) return null;
      return TransportLookupResult.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
