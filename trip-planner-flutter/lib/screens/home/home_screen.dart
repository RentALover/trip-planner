import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/trip.dart';
import '../../providers/trip_list_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scrollCtrl = ScrollController();
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    Future.microtask(() => ref.read(tripListProvider.notifier).load());
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(tripListProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripState = ref.watch(tripListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('我的行程'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter
          _buildFilterChips(),
          // Content
          Expanded(
            child: _buildContent(tripState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.tripCreate).then((_) {
          ref.read(tripListProvider.notifier).load(refresh: true);
        }),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [null, 'PLANNING', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'];
    final labels = ['全部', '规划中', '行程中', '已完成', '已取消'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (i) {
            final selected = _statusFilter == filters[i];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(labels[i]),
                selected: selected,
                onSelected: (_) {
                  setState(() => _statusFilter = filters[i]);
                  ref.read(tripListProvider.notifier).setFilter(status: _statusFilter);
                },
                selectedColor: AppColors.primaryLight.withValues(alpha: 0.3),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  fontSize: 13,
                  color: selected ? AppColors.primaryDark : AppColors.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildContent(TripListState state) {
    if (state.isLoading && state.trips.isEmpty) {
      return _buildShimmerList();
    }
    if (state.error != null && state.trips.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(tripListProvider.notifier).load(refresh: true),
      );
    }
    if (!state.isLoading && state.trips.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.explore_outlined,
        title: '还没有行程',
        subtitle: '开始规划你的第一次旅行吧',
        actionLabel: '创建行程',
        onAction: () => context.push(RoutePaths.tripCreate).then((_) {
          ref.read(tripListProvider.notifier).load(refresh: true);
        }),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(tripListProvider.notifier).load(refresh: true),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: state.trips.length + (state.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.trips.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            );
          }
          return _TripCard(
            trip: state.trips[index],
            onTap: () => context.push(RoutePaths.tripDetail.replaceAll(':tripId', '${state.trips[index].id}')),
            onDelete: () => _confirmDelete(state.trips[index]),
          );
        },
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: 4,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Container(
          height: 130,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(Trip trip) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${trip.tripName}」吗？此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(
            onPressed: () {
              ref.read(tripListProvider.notifier).deleteTrip(trip.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: '搜索行程名称或目的地...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (v) {
                ref.read(tripListProvider.notifier).setFilter(status: _statusFilter, keyword: v.trim().isEmpty ? null : v.trim());
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TripCard extends StatelessWidget {
  final Trip trip;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TripCard({required this.trip, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final dateStr = trip.startDate != null && trip.endDate != null
        ? '${trip.startDate} ~ ${trip.endDate}'
        : '日期待定';
    final statusLabel = AppConstants.tripStatusLabels[trip.status] ?? trip.status;
    final statusColor = switch (trip.status) {
      'PLANNING' => AppColors.info,
      'IN_PROGRESS' => AppColors.success,
      'COMPLETED' => AppColors.textPlaceholder,
      'CANCELLED' => AppColors.danger,
      _ => AppColors.textSecondary,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(color: Color(0x0A2C2416), blurRadius: 12, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.tripName,
                      style: const TextStyle(
                        fontFamily: 'NotoSerifSC', fontSize: 17,
                        fontWeight: FontWeight.w600, color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textPlaceholder),
                  const SizedBox(width: 4),
                  Text(trip.destination, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 13, color: AppColors.textPlaceholder),
                  const SizedBox(width: 4),
                  Text(dateStr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const Spacer(),
                  if (trip.daysCount != null) ...[
                    const Icon(Icons.view_day_outlined, size: 13, color: AppColors.textPlaceholder),
                    const SizedBox(width: 3),
                    Text('${trip.daysCount}天', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
