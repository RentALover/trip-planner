import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/item.dart';

final itemServiceProvider = Provider<ItemService>((ref) {
  return ItemService(client: ref.read(dioClientProvider));
});

class ItemService {
  final DioClient client;
  ItemService({required this.client});

  Future<List<TripItem>> list(int dayId) async {
    final data = await client.get('/days/$dayId/items');
    return (data as List<dynamic>).map((e) => TripItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TripItem> create(int dayId, ItemCreateReq req) async {
    final data = await client.post('/days/$dayId/items', data: req.toJson());
    return TripItem.fromJson(data as Map<String, dynamic>);
  }

  Future<TripItem> update(int dayId, int itemId, ItemUpdateReq req) async {
    final data = await client.put('/days/$dayId/items/$itemId', data: req.toJson());
    return TripItem.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int dayId, int itemId) async {
    await client.delete('/days/$dayId/items/$itemId');
  }

  Future<Map<String, dynamic>> reorder(int dayId, ItemSortReq req) async {
    final data = await client.put('/days/$dayId/items/reorder', data: req.toJson());
    return data as Map<String, dynamic>;
  }

  Future<List<TripItem>> batchCreate(int dayId, List<ItemCreateReq> items) async {
    final data = await client.post('/days/$dayId/items/batch', data: items.map((e) => e.toJson()).toList());
    return (data as List<dynamic>).map((e) => TripItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TripItem> moveToDay(int dayId, int itemId, ItemMoveReq req) async {
    final data = await client.patch('/days/$dayId/items/$itemId/move', data: req.toJson());
    return TripItem.fromJson(data as Map<String, dynamic>);
  }

  Future<List<TripItem>> batchUpdateTimes(int dayId, ItemBatchTimeUpdateReq req) async {
    final data = await client.put('/days/$dayId/items/batch-times', data: req.toJson());
    return (data as List<dynamic>).map((e) => TripItem.fromJson(e as Map<String, dynamic>)).toList();
  }
}
