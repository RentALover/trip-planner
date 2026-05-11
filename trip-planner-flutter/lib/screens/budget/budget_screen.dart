import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../services/budget_service.dart';

class BudgetScreen extends ConsumerWidget {
  final int tripId;
  const BudgetScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(budgetSummaryProvider(tripId));
    final byCategoryAsync = ref.watch(budgetByCategoryProvider(tripId));
    final byDayAsync = ref.watch(budgetByDayProvider(tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('预算')),
      body: summaryAsync.when(
        loading: () => const LoadingWidget(message: '加载预算...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(budgetSummaryProvider(tripId))),
        data: (summary) {
          if (summary.totalBudget == null || summary.totalBudget == 0) {
            return const EmptyStateWidget(icon: Icons.account_balance_wallet_outlined, title: '暂无预算数据', subtitle: '编辑行程设置预算后可查看');
          }
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Summary cards
              Row(
                children: [
                  _StatCard(label: '总预算', value: '¥${(summary.totalBudget ?? 0).toStringAsFixed(0)}', color: AppColors.primary),
                  const SizedBox(width: 12),
                  _StatCard(label: '已花费', value: '¥${(summary.spentTotal ?? 0).toStringAsFixed(0)}', color: AppColors.warning),
                  const SizedBox(width: 12),
                  _StatCard(label: '剩余', value: '¥${(summary.remainingBudget ?? 0).toStringAsFixed(0)}', color: AppColors.success),
                ],
              ),
              const SizedBox(height: 24),

              // Category breakdown
              const Text('分类统计', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              byCategoryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) {
                  if (categories.isEmpty) return const Text('暂无消费分类数据', style: TextStyle(color: AppColors.textSecondary));
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Column(
                      children: categories.map((c) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(c.category, style: const TextStyle(fontSize: 13, color: AppColors.textRegular)),
                            ),
                            Text('¥${(c.totalCost ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 8),
                            Text('${(c.percentage ?? 0).toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      )).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Pie chart
              byCategoryAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) {
                  if (categories.isEmpty) return const SizedBox.shrink();
                  return SizedBox(
                    height: 200,
                    child: PieChart(PieChartData(
                      sections: categories.map((c) {
                        final color = _categoryColor(c.category);
                        return PieChartSectionData(
                          value: c.totalCost ?? 0,
                          title: '${(c.percentage ?? 0).toStringAsFixed(0)}%',
                          color: color,
                          radius: 50,
                          titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w500),
                        );
                      }).toList(),
                      centerSpaceRadius: 30,
                    )),
                  );
                },
              ),
              const SizedBox(height: 24),

              // By day breakdown
              const Text('每日明细', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              byDayAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (days) {
                  if (days.isEmpty) return const SizedBox.shrink();
                  return Container(
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.borderLight)),
                    child: Column(
                      children: days.map((d) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(children: [
                          SizedBox(width: 60, child: Text('Day ${d.dayNumber}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary))),
                          const SizedBox(width: 8),
                          Text('项目 ¥${(d.itemCost ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 8),
                          Text('交通 ¥${(d.transportCost ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const Spacer(),
                          Text('¥${(d.dayTotal ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                        ]),
                      )).toList(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Color _categoryColor(String category) {
    return switch (category) {
      '住宿' => AppColors.accent,
      '餐饮' => AppColors.warning,
      '交通' => AppColors.info,
      '景点' => AppColors.danger,
      '购物' => const Color(0xFF9B6B9E),
      _ => AppColors.textSecondary,
    };
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
