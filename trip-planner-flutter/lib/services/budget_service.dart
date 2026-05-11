import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/network/dio_client.dart';
import '../models/budget.dart';

final budgetServiceProvider = Provider<BudgetService>((ref) {
  return BudgetService(client: ref.read(dioClientProvider));
});

final budgetSummaryProvider = FutureProvider.family<BudgetSummary, int>((ref, tripId) {
  return ref.read(budgetServiceProvider).getSummary(tripId);
});

final budgetByDayProvider = FutureProvider.family<List<BudgetByDay>, int>((ref, tripId) {
  return ref.read(budgetServiceProvider).getByDay(tripId);
});

final budgetByCategoryProvider = FutureProvider.family<List<BudgetByCategory>, int>((ref, tripId) {
  return ref.read(budgetServiceProvider).getByCategory(tripId);
});

class BudgetService {
  final DioClient client;
  BudgetService({required this.client});

  Future<BudgetSummary> getSummary(int tripId) async {
    final data = await client.get('/trips/$tripId/budget');
    return BudgetSummary.fromJson(data as Map<String, dynamic>);
  }

  Future<List<BudgetByDay>> getByDay(int tripId) async {
    final data = await client.get('/trips/$tripId/budget/by-day');
    return (data as List<dynamic>).map((e) => BudgetByDay.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<BudgetByCategory>> getByCategory(int tripId) async {
    final data = await client.get('/trips/$tripId/budget/by-category');
    return (data as List<dynamic>).map((e) => BudgetByCategory.fromJson(e as Map<String, dynamic>)).toList();
  }
}
