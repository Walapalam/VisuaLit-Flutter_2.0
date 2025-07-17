import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/router/app_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/core/theme/theme_controller.dart';

Future<void> main() async {
  // Set up error handling for the entire app
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint("[FATAL] Uncaught Flutter error: ${details.exception}");
    debugPrintStack(stackTrace: details.stack);
  };

  // Handle errors that occur during async operations
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint("[FATAL] Uncaught platform error: $error");
    debugPrintStack(stackTrace: stack);
    return true;
  };

  debugPrint("[DEBUG] VisuaLit: Application starting");

  try {
    debugPrint("[DEBUG] VisuaLit: Initializing Flutter binding");
    WidgetsFlutterBinding.ensureInitialized();

    debugPrint("[DEBUG] VisuaLit: Loading environment variables");
    try {
      await dotenv.load(fileName: ".env");
      debugPrint("[DEBUG] VisuaLit: Environment variables loaded successfully");
    } catch (e) {
      debugPrint("[ERROR] VisuaLit: Failed to load environment variables: $e");
      debugPrint("[WARN] VisuaLit: Continuing without environment variables");
    }

    debugPrint("[DEBUG] VisuaLit: Starting application");
    runApp(const ProviderScope(
      child: MyApp(),
    ));
    debugPrint("[DEBUG] VisuaLit: Application started successfully");
  } catch (e, stack) {
    debugPrint("[FATAL] VisuaLit: Error during application startup: $e");
    debugPrintStack(stackTrace: stack);
    rethrow; // Rethrow to let the platform handle the error
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint("[DEBUG] MyApp: Building application");

    try {
      final router = ref.watch(goRouterProvider);
      final themeMode = ref.watch(themeControllerProvider);

      debugPrint("[DEBUG] MyApp: Theme mode: $themeMode");

      return MaterialApp.router(
        title: 'VisuaLit',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          // Add error handling for widgets
          ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
            debugPrint("[ERROR] Widget error: ${errorDetails.exception}");
            return Material(
              color: Colors.red.shade100,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'An error occurred: ${errorDetails.exception}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            );
          };

          return child ?? const SizedBox.shrink();
        },
      );
    } catch (e, stack) {
      debugPrint("[ERROR] MyApp: Error building application: $e");
      debugPrintStack(stackTrace: stack);

      // Return a fallback UI in case of error
      return MaterialApp(
        title: 'VisuaLit - Error',
        home: Scaffold(
          body: Center(
            child: Text(
              'Failed to initialize application: $e',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }
  }
}
