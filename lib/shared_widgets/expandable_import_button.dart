import 'package:flutter/material.dart';
import 'package:visualit/core/theme/app_theme.dart';

class ExpandableImportButton extends StatefulWidget {
  final VoidCallback onImportBook;
  final VoidCallback onImportFolder;

  const ExpandableImportButton({
    super.key,
    required this.onImportBook,
    required this.onImportFolder,
  });

  @override
  State<ExpandableImportButton> createState() => _ExpandableImportButtonState();
}

class _ExpandableImportButtonState extends State<ExpandableImportButton>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Button
        GestureDetector(
          onTap: _toggleExpanded,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGreen.withOpacity(0.2),
                  AppTheme.primaryGreen.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isExpanded ? Icons.close : Icons.add_circle_outline,
                  color: AppTheme.primaryGreen,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Import New Books',
                  style: TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Expandable Options
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isExpanded ? 120 : 0,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: _isExpanded ? 1.0 : 0.0,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        // Import Single Book
                        _buildOption(
                          icon: Icons.book_outlined,
                          label: 'Import Single Book',
                          onTap: () {
                            _toggleExpanded();
                            widget.onImportBook();
                          },
                        ),
                        const SizedBox(height: 8),
                        // Import Folder
                        _buildOption(
                          icon: Icons.folder_outlined,
                          label: 'Import from Folder',
                          onTap: () {
                            _toggleExpanded();
                            widget.onImportFolder();
                          },
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryGreen.withOpacity(0.8), size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: AppTheme.primaryGreen.withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
