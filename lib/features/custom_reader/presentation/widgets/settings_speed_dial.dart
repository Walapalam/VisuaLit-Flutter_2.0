import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visualit/core/theme/app_theme.dart';

class SettingsSpeedDial extends StatelessWidget {
  final bool isLocked;
  final VoidCallback onToggleLock;
  final VoidCallback onShowSettingsPanel;
  final VoidCallback onShowBookmark;
  final VoidCallback onShare;
  final VoidCallback onSearch;
  final bool isVisible;

  const SettingsSpeedDial({
    Key? key,
    required this.isLocked,
    required this.onToggleLock,
    required this.onShowSettingsPanel,
    required this.onShowBookmark,
    required this.onShare,
    required this.onSearch,
    required this.isVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.more_horiz,
      activeIcon: Icons.close,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.black,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      buttonSize: const Size(48, 48),
      childrenButtonSize: const Size(44, 44),
      curve: Curves.bounceIn,
      visible: isVisible,
      direction: SpeedDialDirection.up,
      switchLabelPosition: true,
      spacing: 10,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.bookmark_border),
          label: 'Bookmark',
          onTap: onShowBookmark,
        ),
        SpeedDialChild(
          child: const Icon(Icons.share_outlined),
          label: 'Share',
          onTap: onShare,
        ),
        SpeedDialChild(
          child: Icon(isLocked ? Icons.lock_open_outlined : Icons.lock_outline),
          label: isLocked ? 'Unlock' : 'Lock Screen',
          onTap: onToggleLock,
        ),
        SpeedDialChild(
          child: const Icon(Icons.search),
          label: 'Search',
          onTap: onSearch,
        ),
        SpeedDialChild(
          child: const Icon(Icons.tune_outlined),
          label: 'Theme & Settings',
          onTap: onShowSettingsPanel,
        ),
      ],
    );
  }
}
