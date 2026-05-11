import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import 'package:go_router/go_router.dart';
import '../../core/router/route_names.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/photo.dart';
import '../../services/photo_service.dart';

final photoAlbumProvider = FutureProvider<List<PhotoAlbumItem>>((ref) {
  return ref.read(photoServiceProvider).listAll();
});

class PhotoAlbumScreen extends ConsumerWidget {
  const PhotoAlbumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumAsync = ref.watch(photoAlbumProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('旅行相册')),
      body: albumAsync.when(
        loading: () => const LoadingWidget(message: '加载相册...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(photoAlbumProvider)),
        data: (photos) {
          if (photos.isEmpty) {
            return const EmptyStateWidget(icon: Icons.photo_library_outlined, title: '还没有照片', subtitle: '在各行程中添加照片后这里会展示旅行回忆');
          }

          // Group by trip
          final grouped = <String, List<PhotoAlbumItem>>{};
          for (final p in photos) {
            grouped.putIfAbsent(p.tripName, () => []).add(p);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      final tripId = entry.value.first.tripId;
                      context.push(RoutePaths.tripPhotos.replaceAll(':tripId', '$tripId'));
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 16, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(entry.key, style: const TextStyle(fontFamily: 'NotoSerifSC', fontSize: 16, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('${entry.value.length} 张', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textPlaceholder),
                        ],
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
                    itemCount: entry.value.length,
                    itemBuilder: (context, index) {
                      final photo = entry.value[index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: CachedNetworkImage(
                          imageUrl: photo.thumbnailUrl ?? photo.url,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.muted),
                          errorWidget: (_, __, ___) => const Icon(Icons.broken_image, color: AppColors.textPlaceholder),
                        ),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
