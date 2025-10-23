import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart'; // Added this import for alternative approach
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/settings/presentation/widgets/hero_banner_widget.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // Updated email launch method with error handling and alternative approaches
  Future<void> _launchEmail(String subject, BuildContext context) async {
    final String emailAddress = 'visualitapp@gmail.com';
    final String emailSubject = Uri.encodeComponent(subject);
    final String emailUrl = 'mailto:$emailAddress?subject=$emailSubject';

    try {
      final Uri emailUri = Uri.parse(emailUrl);
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // Fallback to string-based launch
        if (await canLaunchUrlString(emailUrl)) {
          await launchUrlString(emailUrl);
        } else {
          // Show snackbar if both methods fail
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Could not open email client. Please email visualitapp@gmail.com directly.'),
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error launching email: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Help & Support'),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24.0),
        children: [
          // Hero Banner
          const HeroBannerWidget(
            icon: Icons.support_agent,
            title: 'Help & Support',
            subtitle: 'Get assistance, report issues, or send feedback',
          ),
          const SizedBox(height: 24),

          // FAQs Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    _buildFaqItem(
                      context,
                      'How do I import a book?',
                      'You can import books by going to Library > "+" button > "Import from Device" and selecting your EPUB or PDF files.',
                    ),
                    _buildFaqItem(
                      context,
                      'How do I change the reading font?',
                      'In Settings > Preferences > Font Style, you can select from various font options including dyslexia-friendly fonts.',
                    ),
                    _buildFaqItem(
                      context,
                      'Can I listen to my books offline?',
                      'Yes! Downloaded audiobooks are available offline. Make sure to download them while connected to the internet.',
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Contact Us Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Get in Touch',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: Icon(Icons.email_outlined, color: AppTheme.primaryGreen),
                      title: const Text('Contact Support'),
                      subtitle: const Text('visualitapp@gmail.com'),
                      onTap: () => _launchEmail('Support Request', context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.bug_report_outlined, color: AppTheme.primaryGreen),
                      title: const Text('Report a Bug'),
                      onTap: () => _launchEmail('Bug Report', context),
                    ),
                    const Divider(),
                    ListTile(
                      leading: Icon(Icons.lightbulb_outline, color: AppTheme.primaryGreen),
                      title: const Text('Suggest a Feature'),
                      onTap: () => _launchEmail('Feature Request', context),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(BuildContext context, String question, String answer) {
    return ExpansionTile(
      leading: Icon(Icons.question_answer_outlined, color: AppTheme.primaryGreen),
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
          child: Text(
            answer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
