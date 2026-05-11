import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

class WanderlogApp extends ConsumerWidget {
  const WanderlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Wanderlog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.notoSansScTextTheme(AppTheme.lightTheme.textTheme).copyWith(
          headlineLarge: GoogleFonts.notoSerifSc(
            fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.lightTheme.textTheme.headlineLarge?.color,
          ),
          headlineMedium: GoogleFonts.notoSerifSc(
            fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.lightTheme.textTheme.headlineMedium?.color,
          ),
          titleLarge: GoogleFonts.notoSerifSc(
            fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.lightTheme.textTheme.titleLarge?.color,
          ),
        ),
      ),
      routerConfig: router,
    );
  }
}
