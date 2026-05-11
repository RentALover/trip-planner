import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../models/item.dart';

class ItemCard extends StatelessWidget {
  final TripItem item;
  final bool showDragHandle;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ItemCard({
    super.key, required this.item, this.showDragHandle = true,
    this.onTap, this.onEdit, this.onDelete,
  });

  IconData get _icon => switch (item.itemType) {
    'TRANSPORT' => Icons.directions_bus,
    'ACCOMMODATION' => Icons.hotel,
    'DINING' => Icons.restaurant,
    'ATTRACTION' => Icons.attractions,
    'SHOPPING' => Icons.shopping_bag,
    _ => Icons.place,
  };

  Color get _color => switch (item.itemType) {
    'TRANSPORT' => const Color(0xFF3D6B6B),
    'ACCOMMODATION' => const Color(0xFF7B8C4E),
    'DINING' => const Color(0xFFC4963E),
    'ATTRACTION' => const Color(0xFFB8453E),
    'SHOPPING' => const Color(0xFF6B7D8B),
    _ => const Color(0xFF8B7E6A),
  };

  @override
  Widget build(BuildContext context) {
    final hasTime = item.startTime != null || item.endTime != null;
    final timeStr = hasTime
        ? '${item.startTime ?? ''}${item.startTime != null && item.endTime != null ? ' ~ ' : ''}${item.endTime ?? ''}'
        : null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: _color, width: 3)),
          boxShadow: const [
            BoxShadow(color: Color(0x082C2416), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            if (showDragHandle) ...[
              const Icon(Icons.drag_indicator, size: 18, color: AppColors.textPlaceholder),
              const SizedBox(width: 8),
            ],
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(_icon, size: 18, color: _color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.title, style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14,
                          color: AppColors.textPrimary,
                        ), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      if (item.cost != null && item.cost! > 0)
                        Text('¥${item.cost!.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  if (timeStr != null || item.location != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (timeStr != null) ...[
                          const Icon(Icons.access_time, size: 12, color: AppColors.textPlaceholder),
                          const SizedBox(width: 3),
                          Text(timeStr, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                        if (timeStr != null && item.location != null) const SizedBox(width: 12),
                        if (item.location != null) ...[
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textPlaceholder),
                          const SizedBox(width: 3),
                          Flexible(child: Text(item.location!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onEdit != null || onDelete != null) ...[
              const SizedBox(width: 4),
              if (onEdit != null)
                IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32), color: AppColors.textSecondary),
              if (onDelete != null)
                IconButton(onPressed: onDelete, icon: const Icon(Icons.close, size: 16), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32), color: AppColors.danger),
            ],
          ],
        ),
      ),
    );
  }
}
