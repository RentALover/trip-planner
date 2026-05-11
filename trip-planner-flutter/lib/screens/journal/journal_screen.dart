import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/journal.dart';
import '../../services/journal_service.dart';

final journalProvider = FutureProvider.family<Journal?, int>((ref, dayId) {
  return ref.read(journalServiceProvider).get(dayId);
});

class JournalScreen extends ConsumerStatefulWidget {
  final int tripId;
  final int dayId;
  const JournalScreen({super.key, required this.tripId, required this.dayId});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen> {
  final _contentCtrl = TextEditingController();
  String? _mood;
  String? _weather;
  bool _saving = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ref.read(journalServiceProvider).save(widget.dayId, JournalReq(
        content: _contentCtrl.text,
        mood: _mood,
        weather: _weather,
      ));
      ref.invalidate(journalProvider(widget.dayId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('日记已保存')));
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final journalAsync = ref.watch(journalProvider(widget.dayId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('旅行日记'),
        actions: [
          TextButton(onPressed: _saving ? null : _save, child: const Text('保存')),
        ],
      ),
      body: journalAsync.when(
        loading: () => const LoadingWidget(message: '加载日记...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(journalProvider(widget.dayId))),
        data: (journal) {
          // Init from journal data
          if (journal != null && _contentCtrl.text.isEmpty) {
            _contentCtrl.text = journal.content;
            _mood = journal.mood;
            _weather = journal.weather;
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Mood selector
              const Text('今日心情', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.journalMoods.entries.map((e) {
                  final selected = _mood == e.key;
                  return ChoiceChip(
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setState(() => _mood = selected ? null : e.key),
                    selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Weather selector
              const Text('今日天气', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: AppConstants.journalWeathers.entries.map((e) {
                  final selected = _weather == e.key;
                  return ChoiceChip(
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    onSelected: (_) => setState(() => _weather = selected ? null : e.key),
                    selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Content
              TextFormField(
                controller: _contentCtrl,
                decoration: const InputDecoration(
                  hintText: '记录今天的旅行故事...',
                  border: InputBorder.none,
                ),
                maxLines: 15,
                style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary),
              ),
            ],
          );
        },
      ),
    );
  }
}
