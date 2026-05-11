import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../services/export_service.dart';
import '../trip/trip_detail_screen.dart';

final exportProvider = FutureProvider.family<String, int>((ref, tripId) {
  return ref.read(exportServiceProvider).exportText(tripId);
});

class ExportScreen extends ConsumerWidget {
  final int tripId;
  const ExportScreen({super.key, required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exportAsync = ref.watch(exportProvider(tripId));
    final tripAsync = ref.watch(tripDetailProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('导出'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy, size: 20),
            tooltip: '复制内容',
            onPressed: () {
              exportAsync.whenData((text) {
                Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已复制到剪贴板')));
              });
            },
          ),
        ],
      ),
      body: exportAsync.when(
        loading: () => const LoadingWidget(message: '生成导出内容...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(exportProvider(tripId))),
        data: (text) {
          return Column(
            children: [
              // Trip name header
              tripAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (trip) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.muted,
                  child: Text(trip.tripName, style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              // Markdown preview
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(
                    text,
                    style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textPrimary),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
