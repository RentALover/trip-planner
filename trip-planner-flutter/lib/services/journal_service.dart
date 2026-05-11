import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/journal.dart';

final journalServiceProvider = Provider<JournalService>((ref) {
  return JournalService(client: ref.read(dioClientProvider));
});

class JournalService {
  final DioClient client;
  JournalService({required this.client});

  Future<Journal?> get(int dayId) async {
    try {
      final data = await client.get('/days/$dayId/journal');
      if (data == null) return null;
      return Journal.fromJson(data as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<Journal> save(int dayId, JournalReq req) async {
    final data = await client.put('/days/$dayId/journal', data: req.toJson());
    return Journal.fromJson(data as Map<String, dynamic>);
  }

  Future<void> delete(int dayId) async {
    await client.delete('/days/$dayId/journal');
  }
}
