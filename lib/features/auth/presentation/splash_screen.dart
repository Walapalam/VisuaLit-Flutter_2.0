import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Add a small delay to show splash screen briefly
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; // Check if widget is still mounted
      try {
        await ref.read(authControllerProvider.notifier).initialize();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to initialize app'),
            backgroundColor: AppTheme.grey,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/AppLogo.png', height: 100), // Ensure this asset exists
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: AppTheme.primaryGreen),
            const SizedBox(height: 20),
            const Text('Connecting to services...', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}