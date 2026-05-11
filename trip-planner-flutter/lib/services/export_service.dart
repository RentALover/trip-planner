import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService(client: ref.read(dioClientProvider));
});

class ExportService {
  final DioClient client;
  ExportService({required this.client});

  Future<String> exportText(int tripId) async {
    final data = await client.get('/trips/$tripId/export/text');
    return data as String;
  }
}
