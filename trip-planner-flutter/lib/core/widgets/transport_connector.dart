import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';
import '../../models/transport.dart';

class TransportConnector extends StatelessWidget {
  final Transport transport;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransportConnector({super.key, required this.transport, this.onTap, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final typeLabel = AppConstants.transportTypeLabels[transport.transportType] ?? transport.transportType;
    final color = AppColors.transportColor(transport.transportType);
    final routeText = _buildRouteText();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 20, height: 20,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: Center(child: Text(_transportIcon(transport.transportType), style: const TextStyle(fontSize: 10))),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(typeLabel, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
                      if (transport.estimatedDuration != null) ...[
                        const SizedBox(width: 8),
                        Text('${transport.estimatedDuration}分钟', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                      ],
                    ],
                  ),
                  if (routeText != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(routeText, style: const TextStyle(fontSize: 10, color: AppColors.textPlaceholder)),
                    ),
                ],
              ),
            ),
            if (onDelete != null)
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.close, size: 14, color: AppColors.textPlaceholder),
              ),
          ],
        ),
      ),
    );
  }

  String? _buildRouteText() {
    if (transport.departureStation != null && transport.arrivalStation != null) {
      return '${transport.departureStation} → ${transport.arrivalStation}';
    }
    if (transport.transportNumber != null) {
      return transport.transportNumber!;
    }
    if (transport.routeInfo != null) {
      return transport.routeInfo!;
    }
    return null;
  }

  String _transportIcon(String type) {
    return switch (type) {
      'WALK' => '🚶', 'BUS' => '🚌', 'SUBWAY' => '🚇', 'TAXI' => '🚕',
      'RIDE_HAIL' => '🚗', 'SELF_DRIVE' => '🚙', 'BIKE' => '🚲',
      'FLIGHT' => '✈️', 'TRAIN' => '🚄', _ => '➡️',
    };
  }
}
