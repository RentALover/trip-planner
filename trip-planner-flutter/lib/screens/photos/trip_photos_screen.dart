import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/photo.dart';
import '../../services/photo_service.dart';

final tripPhotosProvider = FutureProvider.family<List<Photo>, int>((ref, tripId) {
  return ref.read(photoServiceProvider).list(tripId);
});

class TripPhotosScreen extends ConsumerStatefulWidget {
  final int tripId;
  const TripPhotosScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripPhotosScreen> createState() => _TripPhotosScreenState();
}

class _TripPhotosScreenState extends ConsumerState<TripPhotosScreen> {
  final Set<int> _selectedIds = {};
  bool _isSelectionMode = false;

  @override
  Widget build(BuildContext context) {
    final photosAsync = ref.watch(tripPhotosProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedIds.isEmpty ? '行程照片' : '已选 ${_selectedIds.length} 张'),
        actions: _buildAppBarActions(context),
      ),
      body: photosAsync.when(
        loading: () => const LoadingWidget(message: '加载照片...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(tripPhotosProvider(widget.tripId))),
        data: (photos) {
          if (photos.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.photo_library_outlined,
              title: '该行程还没有照片',
              subtitle: '点击右上角上传旅行回忆',
              actionLabel: '上传照片',
              onAction: () => _uploadPhotos(),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              final selected = _selectedIds.contains(photo.id);
              return GestureDetector(
                onLongPress: () {
                  if (!_isSelectionMode) setState(() => _isSelectionMode = true);
                  setState(() => selected ? _selectedIds.remove(photo.id) : _selectedIds.add(photo.id));
                },
                onTap: () {
                  if (_isSelectionMode) {
                    setState(() => selected ? _selectedIds.remove(photo.id) : _selectedIds.add(photo.id));
                  } else {
                    _showPhotoDetail(photo);
                  }
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CachedNetworkImage(
                        imageUrl: photo.thumbnailUrl ?? photo.url,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.muted),
                        errorWidget: (_, __, ___) => const Center(child: Icon(Icons.broken_image, color: AppColors.textPlaceholder)),
                      ),
                    ),
                    if (_isSelectionMode)
                      Positioned(
                        top: 6, right: 6,
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? AppColors.primary : Colors.white.withValues(alpha: 0.7),
                            border: Border.all(color: selected ? AppColors.primary : Colors.grey.shade300),
                          ),
                          child: selected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                      ),
                    if (photo.isFeatured == true && !_isSelectionMode)
                      const Positioned(bottom: 6, left: 6, child: Icon(Icons.star, size: 16, color: Colors.amber)),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      if (_selectedIds.isEmpty) ...[
        IconButton(icon: const Icon(Icons.add_photo_alternate_outlined, size: 22), tooltip: '上传照片', onPressed: _uploadPhotos),
      ] else ...[
        IconButton(icon: const Icon(Icons.star_outline, size: 22), tooltip: '切换精选', onPressed: () => _toggleFeatured(_selectedIds.toList())),
        IconButton(icon: const Icon(Icons.edit_outlined, size: 22), tooltip: '编辑标签', onPressed: _batchEdit),
        IconButton(icon: const Icon(Icons.delete_outline, size: 22), tooltip: '删除', onPressed: _batchDelete),
        TextButton(onPressed: () => setState(() { _selectedIds.clear(); _isSelectionMode = false; }), child: const Text('取消')),
      ],
    ];
  }

  Future<void> _uploadPhotos() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(maxWidth: 1920, maxHeight: 1920);
    if (picked.isEmpty) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
    );
    try {
      await ref.read(photoServiceProvider).uploadBatch(
        widget.tripId,
        picked.map((f) => f.path).toList(),
      );
      ref.invalidate(tripPhotosProvider(widget.tripId));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('上传失败: $e')));
      }
    }
  }

  void _showPhotoDetail(Photo photo) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(imageUrl: photo.url, fit: BoxFit.contain),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _actionChip(Icons.star, photo.isFeatured == true ? '取消精选' : '设为精选', () async {
                  await ref.read(photoServiceProvider).toggleFeatured(widget.tripId, photo.id);
                  ref.invalidate(tripPhotosProvider(widget.tripId));
                  if (ctx.mounted) Navigator.pop(ctx);
                }),
                const SizedBox(width: 12),
                _actionChip(Icons.delete, '删除', () async {
                  await ref.read(photoServiceProvider).delete(widget.tripId, photo.id);
                  ref.invalidate(tripPhotosProvider(widget.tripId));
                  if (ctx.mounted) Navigator.pop(ctx);
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.primary, fontSize: 13)),
        ]),
      ),
    );
  }

  Future<void> _toggleFeatured(List<int> ids) async {
    try {
      for (final id in ids) {
        await ref.read(photoServiceProvider).toggleFeatured(widget.tripId, id);
      }
      ref.invalidate(tripPhotosProvider(widget.tripId));
      setState(() { _selectedIds.clear(); _isSelectionMode = false; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('操作失败: $e')));
    }
  }

  Future<void> _batchEdit() async {
    final locationCtrl = TextEditingController();
    String? photoType;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('批量编辑'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: '地点')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: '类型'),
              items: AppConstants.photoTypes.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) => photoType = v,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          ElevatedButton(onPressed: () async {
            try {
              await ref.read(photoServiceProvider).batchUpdate(widget.tripId, PhotoBatchUpdateReq(
                ids: _selectedIds.toList(),
                location: locationCtrl.text.trim().isEmpty ? null : locationCtrl.text.trim(),
                photoType: photoType,
              ));
              ref.invalidate(tripPhotosProvider(widget.tripId));
              setState(() { _selectedIds.clear(); _isSelectionMode = false; });
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (_) {}
          }, child: const Text('确定')),
        ],
      ),
    );
  }

  Future<void> _batchDelete() async {
    if (_selectedIds.isEmpty) return;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除选中的 ${_selectedIds.length} 张照片吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref.read(photoServiceProvider).batchDelete(widget.tripId, _selectedIds.toList());
      _selectedIds.clear();
      _isSelectionMode = false;
      ref.invalidate(tripPhotosProvider(widget.tripId));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('删除失败: $e')));
    }
  }
}
