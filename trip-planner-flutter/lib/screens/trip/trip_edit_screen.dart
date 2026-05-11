import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../models/trip.dart';
import '../../services/trip_service.dart';
import 'trip_detail_screen.dart';

class TripEditScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripEditScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripEditScreen> createState() => _TripEditScreenState();
}

class _TripEditScreenState extends ConsumerState<TripEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _destCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  String? _startDate;
  String? _endDate;
  int _numPeople = 1;
  bool _saving = false;
  bool _loaded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _destCtrl.dispose();
    _notesCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  void _initFromTrip(Trip trip) {
    if (_loaded) return;
    _loaded = true;
    _nameCtrl.text = trip.tripName;
    _destCtrl.text = trip.destination;
    _notesCtrl.text = trip.notes ?? '';
    _budgetCtrl.text = trip.totalBudget?.toStringAsFixed(0) ?? '';
    _startDate = trip.startDate;
    _endDate = trip.endDate;
    _numPeople = trip.numPeople ?? 1;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final initial = isStart
        ? (_startDate != null ? DateTime.tryParse(_startDate!) : now)
        : (_endDate != null ? DateTime.tryParse(_endDate!) : now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial ?? now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      final dateStr = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        if (isStart) _startDate = dateStr;
        else _endDate = dateStr;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(tripServiceProvider).update(widget.tripId, TripUpdateReq(
        tripName: _nameCtrl.text.trim(),
        destination: _destCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        numPeople: _numPeople,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        totalBudget: double.tryParse(_budgetCtrl.text),
      ));
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tripAsync = ref.watch(tripDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('编辑行程')),
      body: tripAsync.when(
        loading: () => const LoadingWidget(message: '加载行程信息...'),
        error: (e, _) => AppErrorWidget(
          message: '加载失败: $e',
          onRetry: () => ref.invalidate(tripDetailProvider(widget.tripId)),
        ),
        data: (trip) {
          _initFromTrip(trip);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: '行程名称 *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '请输入行程名称' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _destCtrl,
                    decoration: const InputDecoration(labelText: '目的地 *'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? '请输入目的地' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: '开始日期'),
                            child: Text(_startDate ?? '选择日期', style: TextStyle(color: _startDate != null ? AppColors.textPrimary : AppColors.textPlaceholder)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _pickDate(false),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: '结束日期'),
                            child: Text(_endDate ?? '选择日期', style: TextStyle(color: _endDate != null ? AppColors.textPrimary : AppColors.textPlaceholder)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('出行人数', style: TextStyle(color: AppColors.textSecondary)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: _numPeople > 1 ? () => setState(() => _numPeople--) : null,
                      ),
                      Text('$_numPeople', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => setState(() => _numPeople++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _budgetCtrl,
                    decoration: const InputDecoration(labelText: '预算总额'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesCtrl,
                    decoration: const InputDecoration(labelText: '备注'),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Text('保存修改'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
