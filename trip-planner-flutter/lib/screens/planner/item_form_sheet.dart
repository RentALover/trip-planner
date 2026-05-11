import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/item.dart';
import '../../services/item_service.dart';

class ItemFormSheet extends ConsumerStatefulWidget {
  final int dayId;
  final TripItem? existingItem;
  final VoidCallback onSaved;

  const ItemFormSheet({super.key, required this.dayId, this.existingItem, required this.onSaved});

  @override
  ConsumerState<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends ConsumerState<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  final _startTimeCtrl = TextEditingController();
  final _endTimeCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _itemType = 'ATTRACTION';
  bool _saving = false;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    if (item != null) {
      _titleCtrl.text = item.title;
      _locCtrl.text = item.location ?? '';
      _startTimeCtrl.text = item.startTime ?? '';
      _endTimeCtrl.text = item.endTime ?? '';
      _costCtrl.text = item.cost?.toStringAsFixed(0) ?? '';
      _descCtrl.text = item.description ?? '';
      _itemType = item.itemType;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locCtrl.dispose();
    _startTimeCtrl.dispose();
    _endTimeCtrl.dispose();
    _costCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (_isEditing) {
        await ref.read(itemServiceProvider).update(
          widget.dayId, widget.existingItem!.id,
          ItemUpdateReq(
            title: _titleCtrl.text.trim(),
            location: _locCtrl.text.trim().isEmpty ? null : _locCtrl.text.trim(),
            startTime: _startTimeCtrl.text.trim().isEmpty ? null : _startTimeCtrl.text.trim(),
            endTime: _endTimeCtrl.text.trim().isEmpty ? null : _endTimeCtrl.text.trim(),
            cost: double.tryParse(_costCtrl.text),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          ),
        );
      } else {
        await ref.read(itemServiceProvider).create(
          widget.dayId,
          ItemCreateReq(
            itemType: _itemType, title: _titleCtrl.text.trim(),
            location: _locCtrl.text.trim().isEmpty ? null : _locCtrl.text.trim(),
            startTime: _startTimeCtrl.text.trim().isEmpty ? null : _startTimeCtrl.text.trim(),
            endTime: _endTimeCtrl.text.trim().isEmpty ? null : _endTimeCtrl.text.trim(),
            cost: double.tryParse(_costCtrl.text),
            description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
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
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(_isEditing ? '编辑行程项' : '添加行程项', style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 18, fontWeight: FontWeight.w600)),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
              ],
            ),
          ),
          // Form
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Type selector
                    if (!_isEditing) ...[
                      DropdownButtonFormField<String>(
                        value: _itemType,
                        decoration: const InputDecoration(labelText: '类型'),
                        items: AppConstants.itemTypeLabels.entries
                            .where((e) => e.key != 'TRANSPORT')
                            .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                            .toList(),
                        onChanged: (v) => setState(() => _itemType = v!),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(labelText: '名称 *'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? '请输入名称' : null,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _startTimeCtrl,
                            decoration: const InputDecoration(labelText: '开始时间', hintText: 'HH:mm'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _endTimeCtrl,
                            decoration: const InputDecoration(labelText: '结束时间', hintText: 'HH:mm'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _locCtrl,
                      decoration: const InputDecoration(labelText: '地点', prefixIcon: Icon(Icons.location_on_outlined, size: 20)),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _costCtrl,
                      decoration: const InputDecoration(labelText: '费用', prefixText: '¥ '),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descCtrl,
                      decoration: const InputDecoration(labelText: '备注'),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : Text(_isEditing ? '保存修改' : '添加'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
