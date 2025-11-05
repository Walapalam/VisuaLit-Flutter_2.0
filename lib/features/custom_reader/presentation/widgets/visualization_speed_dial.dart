import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:visualit/core/theme/app_theme.dart';

class VisualizationSpeedDial extends StatelessWidget {
  final bool isVisible;
  final VoidCallback onToggleVisualization;
  final VoidCallback onAdjustVisualization;

  const VisualizationSpeedDial({
    Key? key,
    required this.isVisible,
    required this.onToggleVisualization,
    required this.onAdjustVisualization,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.visibility,
      activeIcon: Icons.visibility_off,
      backgroundColor: AppTheme.primaryGreen,
      foregroundColor: Colors.black,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      buttonSize: const Size(48, 48),
      childrenButtonSize: const Size(44, 44),
      curve: Curves.bounceIn,
      visible: isVisible,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.visibility),
          label: 'Toggle Visualization',
          onTap: onToggleVisualization,
        ),
        SpeedDialChild(
          child: const Icon(Icons.tune),
          label: 'Adjust Visualization Settings',
          onTap: onAdjustVisualization,
        ),
      ],
    );
  }
}
