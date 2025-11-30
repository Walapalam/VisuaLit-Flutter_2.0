import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:visualit/shared_widgets/streak_widget.dart';

class HomeGreetingHeader extends ConsumerWidget {
  const HomeGreetingHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;
    final firstName = user?.displayName?.split(' ').first ?? 'Reader';
    final displayName = firstName.isEmpty ? 'Reader' : firstName;

    // Greeting Logic
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 2 && hour < 5) {
      greeting = 'No Sleep? 😴';
    } else if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              greeting,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            Text(
              displayName,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Streak Widget instead of profile icon
        const StreakWidget(),
      ],
    );
  }
}
