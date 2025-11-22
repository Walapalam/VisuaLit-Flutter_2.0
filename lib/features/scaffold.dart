import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visualit/core/theme/app_theme.dart';
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
        centerTitle: true, // Center the logo
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.0),
        elevation: 0,
        // Add empty leading to balance the profile icon on right
        leading: const SizedBox(width: 56), // Same width as IconButton
        leadingWidth: 56,
        actions: [
          // Profile icon aligned with home screen content
          Padding(
            padding: const EdgeInsets.only(
              right: 20,
            ), // Match home screen padding
            child: Consumer(
              builder: (context, ref, child) {
                final authState = ref.watch(authControllerProvider);
                final user = authState.user;

                return Builder(
                  builder: (context) => IconButton(
                    icon: CircleAvatar(
                      backgroundColor: AppTheme.primaryGreen,
                      radius: 16,
                      child: Text(
                        user?.displayName?.isNotEmpty == true
                            ? user!.displayName![0].toUpperCase()
                            : 'G',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.black,
                        ),
                      ),
                    ),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
