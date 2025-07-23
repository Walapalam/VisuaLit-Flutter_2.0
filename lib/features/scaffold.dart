import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_drawer.dart';
import 'audiobook_player/presentation/mini_audio_player.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The AppBar and endDrawer remain unchanged
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
          IconButton(
            icon: Icon(
              Icons.search,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
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
                backgroundColor: Theme.of(context).colorScheme.surface,
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

      // +++ THIS IS THE MAIN CHANGE +++
      // We use a Column to stack the main page content on top of the mini-player.
      body: Column(
        children: [
          // The Expanded widget ensures the main content (your pages)
          // takes up all available space, pushing the mini-player to the bottom.
          Expanded(
            child: navigationShell,
          ),

          // The MiniAudioPlayer is placed here.
          // It will automatically be visible only when an audiobook is loaded
          // in the global AudiobookPlayerService.
          const MiniAudioPlayer(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        selectedItemColor: Theme.of(context).colorScheme.onPrimary,
        unselectedItemColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.6),
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: false,
        showSelectedLabels: true,
        currentIndex: navigationShell.currentIndex,
        onTap: (index) {
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