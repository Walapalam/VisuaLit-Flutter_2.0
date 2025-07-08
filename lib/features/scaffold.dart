import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
              icon: const CircleAvatar(
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
      // REPLACED: Using the standard Flutter BottomNavigationBar
      bottomNavigationBar: BottomNavigationBar(
        // Styling to match your theme
        backgroundColor: AppTheme.black,
        selectedItemColor: AppTheme.white,     // Color for the selected icon and label
        unselectedItemColor: AppTheme.grey,    // Color for unselected items
        type: BottomNavigationBarType.fixed, // Ensures background color is applied
        showUnselectedLabels: false,           // Hides labels for unselected items
        showSelectedLabels: true,              // Shows label for the selected item

        // Logic to handle navigation
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        // Navigation items
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home), // Optional: a different icon when selected
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            activeIcon: Icon(Icons.book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.headphones_outlined),
            activeIcon: Icon(Icons.headphones),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// Your MySearchDelegate code remains the same
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