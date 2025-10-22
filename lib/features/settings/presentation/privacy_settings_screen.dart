import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/settings/presentation/widgets/hero_banner_widget.dart';
import 'package:visualit/features/settings/providers/settings_providers.dart';
import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  // Function to load privacy policy from markdown file
  Future<String> _loadPrivacyPolicy(BuildContext context) async {
    return await rootBundle.loadString('lib/features/settings/data/privacyPolicy.md');
  }

  // Show privacy policy dialog
  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);

        return FutureBuilder<String>(
          future: _loadPrivacyPolicy(context),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: Text("Privacy Policy", style: theme.textTheme.headlineMedium),
                content: const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator(
                    color: AppTheme.primaryGreen,
                  )),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: Text("Error", style: theme.textTheme.headlineMedium),
                content: Text(
                  "Failed to load privacy policy: ${snapshot.error}",
                  style: theme.textTheme.bodyMedium,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryGreen,
                    ),
                    child: const Text("Close"),
                  ),
                ],
              );
            } else {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.primaryGreen, AppTheme.black],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.policy, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            "Privacy Policy",
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: Container(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.7,
                          maxWidth: MediaQuery.of(context).size.width * 0.9,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: MarkdownBody(
                            data: snapshot.data!,
                            styleSheet: MarkdownStyleSheet(
                              h1: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                              h2: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                              p: theme.textTheme.bodyMedium,
                              strong: const TextStyle(fontWeight: FontWeight.bold),
                              a: TextStyle(color: AppTheme.primaryGreen),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text("Close"),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
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
    // Watch the initializer to ensure SharedPreferences is loaded
    final initializerState = ref.watch(settingsInitializerProvider);
    final privacySettings = ref.watch(privacySettingsProvider);
    final theme = Theme.of(context);

    // Show loading state if preferences are still initializing
    if (initializerState is AsyncLoading) {
      return Scaffold(
        body: Column(
          children: [
            const HeroBannerWidget(
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              subtitle: 'Manage your data and privacy preferences',
            ),
            Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Show error state if initialization failed
    if (initializerState is AsyncError) {
      return Scaffold(
        body: Column(
          children: [
            const HeroBannerWidget(
              icon: Icons.privacy_tip,
              title: 'Privacy Settings',
              subtitle: 'Manage your data and privacy preferences',
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load settings',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(settingsInitializerProvider);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Main content when preferences are loaded successfully
    return Scaffold(
      body: Column(
        children: [
          const HeroBannerWidget(
            icon: Icons.privacy_tip,
            title: 'Privacy Settings',
            subtitle: 'Manage your data and privacy preferences',
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
                      // Data Collection Section
                      _buildSectionHeader(context, 'Data Collection'),
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
                              title: Text('Analytics',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Allow us to collect app usage data to improve our services',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              secondary: Icon(Icons.analytics_outlined,
                                color: AppTheme.primaryGreen,
                              ),
                              value: privacySettings.analyticsEnabled,
                              activeColor: AppTheme.primaryGreen,
                              activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                              onChanged: (bool value) {
                                HapticFeedback.lightImpact();
                                ref.read(privacySettingsProvider.notifier).setAnalytics(value);
                              },
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                            SwitchListTile(
                              title: Text('Crash Reporting',
                                style: theme.textTheme.bodyLarge,
                              ),
                              subtitle: Text(
                                'Send crash reports to help us fix issues',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                              secondary: Icon(Icons.bug_report_outlined,
                                color: AppTheme.primaryGreen,
                              ),
                              value: privacySettings.crashReportingEnabled,
                              activeColor: AppTheme.primaryGreen,
                              activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                              onChanged: (bool value) {
                                HapticFeedback.lightImpact();
                                ref.read(privacySettingsProvider.notifier).setCrashReporting(value);
                              },
                            ),
                          ],
                        ),
                      ),

                      // Personalization Section
                      _buildSectionHeader(context, 'Personalization'),
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        color: theme.colorScheme.surface,
                        child: SwitchListTile(
                          title: Text('Personalized Experience',
                            style: theme.textTheme.bodyLarge,
                          ),
                          subtitle: Text(
                            'Allow us to use your reading habits to personalize recommendations',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          secondary: Icon(Icons.person_outline,
                            color: AppTheme.primaryGreen,
                          ),
                          value: privacySettings.personalizationEnabled,
                          activeColor: AppTheme.primaryGreen,
                          activeTrackColor: AppTheme.primaryGreen.withOpacity(0.5),
                          onChanged: (bool value) {
                            HapticFeedback.lightImpact();
                            ref.read(privacySettingsProvider.notifier).setPersonalization(value);
                          },
                        ),
                      ),

                      // Privacy Policy Button
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.policy),
                            label: const Text('View Privacy Policy'),
                            onPressed: () => _showPrivacyPolicy(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ),

                      // Privacy Information
                      Card(
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.shield,
                                    color: AppTheme.primaryGreen,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Your Privacy Matters',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'You can request deletion of your data at any time by contacting our support team. '
                                'We are committed to protecting your privacy and providing a secure reading experience.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
