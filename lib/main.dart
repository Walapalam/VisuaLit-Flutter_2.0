import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/router/app_router.dart';
import 'package:visualit/core/services/sync_lifecycle_observer.dart';
import 'package:visualit/core/services/sync_service.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/theme/theme_controller.dart';


import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    final themeMode = ref.watch(themeControllerProvider);

    // Initialize sync lifecycle observer
    // This will trigger sync when app lifecycle changes
    ref.watch(syncLifecycleObserverProvider);

    // Trigger initial sync when app starts
    // Use a delayed future to ensure the app is fully initialized
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
