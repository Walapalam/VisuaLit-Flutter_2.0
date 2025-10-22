import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/settings/presentation/widgets/hero_banner_widget.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  String _appVersion = '';
  String _buildNumber = '';
  bool _isLoading = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _loadPackageInfo();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
        _isLoading = false;
      });
      _controller.forward();
    }
  }

  Future<void> _launchUrl(String url) async {
    HapticFeedback.mediumImpact();
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open $url'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.brightness == Brightness.dark
                  ? theme.colorScheme.onBackground
                  : AppTheme.primaryGreen,
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

  Widget _buildContactTile({required IconData icon, required String title, required String url}) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
      child: InkWell(
        onTap: () => _launchUrl(url),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          const HeroBannerWidget(
            icon: Icons.info_outline,
            title: 'About VisuaLit',
            subtitle: 'Your AI Powered Ebook Reader',
          ),
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
              ),
            )
                : FadeTransition(
              opacity: _animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.1),
                  end: Offset.zero,
                ).animate(_animation),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // App Logo and Version
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? theme.colorScheme.surfaceContainerHighest
                                      : theme.colorScheme.surface,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  theme.brightness == Brightness.dark
                                      ? 'assets/images/AppLogo_Dark.png'
                                      : 'assets/images/AppLogo.png',
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'VisuaLit',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Version $_appVersion (Build $_buildNumber)',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.primaryGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Developer Section
                      _buildSectionHeader('About'),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGreen.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.auto_stories,
                                      color: AppTheme.primaryGreen,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'AI Powered Reading Experience',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'VisuaLit is developed by the VisuaLit Team, dedicated to making reading accessible to everyone through AI-powered innovations. Our app provides a seamless reading experience with advanced features for all types of readers.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Our technology enhances ebooks with visual aids, assists readers with dyslexia, and offers personalized reading recommendations.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Contact Section
                      _buildSectionHeader('Contact'),
                      _buildContactTile(
                        icon: Icons.language,
                        title: 'Visit our website',
                        url: 'https://www.visualit.live',
                      ),
                      _buildContactTile(
                        icon: Icons.email,
                        title: 'Send us an email',
                        url: 'mailto:contact@visualit.com',
                      ),
                      _buildContactTile(
                        icon: Icons.support_agent,
                        title: 'Contact support',
                        url: 'mailto:support@visualit.com',
                      ),

                      // Legal Section
                      _buildSectionHeader('Legal'),
                      Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Navigator.pushNamed(context, '/privacy-settings');
                              },
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.policy,
                                        color: AppTheme.primaryGreen,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Privacy Policy',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Divider(
                              height: 1,
                              thickness: 1,
                              indent: 16,
                              endIndent: 16,
                              color: theme.colorScheme.outline.withOpacity(0.2),
                            ),
                            InkWell(
                              onTap: () => _launchUrl('https://www.visualit.com/terms'),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(12),
                                bottomRight: Radius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryGreen.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.gavel,
                                        color: AppTheme.primaryGreen,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        'Terms of Service',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: 16,
                                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Footer
                      const SizedBox(height: 32),
                      Center(
                        child: Text(
                          '© 2025 VisuaLit. All rights reserved.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onBackground.withOpacity(0.6),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
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
