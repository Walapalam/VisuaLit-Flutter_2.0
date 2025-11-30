import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_drawer.dart';
import 'audiobook_player/presentation/mini_audio_player.dart';
import 'package:visualit/shared_widgets/glass_bottom_nav.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: navigationShell.currentIndex == 0
          ? AppBar(
              title: const Text(
                'VisuaLit',
                style: TextStyle(
                  fontFamily: 'Jersey20',
                  fontSize: 35.0,
                  fontWeight: FontWeight.normal,
                ),
              ),
              centerTitle: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: const [SizedBox.shrink()],
            )
          : null,
      endDrawer: const AppDrawer(),
      body: Stack(
        children: [
          // Main Content
          navigationShell,

          // Bottom Elements
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MiniAudioPlayer(),
                // Add some spacing if needed, or let the player sit on top of the nav bar area
                // But typically MiniAudioPlayer sits above the nav bar.
                // Let's put the nav bar below it.
                GlassBottomNav(
                  currentIndex: navigationShell.currentIndex,
                  onTap: (index) {
                    debugPrint('Navigating to index: $index');
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // Remove standard BottomNavigationBar
      // bottomNavigationBar: ...
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
