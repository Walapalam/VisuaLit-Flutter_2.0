import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:forui/forui.dart';
import 'package:visualit/core/theme/app_theme.dart';

import 'app_drawer.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Visualit',
          style: TextStyle(
            fontFamily: 'Jersey20',
            color: AppTheme.white,
            fontSize: 35.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.black,
        elevation: 0,
      ),
      // The new drawer is added here, pointing to our separate widget.
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: FBottomNavigationBar(
        style: FBottomNavigationBarStyle(
          decoration: BoxDecoration(
            color: AppTheme.black,
          ),
          itemStyle: FBottomNavigationBarItemStyle(
            iconStyle: FWidgetStateMap<IconThemeData>({
              WidgetState.pressed: const IconThemeData(color: AppTheme.primaryGreen),
              WidgetState.selected: const IconThemeData(color: Colors.white),
              WidgetState.any: const IconThemeData(color: Colors.grey),
            }),
            textStyle: FWidgetStateMap<TextStyle>({
              WidgetState.selected: const TextStyle(color: AppTheme.white),
              WidgetState.any: const TextStyle(color: Colors.grey),
            }),
            tappableStyle: FTappableStyle(),
            focusedOutlineStyle: FFocusedOutlineStyle(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
        index: navigationShell.currentIndex,
        onChange: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        children: const [
          FBottomNavigationBarItem(
            icon: Icon(FIcons.house),
            label: Text('Home'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.book),
            label: Text('Library'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.headphones),
            label: Text('Audio'),
          ),
          FBottomNavigationBarItem(
            icon: Icon(FIcons.settings),
            label: Text('Settings'),
          ),
        ],
      ),
    );
  }
}