import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:archimate/core/routing/app_router.dart';
import 'package:archimate/presentation/theme/app_theme.dart';

/// Main application widget that configures the app theme and routing
class ArchimateApp extends ConsumerWidget {
  /// Creates an instance of [ArchimateApp]
  const ArchimateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: 'Archimate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
