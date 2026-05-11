import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'route_names.dart';
import '../constants/storage_keys.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/register_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/trip/trip_create_screen.dart';
import '../../screens/trip/trip_detail_screen.dart';
import '../../screens/trip/trip_edit_screen.dart';
import '../../screens/planner/planner_screen.dart';
import '../../screens/budget/budget_screen.dart';
import '../../screens/checklist/checklist_screen.dart';
import '../../screens/journal/journal_screen.dart';
import '../../screens/photos/trip_photos_screen.dart';
import '../../screens/photos/photo_album_screen.dart';
import '../../screens/map/map_screen.dart';
import '../../screens/export/export_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/edit_profile_screen.dart';
import '../widgets/app_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RoutePaths.home,
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(StorageKeys.token);
      final isLoggedIn = token != null && token.isNotEmpty;
      final isPublic = state.matchedLocation == RoutePaths.login ||
          state.matchedLocation == RoutePaths.register;

      if (!isLoggedIn && !isPublic) return RoutePaths.login;
      if (isLoggedIn && isPublic) return RoutePaths.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: RoutePaths.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: RoutePaths.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: RoutePaths.editProfile,
            builder: (context, state) => const EditProfileScreen(),
          ),
          GoRoute(
            path: RoutePaths.tripCreate,
            builder: (context, state) => const TripCreateScreen(),
          ),
          GoRoute(
            path: RoutePaths.tripDetail,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripDetailScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.tripEdit,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripEditScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.planner,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return PlannerScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.budget,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return BudgetScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.checklist,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return ChecklistScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.tripPhotos,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return TripPhotosScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.map,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return MapScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.export,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              return ExportScreen(tripId: tripId);
            },
          ),
          GoRoute(
            path: RoutePaths.journal,
            builder: (context, state) {
              final tripId = int.parse(state.pathParameters['tripId']!);
              final dayId = int.parse(state.pathParameters['dayId']!);
              return JournalScreen(tripId: tripId, dayId: dayId);
            },
          ),
          GoRoute(
            path: RoutePaths.photoAlbum,
            builder: (context, state) => const PhotoAlbumScreen(),
          ),
        ],
      ),
    ],
  );
});
