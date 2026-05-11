import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/day_tabs.dart';
import '../../core/widgets/item_card.dart';
import '../../core/widgets/transport_connector.dart';
import '../../models/trip.dart';
import '../../models/day.dart';
import '../../models/item.dart';
import '../../models/transport.dart';
import '../../models/journal.dart';
import '../../services/trip_service.dart';
import '../../services/day_service.dart';
import '../../services/journal_service.dart';
import '../../providers/trip_list_provider.dart';

final tripDetailProvider = FutureProvider.family<Trip, int>((ref, tripId) {
  return ref.read(tripServiceProvider).getById(tripId);
});

final dayListProvider = FutureProvider.family<List<Day>, int>((ref, tripId) {
  return ref.read(dayServiceProvider).list(tripId);
});

final dayDetailProvider = FutureProvider.family<DayDetail, ({int tripId, int dayId})>((ref, params) {
  return ref.read(dayServiceProvider).getDetail(params.tripId, params.dayId);
});

class TripDetailScreen extends ConsumerStatefulWidget {
  final int tripId;

  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  int? _selectedDayId;

  String _sectionTitle(String status) {
    return switch (status) {
      'PLANNING' => '行程预览',
      'IN_PROGRESS' => '行程进行中',
      'COMPLETED' => '行程回顾',
      _ => '行程概览',
    };
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('行程详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 22),
            onPressed: () => context.push(RoutePaths.tripEdit.replaceAll(':tripId', '${widget.tripId}')),
          ),
          PopupMenuButton<String>(
            onSelected: (action) async {
              if (action == 'copy') {
                try {
                  await ref.read(tripServiceProvider).copy(widget.tripId);
                  ref.read(tripListProvider.notifier).load(refresh: true);
                  if (context.mounted) context.pop();
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('复制失败: $e')));
                }
              } else if (action == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'copy', child: Text('复制行程')),
              const PopupMenuItem(value: 'delete', child: Text('删除行程', style: TextStyle(color: AppColors.danger))),
            ],
          ),
        ],
      ),
      body: tripAsync.when(
        loading: () => const LoadingWidget(message: '加载行程信息...'),
        error: (e, _) => AppErrorWidget(
          message: '加载失败: $e',
          onRetry: () => ref.invalidate(tripDetailProvider(widget.tripId)),
        ),
        data: (trip) => _buildFullContent(context, ref, trip),
      ),
    );
  }

  // ─── FULL CONTENT ────────────────────────────────────

  Widget _buildFullContent(BuildContext context, WidgetRef ref, Trip trip) {
    final statusColor = _statusColor(trip.status);
    final statusLabel = AppConstants.tripStatusLabels[trip.status] ?? trip.status;
    final dateStr = trip.startDate != null && trip.endDate != null
        ? '${trip.startDate} ~ ${trip.endDate}'
        : '日期待定';
    final isReadOnly = trip.status == 'COMPLETED' || trip.status == 'CANCELLED';
    final showJournal = trip.status == 'IN_PROGRESS' || trip.status == 'COMPLETED';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async => ref.invalidate(tripDetailProvider(widget.tripId)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 1. Trip Info Header ──
          _buildHeaderCard(trip, statusColor, statusLabel, dateStr, isReadOnly),
          const SizedBox(height: 16),

          // ── 2. Nav Buttons ──
          _buildNavRow(context, trip, isReadOnly),
          const SizedBox(height: 20),

          // ── 3. Itinerary Preview Section ──
          Text(_sectionTitle(trip.status), style: const TextStyle(
            fontFamily: 'NotoSerifSC', fontSize: 18, fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          )),
          const SizedBox(height: 10),
          _buildItinerarySection(ref, trip, isReadOnly, showJournal),

          // ── 4. Photo Gallery ──
          const SizedBox(height: 24),
          _buildPhotoStrip(ref),
        ],
      ),
    );
  }

  // ─── HEADER CARD ─────────────────────────────────────

  Widget _buildHeaderCard(Trip trip, Color statusColor, String statusLabel, String dateStr, bool isReadOnly) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (trip.coverImageUrl != null && trip.coverImageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(trip.coverImageUrl!, height: 130, width: double.infinity, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const SizedBox.shrink()),
          ),
          const SizedBox(height: 12),
        ],
        Row(children: [
          Expanded(child: Text(trip.tripName, style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 10),
        _infoRow(Icons.location_on_outlined, trip.destination),
        const SizedBox(height: 4),
        _infoRow(Icons.calendar_today_outlined, dateStr),
        if (trip.numPeople != null && trip.numPeople! > 0) ...[
          const SizedBox(height: 4),
          _infoRow(Icons.people_outlined, '${trip.numPeople}人'),
        ],
        if (trip.notes != null && trip.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(trip.notes!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ],
        if (!isReadOnly) ...[
          const SizedBox(height: 12),
          Row(children: [
            if (trip.status == 'PLANNING')
              Expanded(child: OutlinedButton(
                onPressed: () => _changeStatus(context, ref, trip, 'CANCELLED'),
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger, side: const BorderSide(color: AppColors.danger)),
                child: const Text('取消行程'),
              )),
            if (trip.status == 'CANCELLED')
              Expanded(child: OutlinedButton(
                onPressed: () => _changeStatus(context, ref, trip, 'PLANNING'),
                child: const Text('重新激活'),
              )),
          ]),
        ],
      ]),
    );
  }

  // ─── NAV ROW ─────────────────────────────────────────

  Widget _buildNavRow(BuildContext context, Trip trip, bool isReadOnly) {
    final actions = [
      if (!isReadOnly) _navChip(Icons.edit_calendar, '日程规划', AppColors.primary, RoutePaths.planner.replaceAll(':tripId', '${widget.tripId}')),
      _navChip(Icons.account_balance_wallet, '预算', AppColors.accent, RoutePaths.budget.replaceAll(':tripId', '${widget.tripId}')),
      _navChip(Icons.checklist, '行前清单', AppColors.success, RoutePaths.checklist.replaceAll(':tripId', '${widget.tripId}')),
      _navChip(Icons.photo_library, '照片', AppColors.warning, RoutePaths.tripPhotos.replaceAll(':tripId', '${widget.tripId}')),
      _navChip(Icons.map, '地图', AppColors.info, RoutePaths.map.replaceAll(':tripId', '${widget.tripId}')),
      _navChip(Icons.download, '导出', AppColors.textSecondary, RoutePaths.export.replaceAll(':tripId', '${widget.tripId}')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: actions.map((w) => Padding(padding: const EdgeInsets.only(right: 8), child: w)).toList()),
    );
  }

  Widget _navChip(IconData icon, String label, Color color, String route) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
        ]),
      ),
    );
  }

  // ─── ITINERARY PREVIEW ───────────────────────────────

  Widget _buildItinerarySection(WidgetRef ref, Trip trip, bool isReadOnly, bool showJournal) {
    final daysAsync = ref.watch(dayListProvider(widget.tripId));

    return daysAsync.when(
      loading: () => const Padding(padding: EdgeInsets.all(20), child: LoadingWidget()),
      error: (_, __) => const SizedBox.shrink(),
      data: (days) {
        if (days.isEmpty) {
          return EmptyStateWidget(
            icon: Icons.calendar_month_outlined,
            title: '还没有日程安排',
            subtitle: isReadOnly ? null : '进入日程规划开始编排行程',
            actionLabel: isReadOnly ? null : '进入规划',
            onAction: isReadOnly ? null : () => context.push(RoutePaths.planner.replaceAll(':tripId', '${widget.tripId}')),
          );
        }

        if (_selectedDayId == null || !days.any((d) => d.id == _selectedDayId)) {
          _selectedDayId = days.first.id;
        }

        final selectedDay = days.firstWhere((d) => d.id == _selectedDayId);
        final detailAsync = ref.watch(dayDetailProvider((tripId: widget.tripId, dayId: _selectedDayId!)));

        return Column(children: [
          // Day tabs
          DayTabs(days: days, selectedDayId: _selectedDayId, onDaySelected: (id) => setState(() => _selectedDayId = id)),
          const SizedBox(height: 12),

          // Day summary bar
          _buildDaySummaryBar(selectedDay, detailAsync),
          const SizedBox(height: 8),

          // Item list (read-only)
          detailAsync.when(
            loading: () => const Padding(padding: EdgeInsets.all(20), child: LoadingWidget()),
            error: (_, __) => const SizedBox.shrink(),
            data: (detail) {
              final items = List<TripItem>.from(detail.items)
                ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
              final transports = detail.transports;

              if (items.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text('Day ${detail.dayNumber} 还没有行程安排', style: const TextStyle(color: AppColors.textSecondary)),
                );
              }

              final sorted = List<TripItem>.from(items)
                ..sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

              return Column(
                children: List.generate(items.length, (i) {
                  final item = sorted[i];
                  Transport? transport;
                  if (i > 0) {
                    final prev = sorted[i - 1];
                    transport = transports.cast<Transport?>().firstWhere(
                      (t) => t?.fromItemId == prev.id && t?.toItemId == item.id,
                      orElse: () => null,
                    );
                  }
                  return Column(children: [
                    if (transport != null)
                      TransportConnector(transport: transport),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: ItemCard(item: item, showDragHandle: false),
                    ),
                  ]);
                }),
              );
            },
          ),

          // Journal section
          if (showJournal) ...[
            const SizedBox(height: 16),
            _JournalPreview(dayId: _selectedDayId!),
          ],
        ]);
      },
    );
  }

  Widget _buildDaySummaryBar(Day day, AsyncValue<DayDetail> detailAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(children: [
        _summaryStat(Icons.event_note, '${day.itemCount ?? 0} 项'),
        const SizedBox(width: 16),
        detailAsync.when(
          loading: () => const Text('...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          error: (_, __) => const SizedBox.shrink(),
          data: (d) => _summaryStat(Icons.directions_bus, '${d.transports.length} 交通'),
        ),
        const Spacer(),
        detailAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (d) {
            final cost = d.items.fold<double>(0, (sum, i) => sum + (i.cost ?? 0))
                + d.transports.fold<double>(0, (sum, t) => sum + (t.cost ?? 0));
            return cost > 0 ? Text('¥${cost.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)) : const SizedBox.shrink();
          },
        ),
      ]),
    );
  }

  Widget _summaryStat(IconData icon, String text) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
    ]);
  }

  // ─── PHOTO STRIP ─────────────────────────────────────

  Widget _buildPhotoStrip(WidgetRef ref) {
    // Just show a link to the full photo page
    return InkWell(
      onTap: () => context.push(RoutePaths.tripPhotos.replaceAll(':tripId', '${widget.tripId}')),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(children: [
          const Icon(Icons.photo_library_outlined, color: AppColors.warning),
          const SizedBox(width: 10),
          const Text('查看全部照片', style: TextStyle(fontSize: 14, color: AppColors.textPrimary)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: AppColors.textPlaceholder),
        ]),
      ),
    );
  }

  // ─── HELPERS ─────────────────────────────────────────

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(color: AppColors.textRegular, fontSize: 13)),
    ]);
  }

  Color _statusColor(String status) {
    return switch (status) {
      'PLANNING' => AppColors.info,
      'IN_PROGRESS' => AppColors.success,
      'COMPLETED' => AppColors.textPlaceholder,
      'CANCELLED' => AppColors.danger,
      _ => AppColors.textSecondary,
    };
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除此行吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () async {
              try {
                await ref.read(tripServiceProvider).delete(widget.tripId);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) context.pop();
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(BuildContext context, WidgetRef ref, Trip trip, String newStatus) async {
    try {
      await ref.read(tripServiceProvider).updateStatus(widget.tripId, newStatus);
      ref.invalidate(tripDetailProvider(widget.tripId));
      ref.read(tripListProvider.notifier).load(refresh: true);
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }
}

// ─── JOURNAL PREVIEW ─────────────────────────────────────────

final journalProvider = FutureProvider.family<Journal?, int>((ref, dayId) {
  return ref.read(journalServiceProvider).get(dayId);
});

class _JournalPreview extends ConsumerWidget {
  final int dayId;
  const _JournalPreview({required this.dayId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journalAsync = ref.watch(journalProvider(dayId));

    return journalAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (journal) {
        if (journal == null || journal.content.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(children: [
              const Icon(Icons.book_outlined, size: 18, color: AppColors.textPlaceholder),
              const SizedBox(width: 8),
              const Text('这一天还没有记录', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Navigate to journal editor via trip detail info
                  final router = GoRouter.of(context);
                  final currentPath = router.state?.uri.path ?? '';
                  final tripId = currentPath.split('/')[2]; // /trips/:tripId
                  context.push(RoutePaths.journal.replaceAll(':tripId', tripId).replaceAll(':dayId', '$dayId'));
                },
                child: const Text('写日记', style: TextStyle(color: AppColors.primary, fontSize: 13)),
              ),
            ]),
          );
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.book_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('旅行日记', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              if (journal.mood != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primaryLight.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                  child: Text(AppConstants.journalMoods[journal.mood] ?? journal.mood!, style: const TextStyle(fontSize: 11, color: AppColors.primaryDark)),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () {
                  final router = GoRouter.of(context);
                  final currentPath = router.state?.uri.path ?? '';
                  final tripId = currentPath.split('/')[2];
                  context.push(RoutePaths.journal.replaceAll(':tripId', tripId).replaceAll(':dayId', '$dayId'));
                },
                child: const Text('编辑', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(journal.content, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textRegular)),
          ]),
        );
      },
    );
  }
}
