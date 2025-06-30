import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF2ECC71).withOpacity(0.7),
              Theme.of(context).scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/AppLogo.png', height: 100),
                const SizedBox(height: 24),
                Text(
                  'VisuaLit',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(220, 48),
                  ),
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).signInAsGuest();
                    context.go('/preferences');
                  },
                  child: const Text('Start Reading as Guest'),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2ECC71),
                    side: const BorderSide(color: Color(0xFF2ECC71)),
                    minimumSize: const Size(220, 48),
                  ),
                  onPressed: () {
                    context.goNamed('login', extra: false);
                  },
                  child: const Text('Continue with an Account'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}