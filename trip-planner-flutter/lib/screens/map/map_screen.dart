import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/loading_widget.dart';
import '../../core/widgets/app_error_widget.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../models/geo_item.dart';
import '../../services/geo_service.dart';

final geoItemsProvider = FutureProvider.family<List<GeoItem>, int>((ref, tripId) {
  return ref.read(geoServiceProvider).geocode(tripId);
});

class MapScreen extends ConsumerStatefulWidget {
  final int tripId;
  const MapScreen({super.key, required this.tripId});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapCtrl = MapController();

  static const _markerColors = {
    'DESTINATION': Color(0xFFC47B5A),
    'ATTRACTION': Color(0xFFB8453E),
    'DINING': Color(0xFFC4963E),
    'ACCOMMODATION': Color(0xFF7B8C4E),
    'TRANSPORT': Color(0xFF3D6B6B),
    'SHOPPING': Color(0xFF6B7D8B),
  };

  static const _markerIcons = {
    'DESTINATION': Icons.flag,
    'ATTRACTION': Icons.attractions,
    'DINING': Icons.restaurant,
    'ACCOMMODATION': Icons.hotel,
    'TRANSPORT': Icons.directions_bus,
    'SHOPPING': Icons.shopping_bag,
  };

  @override
  Widget build(BuildContext context) {
    final geoAsync = ref.watch(geoItemsProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('行程地图')),
      body: geoAsync.when(
        loading: () => const LoadingWidget(message: '加载地图数据...'),
        error: (e, _) => AppErrorWidget(message: '$e', onRetry: () => ref.invalidate(geoItemsProvider(widget.tripId))),
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(icon: Icons.map_outlined, title: '没有可展示的地点', subtitle: '为行程项添加地点后可在地图上查看');
          }

          final points = items.map((i) => LatLng(i.lat, i.lng)).toList();
          final bounds = LatLngBounds.fromPoints(points);

          return Column(
            children: [
              Expanded(
                child: FlutterMap(
                  mapController: _mapCtrl,
                  options: MapOptions(
                    initialCenter: bounds.center,
                    initialZoom: 5.0,
                    initialCameraFit: CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(40)),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                      userAgentPackageName: 'com.tripplanner.wanderlog',
                    ),
                    MarkerLayer(
                      markers: items.map((item) {
                        final color = _markerColors[item.itemType] ?? AppColors.textSecondary;
                        return Marker(
                          point: LatLng(item.lat, item.lng),
                          width: 32,
                          height: 32,
                          child: GestureDetector(
                            onTap: () => _showPopup(context, item),
                            child: Container(
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                              ),
                              child: Icon(_markerIcons[item.itemType] ?? Icons.place, size: 16, color: Colors.white),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('CARTO', onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
              // Legend
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(spacing: 14, runSpacing: 6, children: [
                  _legendDot(const Color(0xFFC47B5A), '目的地'),
                  _legendDot(const Color(0xFFB8453E), '景点'),
                  _legendDot(const Color(0xFFC4963E), '餐饮'),
                  _legendDot(const Color(0xFF7B8C4E), '住宿'),
                  _legendDot(const Color(0xFF3D6B6B), '交通'),
                  _legendDot(const Color(0xFF6B7D8B), '购物'),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  void _showPopup(BuildContext context, GeoItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item.title),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _infoRow(Icons.location_on, item.location),
          const SizedBox(height: 4),
          _infoRow(Icons.calendar_today, 'Day ${item.dayNumber}'),
        ]),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 6),
      Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textRegular)),
    ]);
  }
}
