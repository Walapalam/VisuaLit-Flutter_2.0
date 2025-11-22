import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize Notification Service
  final container = ProviderContainer();
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.init();

  // Subscribe to topic on startup if enabled
  final prefs = await SharedPreferences.getInstance();
  final bool notificationsEnabled = prefs.getBool('marketing_notifications_enabled') ?? true;
  if (notificationsEnabled) {
    await notificationService.subscribeToTopic('all_users');
  }

  final token = await FirebaseMessaging.instance.getToken();
  print('FCM TOKEN: $token');


  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return MaterialApp.router(
      title: 'VisuaLit',
      theme: AppTheme.lightTheme(
        fontFamily: themeState.fontFamily,
        fontSize: themeState.fontSize,
      ),
      darkTheme: AppTheme.darkTheme(
        fontFamily: themeState.fontFamily,
        fontSize: themeState.fontSize,
      ),
      themeMode: themeState.themeMode,
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
    );
  }
}
