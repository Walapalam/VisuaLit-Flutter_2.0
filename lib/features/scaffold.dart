import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final String? userAvatarUrl = 'https://example.com/avatar.png'; // Replace with actual user avatar URL or null

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Visualit',
          style: TextStyle(
            fontFamily: 'Jersey20',
            color: Theme.of(context).colorScheme.onPrimary,
            fontSize: 35.0,
            fontWeight: FontWeight.normal,
          ),
        ),
        centerTitle: false,
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.surface,
                radius: 28, // Adjusted size for better visibility
                backgroundImage: userAvatarUrl != null
                    ? NetworkImage(userAvatarUrl)
                    : null, // Load avatar image if available
                child: userAvatarUrl == null
                    ? Icon(
                  Icons.account_circle, // Placeholder icon
                  size: 40, // Adjusted size for better visibility
                  color: Theme.of(context).colorScheme.onSurface,
                )
                    : null, // Show placeholder icon if no avatar
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
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
          debugPrint('Navigating to index: $index');
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
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
            icon: Icon(Icons.store_outlined),
            activeIcon: Icon(Icons.store),
            label: 'Marketplace',
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