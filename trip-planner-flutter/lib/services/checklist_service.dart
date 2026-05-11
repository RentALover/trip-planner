import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/checklist.dart';

final checklistServiceProvider = Provider<ChecklistService>((ref) {
  return ChecklistService(client: ref.read(dioClientProvider));
});

class ChecklistService {
  final DioClient client;
  ChecklistService({required this.client});

  Future<List<ChecklistItem>> list(int tripId, {String? category}) async {
    final params = <String, dynamic>{};
    if (category != null) params['category'] = category;
    final data = await client.get('/trips/$tripId/checklist', params: params);
    return (data as List<dynamic>).map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ChecklistItem> create(int tripId, ChecklistItemReq req) async {
    final data = await client.post('/trips/$tripId/checklist', data: req.toJson());
    return ChecklistItem.fromJson(data as Map<String, dynamic>);
  }

  Future<ChecklistItem> update(int tripId, int id, ChecklistItemReq req) async {
    final data = await client.put('/trips/$tripId/checklist/$id', data: req.toJson());
    return ChecklistItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int tripId, int id) async {
    await client.delete('/trips/$tripId/checklist/$id');
  }

  Future<ChecklistItem> toggle(int tripId, int id) async {
    final data = await client.patch('/trips/$tripId/checklist/$id/toggle');
    return ChecklistItem.fromJson(data as Map<String, dynamic>);
  }

  Future<List<ChecklistItem>> toggleAll(int tripId, bool isChecked) async {
    final data = await client.patch('/trips/$tripId/checklist/toggle-all', data: {'isChecked': isChecked});
    return (data as List<dynamic>).map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ChecklistItem>> loadPreset(int tripId) async {
    final data = await client.post('/trips/$tripId/checklist/preset');
    return (data as List<dynamic>).map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
