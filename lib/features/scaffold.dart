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
        centerTitle: false,
        backgroundColor: AppTheme.black,
        elevation: 0,
        actions: [

          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MySearchDelegate(),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 16,
              ),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: const AppDrawer(),
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

// Place this after MainShell in the same file

class MySearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(child: Text('You searched for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}