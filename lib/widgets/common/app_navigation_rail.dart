import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/profile/profile_screen.dart';

class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final Function(int)? onDestinationSelected;


  const AppNavigationRail({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final User? currentUser = authService.currentUser;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (onDestinationSelected != null) {
          onDestinationSelected!(index);
        } else {
          _handleNavigation(context, index, currentUser);
        }
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(icon: Icon(Icons.auto_awesome_outlined), label: Text('AI Chat'), selectedIcon: Icon(Icons.auto_awesome)),
        NavigationRailDestination(
          icon: Icon(Icons.explore_outlined),
          selectedIcon: Icon(Icons.explore),
          label: Text('Explore'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.notifications_outlined),
          selectedIcon: Icon(Icons.notifications),
          label: Text('Notifications'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.message_outlined),
          selectedIcon: Icon(Icons.message),
          label: Text('Messages'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index, User? currentUser) {
    switch (index) {
      case 0: // Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
        break;
      case 1: // Explore
        _showComingSoon(context, 'AI Chat');
        break;
      case 2: // Explore
        _showComingSoon(context, 'Explore');
        break;
      case 3: // Notifications
        _showComingSoon(context, 'Notifications');
        break;
      case 4: // Messages
        _showComingSoon(context, 'Messages');
        break;
      case 5: // Profile
        if (currentUser != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ProfileScreen(userId: currentUser.uid),
            ),
          );
        }
        break;
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
