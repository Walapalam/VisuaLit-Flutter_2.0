import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/router/app_router.dart';
import 'package:visualit/core/services/isar_service.dart';
import 'package:visualit/core/services/sync_lifecycle_observer.dart';
import 'package:visualit/core/services/sync_service.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/theme/theme_controller.dart';
import 'package:visualit/core/providers/isar_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Initialize Isar DB before app start
  final isarService = IsarService();
  await isarService.db;

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isarService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);

    // Observe app lifecycle to trigger background syncs
    ref.watch(syncLifecycleObserverProvider);

    // Trigger initial sync after app starts
    Future.delayed(const Duration(seconds: 2), () {
      ref.read(syncProvider.future).catchError((e) {
        debugPrint('Initial sync error: $e');
      });
    });

    return MaterialApp.router(
      title: 'VisuaLit',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
