import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/item.dart';
import '../../models/transport.dart';
import '../../services/transport_service.dart';

class TransportFormSheet extends ConsumerStatefulWidget {
  final int dayId;
  final Transport? existingTransport;
  final List<TripItem> dayItems;
  final VoidCallback onSaved;

  const TransportFormSheet({super.key, required this.dayId, this.existingTransport, required this.dayItems, required this.onSaved});

  @override
  ConsumerState<TransportFormSheet> createState() => _TransportFormSheetState();
}

class _TransportFormSheetState extends ConsumerState<TransportFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _departureCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _transportType = 'WALK';
  int? _fromItemId;
  int? _toItemId;
  bool _saving = false;
  bool _lookingUp = false;

  bool get _isEditing => widget.existingTransport != null;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTransport;
    if (t != null) {
      _fromItemId = t.fromItemId;
      _toItemId = t.toItemId;
      _departureCtrl.text = t.departureTime ?? '';
      _durationCtrl.text = t.estimatedDuration?.toString() ?? '';
      _costCtrl.text = t.cost?.toStringAsFixed(0) ?? '';
      _numberCtrl.text = t.transportNumber ?? '';
      _notesCtrl.text = t.notes ?? '';
      _transportType = t.transportType;
    }
  }

  @override
  void dispose() {
    _departureCtrl.dispose();
    _durationCtrl.dispose();
    _costCtrl.dispose();
    _numberCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (_transportType != 'FLIGHT' && _transportType != 'TRAIN') return;
    final number = _numberCtrl.text.trim();
    if (number.isEmpty) return;
    setState(() => _lookingUp = true);
    try {
      final result = await ref.read(transportServiceProvider).lookup(_transportType, number, null);
      if (result != null && mounted) {
        if (result.departureStation != null || result.arrivalStation != null || result.durationMinutes != null) {
          _durationCtrl.text = result.durationMinutes?.toString() ?? '';
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(
            '${result.departureStation ?? "?"} → ${result.arrivalStation ?? "?"}  ${result.durationMinutes != null ? "${result.durationMinutes}分钟" : ""}',
          )));
        }
      }
    } catch (_) {}
    setState(() => _lookingUp = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fromItemId == null || _toItemId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请选择出发和到达的行程项')));
      return;
    }
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await ref.read(transportServiceProvider).update(
          widget.dayId, widget.existingTransport!.id,
          TransportUpdateReq(
            transportType: _transportType,
            departureTime: _departureCtrl.text.trim().isEmpty ? null : _departureCtrl.text.trim(),
            estimatedDuration: int.tryParse(_durationCtrl.text),
            cost: double.tryParse(_costCtrl.text),
            transportNumber: _numberCtrl.text.trim().isEmpty ? null : _numberCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          ),
        );
      } else {
        await ref.read(transportServiceProvider).create(
          widget.dayId,
          TransportCreateReq(
            fromItemId: _fromItemId!, toItemId: _toItemId!,
            transportType: _transportType,
            departureTime: _departureCtrl.text.trim().isEmpty ? null : _departureCtrl.text.trim(),
            estimatedDuration: int.tryParse(_durationCtrl.text),
            cost: double.tryParse(_costCtrl.text),
            transportNumber: _numberCtrl.text.trim().isEmpty ? null : _numberCtrl.text.trim(),
            notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          ),
        );
      }
      widget.onSaved();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('保存失败: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final itemOptions = widget.dayItems.map((item) =>
      DropdownMenuItem(value: item.id, child: Text(item.title, overflow: TextOverflow.ellipsis))
    ).toList();

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(_isEditing ? '编辑交通' : '添加交通', style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 18, fontWeight: FontWeight.w600)),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
            ]),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(children: [
                  DropdownButtonFormField<String>(
                    value: _transportType,
                    decoration: const InputDecoration(labelText: '交通方式'),
                    items: AppConstants.transportTypeLabels.entries
                        .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                        .toList(),
                    onChanged: (v) => setState(() => _transportType = v!),
                  ),
                  const SizedBox(height: 14),
                  if (!_isEditing) ...[
                    DropdownButtonFormField<int>(
                      value: _fromItemId,
                      decoration: const InputDecoration(labelText: '从哪个行程项出发'),
                      items: itemOptions,
                      onChanged: (v) => setState(() => _fromItemId = v),
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<int>(
                      value: _toItemId,
                      decoration: const InputDecoration(labelText: '到哪个行程项'),
                      items: itemOptions,
                      onChanged: (v) => setState(() => _toItemId = v),
                    ),
                    const SizedBox(height: 14),
                  ],
                  TextFormField(
                    controller: _departureCtrl,
                    decoration: const InputDecoration(labelText: '出发时间', hintText: 'HH:mm'),
                  ),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _durationCtrl, decoration: const InputDecoration(labelText: '耗时(分钟)'), keyboardType: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: TextFormField(controller: _costCtrl, decoration: const InputDecoration(labelText: '费用', prefixText: '¥ '), keyboardType: TextInputType.number)),
                  ]),
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(child: TextFormField(controller: _numberCtrl, decoration: const InputDecoration(labelText: '车次/航班号'))),
                    if (_transportType == 'FLIGHT' || _transportType == 'TRAIN') ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _lookingUp ? null : _lookup,
                        child: _lookingUp ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('查询'),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 14),
                  TextFormField(controller: _notesCtrl, decoration: const InputDecoration(labelText: '备注'), maxLines: 2),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _save,
                      child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_isEditing ? '保存修改' : '添加'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
