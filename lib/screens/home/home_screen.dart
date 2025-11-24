import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../../widgets/common/app_navigation_rail.dart';
import '../../widgets/post/create_post_dialog.dart';
import '../../widgets/post/posts_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? user = authService.currentUser;
    
    return Scaffold(
      body: Row(
        children: [
          // Navigation Rail
          const AppNavigationRail(selectedIndex: 0),

          // Vertical Divider
          const VerticalDivider(thickness: 1, width: 1),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // App Bar
                AppBar(
                  title: const Text('Witnessed'),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  automaticallyImplyLeading: false,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () => _showSignOutDialog(context, authService),
                      tooltip: 'Sign Out',
                    ),
                  ],
                ),

                // Posts Feed
                const Expanded(
                  child: PostsFeed(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const CreatePostDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Create Post'),
      ),
    );
  }
  
  void _showSignOutDialog(BuildContext context, AuthService authService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              authService.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
