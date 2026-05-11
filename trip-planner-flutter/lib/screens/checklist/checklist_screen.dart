import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/checklist.dart';
import '../../services/checklist_service.dart';

final checklistProvider = FutureProvider.family<List<ChecklistItem>, int>((ref, tripId) {
  return ref.read(checklistServiceProvider).list(tripId);
});

class ChecklistScreen extends ConsumerStatefulWidget {
  final int tripId;
  const ChecklistScreen({super.key, required this.tripId});

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  String? _categoryFilter;

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(checklistProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('行前清单'), actions: [
        IconButton(icon: const Icon(Icons.done_all, size: 20), tooltip: '全选', onPressed: () => _toggleAll(true)),
        IconButton(icon: const Icon(Icons.remove_done, size: 20), tooltip: '取消全选', onPressed: () => _toggleAll(false)),
        IconButton(icon: const Icon(Icons.auto_awesome, size: 20), tooltip: '加载预设清单', onPressed: () => _loadPreset()),
      ]),
      body: Column(
        children: [
          // Category filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('全部'),
                  selected: _categoryFilter == null,
                  onSelected: (_) => setState(() => _categoryFilter = null),
                  selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primary,
                  side: BorderSide(color: _categoryFilter == null ? AppColors.primary : AppColors.border),
                ),
                ...AppConstants.checklistCategories.entries.map((e) {
                  final selected = _categoryFilter == e.key;
                  return Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FilterChip(
                      label: Text(e.value),
                      selected: selected,
                      onSelected: (_) => setState(() => _categoryFilter = selected ? null : e.key),
                      selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                      checkmarkColor: AppColors.primary,
                      side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                    ),
                  );
                }),
              ],
            ),
          ),

          Expanded(
            child: itemsAsync.when(
              loading: () => const LoadingWidget(message: '加载清单...'),
              error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(checklistProvider(widget.tripId))),
              data: (allItems) {
                final items = _categoryFilter == null
                    ? allItems
                    : allItems.where((i) => i.category == _categoryFilter).toList();

                if (allItems.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.checklist_outlined,
                    title: '行前清单为空',
                    subtitle: '添加出行必备物品或加载预设清单',
                    actionLabel: '加载预设清单',
                    onAction: () => _loadPreset(),
                  );
                }

                final checked = items.where((i) => i.isChecked).length;

                return Column(
                  children: [
                    // Progress bar
                    if (items.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: checked / items.length,
                                  backgroundColor: AppColors.borderLight,
                                  color: AppColors.success,
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('$checked/${items.length}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final catLabel = AppConstants.checklistCategories[item.category] ?? item.category;
                          return ListTile(
                            leading: Icon(
                              item.isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                              color: item.isChecked ? AppColors.success : AppColors.textPlaceholder,
                            ),
                            title: Text(
                              item.title,
                              style: TextStyle(
                                fontSize: 14,
                                color: item.isChecked ? AppColors.textPlaceholder : AppColors.textPrimary,
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: Text(catLabel, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 16, color: AppColors.textPlaceholder),
                              onPressed: () => _delete(item),
                            ),
                            onTap: () => _toggle(item),
                            onLongPress: () => _editItem(item),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggle(ChecklistItem item) async {
    try {
      await ref.read(checklistServiceProvider).toggle(widget.tripId, item.id);
      ref.invalidate(checklistProvider(widget.tripId));
    } catch (_) {}
  }

  Future<void> _delete(ChecklistItem item) async {
    try {
      await ref.read(checklistServiceProvider).delete(widget.tripId, item.id);
      ref.invalidate(checklistProvider(widget.tripId));
    } catch (_) {}
  }

  Future<void> _toggleAll(bool checked) async {
    try {
      await ref.read(checklistServiceProvider).toggleAll(widget.tripId, checked);
      ref.invalidate(checklistProvider(widget.tripId));
    } catch (_) {}
  }

  Future<void> _loadPreset() async {
    try {
      await ref.read(checklistServiceProvider).loadPreset(widget.tripId);
      ref.invalidate(checklistProvider(widget.tripId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载预设失败: $e')));
    }
  }

  void _editItem(ChecklistItem item) {
    final nameCtrl = TextEditingController(text: item.title);
    String category = item.category;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('编辑清单项'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '名称')),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: category,
            decoration: const InputDecoration(labelText: '分类'),
            items: AppConstants.checklistCategories.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => category = v!,
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(onPressed: () async {
            try {
              await ref.read(checklistServiceProvider).update(widget.tripId, item.id, ChecklistItemReq(title: nameCtrl.text.trim(), category: category));
              ref.invalidate(checklistProvider(widget.tripId));
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) {}
          }, child: const Text('保存')),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final ctrl = TextEditingController();
    String category = 'OTHER';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加清单项'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: ctrl, decoration: const InputDecoration(labelText: '名称')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: category,
              decoration: const InputDecoration(labelText: '分类'),
              items: AppConstants.checklistCategories.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => category = v!,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(onPressed: () async {
            try {
              await ref.read(checklistServiceProvider).create(widget.tripId, ChecklistItemReq(title: ctrl.text.trim(), category: category));
              ref.invalidate(checklistProvider(widget.tripId));
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) {}
          }, child: const Text('添加')),
        ],
      ),
    );
  }
}
