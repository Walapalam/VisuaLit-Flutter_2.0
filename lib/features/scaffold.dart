import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:visualit/features/auth/presentation/auth_controller.dart';
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
              leading: const SizedBox(
                width: 48,
              ), // Balance the profile icon (16 padding + 32 avatar)
              actions: [
                Consumer(
                  builder: (context, ref, child) {
                    final authState = ref.watch(authControllerProvider);
                    final user = authState.user;

                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: GestureDetector(
                        onTap: () => Scaffold.of(context).openEndDrawer(),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? Text(
                                  user?.displayName?.isNotEmpty == true
                                      ? user!.displayName![0].toUpperCase()
                                      : 'G',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  },
                ),
              ],
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
