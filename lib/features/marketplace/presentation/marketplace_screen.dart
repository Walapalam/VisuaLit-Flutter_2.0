import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';

class MarketplaceScreen extends ConsumerWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    if (authState.status == AuthStatus.unauthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Marketplace')),
        body: const Center(
          child: Text('Please log in to access the marketplace.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Marketplace')),
      body: const Center(
        child: Text('Marketplace Content Goes Here'),
      ),
    );
  }
}