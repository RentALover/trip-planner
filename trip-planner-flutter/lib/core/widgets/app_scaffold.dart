import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../router/route_names.dart';

class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int index) => state = index;
}

final selectedNavIndexProvider = NotifierProvider<NavIndexNotifier, int>(NavIndexNotifier.new);

class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    // Only show bottom nav on main tabs
    final showBottomNav = location == RoutePaths.home ||
        location == RoutePaths.profile ||
        location == RoutePaths.photoAlbum;
    final currentIndex = ref.watch(selectedNavIndexProvider);

    return Scaffold(
      body: child,
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(selectedNavIndexProvider.notifier).set(index);
                  switch (index) {
                    case 0:
                      context.go(RoutePaths.home);
                      break;
                    case 1:
                      context.go(RoutePaths.photoAlbum);
                      break;
                    case 2:
                      context.go(RoutePaths.profile);
                      break;
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore),
                    label: '我的行程',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.photo_library_outlined),
                    activeIcon: Icon(Icons.photo_library),
                    label: '旅行相册',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: '我的',
                  ),
                ],
              ),
            )
          : null,
    );
  }
}
