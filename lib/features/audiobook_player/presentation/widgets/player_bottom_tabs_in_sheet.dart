// lib/features/audiobook_player/presentation/widgets/player_bottom_tabs_in_sheet.dart

import 'package:flutter/material.dart';

// --- DEDICATED TAB WIDGET for use *inside* the bottom sheet ---
class PlayerBottomTabsInSheet extends StatefulWidget {
  final int initialIndex;
  final Color accentColor;
  final ValueChanged<int> onTabSelected;

  const PlayerBottomTabsInSheet({
    super.key,
    required this.initialIndex,
    required this.accentColor,
    required this.onTabSelected,
  });

  @override
  State<PlayerBottomTabsInSheet> createState() => _PlayerBottomTabsInSheetState();
}

class _PlayerBottomTabsInSheetState extends State<PlayerBottomTabsInSheet> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _buildTab(int index, String text) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        widget.onTabSelected(index);
      },
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
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
