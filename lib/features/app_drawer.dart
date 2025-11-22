import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:visualit/core/theme/app_theme.dart';
import 'package:visualit/features/auth/presentation/auth_controller.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: AppTheme.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          bottomLeft: Radius.circular(20),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryGreen.withOpacity(0.05),
              AppTheme.black,
              AppTheme.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Profile Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGreen,
                            AppTheme.primaryGreen.withOpacity(0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGreen.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          user?.displayName?.isNotEmpty == true
                              ? user!.displayName![0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name
                    Text(
                      user?.displayName ?? 'Guest User',
                      style: const TextStyle(
                        color: AppTheme.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email
                    Text(
                      user?.email ?? 'Sign in for full features',
                      style: TextStyle(
                        color: AppTheme.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Colors.white10, height: 1, thickness: 1),

              const SizedBox(height: 16),

              // Menu Items
              _buildMenuItem(
                icon: Icons.person_outline,
                label: 'My Profile',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to profile screen
                },
              ),
              _buildMenuItem(
                icon: Icons.leaderboard_outlined,
                label: 'Leaderboards',
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Navigate to leaderboards screen
                },
              ),

              const Spacer(),

              // Logout/Login Button
              Padding(
                padding: const EdgeInsets.all(20),
                child:
                    authState.status == AuthStatus.authenticated ||
                        authState.status == AuthStatus.guest
                    ? _buildActionButton(
                        icon: Icons.logout,
                        label: 'Logout',
                        onTap: () {
                          Navigator.of(context).pop();
                          ref.read(authControllerProvider.notifier).logout();
                        },
                      )
                    : _buildActionButton(
                        icon: Icons.login,
                        label: 'Login',
                        onTap: () {
                          Navigator.of(context).pop();
                          context.goNamed('login', extra: true);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppTheme.primaryGreen.withOpacity(0.8),
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: AppTheme.primaryGreen.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryGreen, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.primaryGreen,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
