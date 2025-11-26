import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/services/notification_service.dart';
import 'notification_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final marketingEnabled = ref.watch(notificationControllerProvider);
    final accountAlertsEnabled = ref.watch(accountAlertsProvider);
    final generalNotificationsEnabled = ref.watch(generalNotificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Notification Settings"), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NotificationToggleCard(
            title: "Marketing Alerts",
            description:
                "Receive updates on new features, tips, and special offers from the VisuaLit team.",
            value: marketingEnabled,
            onChanged: (val) {
              ref
                  .read(notificationControllerProvider.notifier)
                  .toggleNotifications(val);
            },
          ),
          const SizedBox(height: 16),
          _NotificationToggleCard(
            title: "Account Related Alerts",
            description:
                "Get important notifications about your account security and subscription status.",
            value: accountAlertsEnabled,
            onChanged: (val) {
              ref.read(accountAlertsProvider.notifier).toggle(val);
            },
          ),
          const SizedBox(height: 16),
          _NotificationToggleCard(
            title: "General App Functions",
            description:
                "Receive alerts for core app functions like sync completion or storage warnings.",
            value: generalNotificationsEnabled,
            onChanged: (val) {
              ref.read(generalNotificationsProvider.notifier).toggle(val);
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationServiceProvider).showTestNotification();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Test notification sent!')),
                );
              },
              icon: const Icon(Icons.notifications_active),
              label: const Text('Test Notification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleCard extends StatelessWidget {
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationToggleCard({
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
