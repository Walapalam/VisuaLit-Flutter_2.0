import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  // Data model for the FAQ section
  // We keep track of the expansion state using the 'isExpanded' boolean
  final List<FAQItem> _faqs = [
    FAQItem(
      question: "What is VisuaLit?",
      answer: "VisuaLit is the smartest reading assistant, which tailors your experience to your needs. To get started, simply download the VisuaLit app from the Apple Store or Google Play for free.",
      isExpanded: true, // Matches the screenshot
    ),
    FAQItem(
      question: "Why choose VisuaLit?",
      answer: "VisuaLit offers a comfortable, reliable, and accessible reading experience. Enhance your focus and comprehension with our specialized tools.",
    ),
    FAQItem(
      question: "What features are available?",
      answer: "We currently offer customizable fonts, text sizes, and color themes. Check the 'Settings' tab for all available options.",
    ),
    FAQItem(
      question: "How does text-to-speech work?",
      answer: "Our text-to-speech feature uses advanced synthesis to read text aloud, helping you to listen on the go.",
    ),
    FAQItem(
      question: "Is there a premium version?",
      answer: "Yes, all legal terms and conditions regarding usage and subscriptions are available in the 'Account' section of your profile.",
    ),
    FAQItem(
      question: "What if I have an issue?",
      answer: "If you encounter any problems, please contact support immediately via the button below or use the in-app feedback form.",
    ),
  ];

  /// Function to handle the "Send a message" action
  Future<void> _sendEmail() async {
    // The email address and subject
    final String email = "support@visualit.com";
    final String subject = "Help and Support Query";
    final String body = "Hello VisuaLit Support, \n\nI need help with...";

    // Constructing the mailto URI
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    // --- REAL IMPLEMENTATION (Requires url_launcher package) ---
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      // Fallback: Show a snackbar or alert if no email client is found
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Main Title
              Text(
                "We're here to help you with anything and everything on VisuaLit",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle Description
              Text(
                "At VisuaLit everything we expect at a day's start is you, better and happier than yesterday. We have got you covered. Share your concern or check our frequently asked questions listed below.",
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.5,
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 30),
              // FAQ Header
              Text(
                "FAQ",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // FAQ List Generation
              ..._faqs.asMap().entries.map((entry) {
                int idx = entry.key;
                FAQItem item = entry.value;
                return _buildExpansionTile(item, idx);
              }).toList(),

              // Spacing at the end of the list
              const SizedBox(height: 40),
              _buildContactSection(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile(FAQItem item, int index) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Theme(
        // Removes the default divider lines of ExpansionTile
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: EdgeInsets.zero,
          title: Text(
            item.question,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          // Custom trailing icon logic: X if expanded, + if collapsed
          trailing: Icon(
            item.isExpanded ? Icons.close : Icons.add,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          initiallyExpanded: item.isExpanded,
          onExpansionChanged: (bool expanded) {
            setState(() {
              item.isExpanded = expanded;
            });
          },
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                item.answer,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Still stuck? Help is a mail away",
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _sendEmail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            child: const Text(
              "Send a message",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Simple Data Model class for FAQ items
class FAQItem {
  final String question;
  final String answer;
  bool isExpanded;

  FAQItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
  });
}