import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/settings/presentation/widgets/hero_banner_widget.dart';
import 'package:visualit/features/settings/providers/settings_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _selectTime(BuildContext context, WidgetRef ref, bool isStartTime) async {
    final notificationSettings = ref.read(notificationSettingsProvider);
    final initialTime = isStartTime ? notificationSettings.quietHoursStart : notificationSettings.quietHoursEnd;

    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              dayPeriodBorderSide: const BorderSide(color: AppTheme.primaryGreen),
              dayPeriodColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? AppTheme.primaryGreen
                  : Theme.of(context).colorScheme.surface),
              dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface),
            ),
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      HapticFeedback.mediumImpact();
      if (isStartTime) {
        ref.read(notificationSettingsProvider.notifier).setQuietHoursStart(pickedTime);
      } else {
        ref.read(notificationSettingsProvider.notifier).setQuietHoursEnd(pickedTime);
      }
    }
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 24, bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 50,
            height: 3,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final frequencies = ['Every Hour', 'Daily', 'Weekly'];
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const HeroBannerWidget(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Customize your notification preferences',
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeOutCubic,
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // General notification settings
                      _buildSectionHeader(context, 'General'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: SwitchListTile(
                          title: Text('Enable Notifications',
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Receive important updates and information',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          secondary: Icon(Icons.notifications_active_outlined,
                            color: AppTheme.primaryGreen,
                          ),
                          value: notificationSettings.notificationsEnabled,
                          activeColor: AppTheme.primaryGreen,
                          activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                          onChanged: (bool value) {
                            HapticFeedback.lightImpact();
                            ref.read(notificationSettingsProvider.notifier).setNotificationsEnabled(value);
                          },
                        ),
                      ),

                      // Notification types
                      _buildSectionHeader(context, 'Notification Types'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text('Book Updates',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Get notified about updates to books in your library',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              secondary: Icon(Icons.book_outlined,
                                color: notificationSettings.notificationsEnabled
                                  ? AppTheme.primaryGreen
                                  : theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                              value: notificationSettings.bookUpdatesEnabled && notificationSettings.notificationsEnabled,
                              activeColor: AppTheme.primaryGreen,
                              activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                              onChanged: notificationSettings.notificationsEnabled
                                ? (bool value) {
                                    HapticFeedback.lightImpact();
                                    ref.read(notificationSettingsProvider.notifier).setBookUpdatesEnabled(value);
                                  }
                                : null,
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                            SwitchListTile(
                              title: Text('New Releases',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Receive alerts about new book releases',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              secondary: Icon(Icons.new_releases_outlined,
                                color: notificationSettings.notificationsEnabled
                                  ? AppTheme.primaryGreen
                                  : theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                              value: notificationSettings.newReleasesEnabled && notificationSettings.notificationsEnabled,
                              activeColor: AppTheme.primaryGreen,
                              activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                              onChanged: notificationSettings.notificationsEnabled
                                ? (bool value) {
                                    HapticFeedback.lightImpact();
                                    ref.read(notificationSettingsProvider.notifier).setNewReleasesEnabled(value);
                                  }
                                : null,
                            ),
                          ],
                        ),
                      ),

                      // Quiet hours
                      _buildSectionHeader(context, 'Quiet Hours'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text('Enable Quiet Hours',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Mute notifications during specified hours',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              secondary: Icon(Icons.nights_stay_outlined,
                                color: notificationSettings.notificationsEnabled
                                  ? AppTheme.primaryGreen
                                  : theme.colorScheme.onSurface.withOpacity(0.4),
                              ),
                              value: notificationSettings.quietHoursEnabled && notificationSettings.notificationsEnabled,
                              activeColor: AppTheme.primaryGreen,
                              activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                              onChanged: notificationSettings.notificationsEnabled
                                ? (bool value) {
                                    HapticFeedback.lightImpact();
                                    ref.read(notificationSettingsProvider.notifier).setQuietHoursEnabled(value);
                                  }
                                : null,
                            ),
                            if (notificationSettings.quietHoursEnabled && notificationSettings.notificationsEnabled)
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Divider(
                                      height: 16,
                                      thickness: 1,
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Text(
                                        'Choose when notifications should be silenced',
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Material(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(8),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () => _selectTime(context, ref, true),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('Start Time',
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.primaryGreen,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          _formatTimeOfDay(notificationSettings.quietHoursStart),
                                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Icon(Icons.access_time,
                                                          size: 18,
                                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Material(
                                            color: theme.colorScheme.surfaceContainerHighest,
                                            borderRadius: BorderRadius.circular(8),
                                            child: InkWell(
                                              borderRadius: BorderRadius.circular(8),
                                              onTap: () => _selectTime(context, ref, false),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('End Time',
                                                      style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontWeight: FontWeight.w500,
                                                        color: AppTheme.primaryGreen,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          _formatTimeOfDay(notificationSettings.quietHoursEnd),
                                                          style: theme.textTheme.bodyLarge?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        Icon(Icons.access_time,
                                                          size: 18,
                                                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Frequency
                      _buildSectionHeader(context, 'Frequency'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.tune,
                                    color: notificationSettings.notificationsEnabled
                                      ? AppTheme.primaryGreen
                                      : theme.colorScheme.onSurface.withOpacity(0.4),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'How often do you want to receive notifications?',
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: theme.colorScheme.outline.withOpacity(0.3),
                                  ),
                                ),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                  dropdownColor: theme.colorScheme.surface,
                                  value: notificationSettings.notificationFrequency,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  style: theme.textTheme.bodyLarge,
                                  onChanged: notificationSettings.notificationsEnabled
                                      ? (String? value) {
                                          if (value != null) {
                                            HapticFeedback.lightImpact();
                                            ref.read(notificationSettingsProvider.notifier).setNotificationFrequency(value);
                                          }
                                        }
                                      : null,
                                  items: frequencies.map((String frequency) {
                                    return DropdownMenuItem<String>(
                                      value: frequency,
                                      child: Text(frequency),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Actions
                      _buildSectionHeader(context, 'Actions'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.notifications_active),
                                      label: const Text('Test Notification'),
                                      onPressed: notificationSettings.notificationsEnabled
                                          ? () {
                                              HapticFeedback.mediumImpact();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Test notification sent!'),
                                                  duration: const Duration(seconds: 2),
                                                  backgroundColor: AppTheme.primaryGreen,
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryGreen,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: theme.colorScheme.surfaceVariant,
                                        disabledForegroundColor: theme.colorScheme.onSurface.withOpacity(0.38),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Clear History'),
                                      onPressed: notificationSettings.notificationsEnabled
                                          ? () {
                                              HapticFeedback.mediumImpact();
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: const Text('Notification history cleared'),
                                                  duration: const Duration(seconds: 2),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                              );
                                            }
                                          : null,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primaryGreen,
                                        side: BorderSide(
                                          color: notificationSettings.notificationsEnabled
                                            ? AppTheme.primaryGreen
                                            : theme.colorScheme.outline.withOpacity(0.3),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
