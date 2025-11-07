// lib/features/audiobook_player/presentation/widgets/player_bottom_tabs.dart

import 'package:flutter/material.dart';

// --- SELF-CONTAINED WIDGET FOR THE ANIMATED BOTTOM TABS ---
class PlayerBottomTabs extends StatefulWidget {
  final VoidCallback onChaptersTap;
  final VoidCallback onReadTap;
  final VoidCallback onVisualizeTap;
  final int initialIndex;
  final Color accentColor;

  const PlayerBottomTabs({
    super.key,
    this.initialIndex = 0,
    required this.accentColor,
    required this.onChaptersTap,
    required this.onReadTap,
    required this.onVisualizeTap,
  });

  @override
  State<PlayerBottomTabs> createState() => _PlayerBottomTabsState();
}

class _PlayerBottomTabsState extends State<PlayerBottomTabs> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onTabTapped(int index) {
    if (index == 0) { widget.onChaptersTap(); }
    else if (index == 1) { widget.onReadTap(); }
    else if (index == 2) { widget.onVisualizeTap(); }
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => _onTabTapped(index),
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text.toUpperCase(),
              style: TextStyle(
                color: isSelected ? widget.accentColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: isSelected ? 30 : 0,
              decoration: BoxDecoration(
                color: widget.accentColor,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTab(0, "CHAPTERS"),
        _buildTab(1, "READ"),
        _buildTab(2, "VISUALIZE"),
      ],
    );
  }
}
