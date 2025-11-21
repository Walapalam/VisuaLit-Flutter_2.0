import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/providers/theme_provider.dart';
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

  runApp(const ProviderScope(child: MyApp()));
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
