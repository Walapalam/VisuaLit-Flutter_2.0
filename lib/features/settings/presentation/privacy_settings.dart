import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacySettingsScreen extends StatelessWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        centerTitle: true,
        elevation: 0,
      ),
      body: FutureBuilder<String>(
        future: rootBundle.loadString('lib/features/settings/data/privacyPolicy.md'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading Privacy Policy...'),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading privacy policy',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please try again later',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No privacy policy available',
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildPrivacyContent(context, snapshot.data!),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip,
              color: theme.colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Privacy Matters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Learn how we protect your data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent(BuildContext context, String content) {
    final theme = Theme.of(context);
    final lines = content.split('\n');
    final List<Widget> widgets = [];

    String currentSection = '';
    List<String> currentSectionContent = [];

    for (var line in lines) {
      line = line.trim();

      if (line.isEmpty) continue;

      // Check if it's a main section (numbered)
      if (RegExp(r'^\d+\.').hasMatch(line)) {
        // Add previous section if exists
        if (currentSection.isNotEmpty) {
          widgets.add(_buildSection(
            context,
            currentSection,
            currentSectionContent.join('\n'),
          ));
          widgets.add(const SizedBox(height: 16));
        }

        currentSection = line;
        currentSectionContent = [];
      } else if (line.startsWith('VisuaLit Privacy Policy')) {
        // Title
        widgets.add(_buildTitle(context, line));
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('Last Updated:')) {
        // Last updated date
        widgets.add(_buildLastUpdated(context, line));
        widgets.add(const SizedBox(height: 24));
      } else {
        currentSectionContent.add(line);
      }
    }

    // Add last section
    if (currentSection.isNotEmpty) {
      widgets.add(_buildSection(
        context,
        currentSection,
        currentSectionContent.join('\n'),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTitle(BuildContext context, String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildLastUpdated(BuildContext context, String date) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        date,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    final theme = Theme.of(context);

    // Extract section number and title
    final match = RegExp(r'^(\d+)\.\s*(.+)$').firstMatch(title);
    final sectionNumber = match?.group(1) ?? '';
    final sectionTitle = match?.group(2) ?? title;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Theme(
        data: theme.copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                sectionNumber,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          title: Text(
            sectionTitle,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          children: [
            _buildSectionContent(context, content),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContent(BuildContext context, String content) {
    final theme = Theme.of(context);
    final lines = content.split('\n');
    final List<Widget> contentWidgets = [];

    String currentSubsection = '';
    List<String> currentSubsectionItems = [];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      if (line.endsWith(':') && !line.startsWith('-')) {
        // Subsection header
        if (currentSubsection.isNotEmpty) {
          contentWidgets.add(_buildSubsection(
            context,
            currentSubsection,
            currentSubsectionItems,
          ));
          contentWidgets.add(const SizedBox(height: 12));
        }
        currentSubsection = line;
        currentSubsectionItems = [];
      } else {
        currentSubsectionItems.add(line);
      }
    }

    // Add last subsection
    if (currentSubsection.isNotEmpty) {
      contentWidgets.add(_buildSubsection(
        context,
        currentSubsection,
        currentSubsectionItems,
      ));
    } else if (currentSubsectionItems.isNotEmpty) {
      // No subsections, just content
      contentWidgets.add(_buildParagraph(context, currentSubsectionItems.join(' ')));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentWidgets,
    );
  }

  Widget _buildSubsection(BuildContext context, String header, List<String> items) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: _buildParagraph(context, item),
        )),
      ],
    );
  }

  Widget _buildParagraph(BuildContext context, String text) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (text.startsWith('-'))
          Padding(
            padding: const EdgeInsets.only(right: 8, top: 6),
            child: Icon(
              Icons.circle,
              size: 6,
              color: theme.colorScheme.primary,
            ),
          ),
        Expanded(
          child: Text(
            text.startsWith('-') ? text.substring(1).trim() : text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
