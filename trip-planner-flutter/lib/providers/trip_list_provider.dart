import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/trip.dart';
import '../services/trip_service.dart';

class TripListState {
  final List<Trip> trips;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final int total;
  final bool hasMore;

  const TripListState({
    this.trips = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.total = 0,
    this.hasMore = true,
  });

  TripListState copyWith({
    List<Trip>? trips, bool? isLoading, bool? isLoadingMore,
    String? error, int? currentPage, int? total, bool? hasMore,
  }) {
    return TripListState(
      trips: trips ?? this.trips,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class TripListNotifier extends Notifier<TripListState> {
  String? _statusFilter;
  String? _keyword;

  @override
  TripListState build() => const TripListState();

  Future<void> load({bool refresh = false}) async {
    if (refresh) {
      state = const TripListState();
    }
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null, currentPage: 1);
    try {
      final result = await ref.read(tripServiceProvider).list(
        page: 1, status: _statusFilter, keyword: _keyword,
      );
      state = state.copyWith(
        trips: result.records, isLoading: false, currentPage: 1,
        total: result.total, hasMore: result.records.length < result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final nextPage = state.currentPage + 1;
      final result = await ref.read(tripServiceProvider).list(
        page: nextPage, status: _statusFilter, keyword: _keyword,
      );
      state = state.copyWith(
        trips: [...state.trips, ...result.records],
        isLoadingMore: false, currentPage: nextPage,
        hasMore: state.trips.length + result.records.length < result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  void setFilter({String? status, String? keyword}) {
    _statusFilter = status;
    _keyword = keyword;
    load(refresh: true);
  }

  Future<void> deleteTrip(int id) async {
    await ref.read(tripServiceProvider).delete(id);
    state = state.copyWith(
      trips: state.trips.where((t) => t.id != id).toList(),
    );
  }
}

final tripListProvider = NotifierProvider<TripListNotifier, TripListState>(TripListNotifier.new);
