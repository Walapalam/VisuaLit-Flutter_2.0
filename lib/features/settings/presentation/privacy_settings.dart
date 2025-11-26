import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class PrivacySettingsScreen extends StatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PolicySectionData {
  final String title;
  final String content;
  _PolicySectionData(this.title, this.content);
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late Future<List<_PolicySectionData>> _policyFuture;
  String _mainTitle = "Privacy Policy";
  String _lastUpdated = "";

  @override
  void initState() {
    super.initState();
    _policyFuture = _loadAndParsePolicy();
  }

  Future<List<_PolicySectionData>> _loadAndParsePolicy() async {
    final rawText = await rootBundle.loadString(
      'lib/features/settings/data/privacyPolicy.md',
    );
    final lines = rawText.split('\n');

    if (mounted) {
      setState(() {
        _mainTitle = lines.isNotEmpty ? lines.first.trim() : "Privacy Policy";
        _lastUpdated = lines.length > 1 ? lines[1].trim() : "";
      });
    }

    final List<_PolicySectionData> sections = [];
    StringBuffer currentContent = StringBuffer();
    String? currentTitle;

    // Start parsing after the header
    for (int i = 2; i < lines.length; i++) {
      String line = lines[i]; // Use untrimmed line to preserve formatting
      // Regex to find section titles like "1. Data We Collect"
      final titleMatch = RegExp(r'^\d+\.\s+(.+)').firstMatch(line.trim());

      if (titleMatch != null) {
        // If we have content for the previous section, save it
        if (currentTitle != null &&
            currentContent.toString().trim().isNotEmpty) {
          sections.add(
            _PolicySectionData(currentTitle, currentContent.toString().trim()),
          );
        }
        // Start a new section
        currentTitle = titleMatch.group(1)!.trim();
        currentContent = StringBuffer();
      } else if (currentTitle != null) {
        // Add line to the content of the current section
        currentContent.writeln(line);
      }
    }

    // Add the last section
    if (currentTitle != null && currentContent.toString().trim().isNotEmpty) {
      sections.add(
        _PolicySectionData(currentTitle, currentContent.toString().trim()),
      );
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy'), elevation: 0),
      body: FutureBuilder<List<_PolicySectionData>>(
        future: _policyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text("Could not load privacy policy."));
          }

          final sections = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            children: [
              Text(
                _mainTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _lastUpdated,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 24),
              ...sections.map(
                (section) => _PolicySection(
                  title: section.title,
                  content: section.content,
                ),
              ),
              const SizedBox(height: 30),
            ],
          );
        },
      ),
    );
  }
}

class _PolicySection extends StatefulWidget {
  final String title;
  final String content;

  const _PolicySection({required this.title, required this.content});

  @override
  State<_PolicySection> createState() => _PolicySectionState();
}

class _PolicySectionState extends State<_PolicySection> {
  bool _isExpanded = false;
  static const int _trimLength = 250; // Character limit before "See more"

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isLongText = widget.content.length > _trimLength;

    String displayedContent;
    if (isLongText && !_isExpanded) {
      int lastSpace = widget.content.lastIndexOf(' ', _trimLength);
      displayedContent =
          '${widget.content.substring(0, lastSpace != -1 ? lastSpace : _trimLength)}...';
    } else {
      displayedContent = widget.content;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          MarkdownBody(
            data: displayedContent,
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: theme.colorScheme.onSurface.withOpacity(0.8),
              ),
            ),
          ),
          if (isLongText) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Text(
                  _isExpanded ? "See less" : "See more",
                  style: const TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }
}
