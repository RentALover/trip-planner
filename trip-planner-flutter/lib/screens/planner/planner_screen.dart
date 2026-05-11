import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/day_tabs.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/transport_connector.dart';
import '../../models/day.dart';
import '../../models/item.dart';
import '../../models/transport.dart';
import '../../services/day_service.dart';
import '../../services/item_service.dart';
import '../../services/transport_service.dart';
import 'item_form_sheet.dart';
import 'transport_form_sheet.dart';

final dayListProvider = FutureProvider.family<List<Day>, int>((ref, tripId) {
  return ref.read(dayServiceProvider).list(tripId);
});

final dayDetailProvider = FutureProvider.family<DayDetail, ({int tripId, int dayId})>((ref, params) {
  return ref.read(dayServiceProvider).getDetail(params.tripId, params.dayId);
});

class PlannerScreen extends ConsumerStatefulWidget {
  final int tripId;
  const PlannerScreen({super.key, required this.tripId});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  int? _selectedDayId;

  @override
  Widget build(BuildContext context) {
    final daysAsync = ref.watch(dayListProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('日程规划'),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_fix_high, size: 20),
            tooltip: '自动生成日程',
            onPressed: () => _generateDays(),
          ),
        ],
      ),
      body: daysAsync.when(
        loading: () => const LoadingWidget(message: '加载日程...'),
        error: (e, _) => AppErrorWidget(
          message: '加载失败: $e',
          onRetry: () => ref.invalidate(dayListProvider(widget.tripId)),
        ),
        data: (days) {
          if (days.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.calendar_month_outlined,
              title: '该行程还没有日程',
              subtitle: '手动添加或自动生成每天的日程安排',
              actionLabel: '自动生成',
              onAction: () => _generateDays(),
            );
          }

          // Auto-select first day
          if (_selectedDayId == null || !days.any((d) => d.id == _selectedDayId)) {
            _selectedDayId = days.first.id;
          }

          return Column(
            children: [
              const SizedBox(height: 12),
              DayTabs(
                days: days,
                selectedDayId: _selectedDayId,
                onDaySelected: (dayId) => setState(() => _selectedDayId = dayId),
              ),
              const SizedBox(height: 12),
              Expanded(child: _buildDayContent()),
            ],
          );
        },
      ),
      floatingActionButton: _selectedDayId != null
          ? FloatingActionButton(
              onPressed: () => _showItemForm(null),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDayContent() {
    if (_selectedDayId == null) return const SizedBox.shrink();

    final detailAsync = ref.watch(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));

    return detailAsync.when(
      loading: () => const LoadingWidget(),
      error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)))),
      data: (detail) {
        final items = detail.items;
        final transports = detail.transports;

        if (items.isEmpty && transports.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.event_note,
            title: 'Day ${detail.dayNumber} 暂无安排',
            subtitle: '点击下方按钮添加行程项',
          );
        }

        // Build items sorted by time
        final sorted = List<TripItem>.from(items)..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!))),
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: sorted.length,
            onReorder: (oldIndex, newIndex) => _onReorder(sorted, oldIndex, newIndex),
            proxyDecorator: (child, index, animation) {
              return Material(color: Colors.transparent, elevation: 4, borderRadius: BorderRadius.circular(8), child: child);
            },
            itemBuilder: (context, index) {
              final item = sorted[index];
              Transport? transport;
              if (index > 0) {
                final prevItem = sorted[index - 1];
                transport = transports.cast<Transport?>().firstWhere(
                  (t) => t?.fromItemId == prevItem.id && t?.toItemId == item.id,
                  orElse: () => null,
                );
              }

              return Column(
                key: ValueKey(item.id),
                children: [
                  if (transport != null)
                    TransportConnector(
                      transport: transport,
                      onTap: () => _showTransportForm(transport),
                      onDelete: () => _deleteTransport(transport!.id),
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: ItemCard(
                      item: item,
                      onTap: () => _showItemForm(item),
                      onEdit: () => _showItemForm(item),
                      onDelete: () => _deleteItem(item),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _generateDays() async {
    try {
      await ref.read(dayServiceProvider).generate(widget.tripId);
      ref.invalidate(dayListProvider(widget.tripId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('日程已自动生成')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('生成失败: $e')));
      }
    }
  }

  void _showItemForm(TripItem? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItemFormSheet(
        dayId: _selectedDayId!,
        existingItem: existing,
        onSaved: () {
          ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
        },
      ),
    );
  }

  void _showTransportForm(Transport? existing) {
    final detail = ref.read(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
    final items = detail.value?.items ?? [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TransportFormSheet(
        dayId: _selectedDayId!,
        existingTransport: existing,
        dayItems: items,
        onSaved: () {
          ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
        },
      ),
    );
  }

  Future<void> _deleteItem(TripItem item) async {
    try {
      await ref.read(itemServiceProvider).delete(item.dayId, item.id);
      ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  Future<void> _deleteTransport(int transportId) async {
    try {
      await ref.read(transportServiceProvider).delete(_selectedDayId!, transportId);
      ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }

  Future<void> _onReorder(List<TripItem> items, int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex--;
    final reordered = List<TripItem>.from(items);
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    // Recalculate sort orders with gaps of 1000
    final sortItems = reordered.asMap().entries.map((e) => SortItem(id: e.value.id, sortOrder: (e.key * 1000).toDouble())).toList();
    try {
      await ref.read(itemServiceProvider).reorder(_selectedDayId!, ItemSortReq(items: sortItems));
      ref.invalidate(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('排序失败: $e')));
    }
  }
}
