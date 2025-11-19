import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Screens
import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
// import '../screens/auth/signup_screen.dart';
// import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
// import '../screens/home/feed_screen.dart';
// import '../screens/post/create_post_screen.dart';
// import '../screens/post/post_detail_screen.dart';
// import '../screens/post/edit_post_screen.dart';
import '../screens/profile/profile_screen.dart';
// import '../screens/profile/settings_screen.dart';
// import '../screens/ai/ai_chat_screen.dart';
// import '../screens/ai/ai_suggestions_screen.dart';

// Providers
import '../providers/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authProvider = context.read<AuthProvider>();
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/forgot-password';

      if (!isAuthenticated && !isAuthRoute) {
        return '/login';
      }

      if (isAuthenticated && (isAuthRoute && state.matchedLocation != '/')) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => SplashScreen(),
      ),
      
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => LoginScreen(),
      ),
      // TODO: Create SignupScreen
      // GoRoute(
      //   path: '/signup',
      //   name: 'signup',
      //   builder: (context, state) => const SignupScreen(),
      // ),
      // TODO: Create ForgotPasswordScreen
      // GoRoute(
      //   path: '/forgot-password',
      //   name: 'forgotPassword',
      //   builder: (context, state) => const ForgotPasswordScreen(),
      // ),
      
      // Main App Routes
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => HomeScreen(),
        // TODO: Uncomment when FeedScreen is created
        // routes: [
        //   // Nested routes for home
        //   GoRoute(
        //     path: 'feed',
        //     name: 'feed',
        //     builder: (context, state) => const FeedScreen(),
        //   ),
        // ],
      ),

      // TODO: Uncomment Post Routes when screens are created
      // Post Routes
      // GoRoute(
      //   path: '/post/create',
      //   name: 'createPost',
      //   builder: (context, state) => const CreatePostScreen(),
      // ),
      // GoRoute(
      //   path: '/post/:id',
      //   name: 'postDetail',
      //   builder: (context, state) {
      //     final postId = state.pathParameters['id']!;
      //     return PostDetailScreen(postId: postId);
      //   },
      // ),
      // GoRoute(
      //   path: '/post/:id/edit',
      //   name: 'editPost',
      //   builder: (context, state) {
      //     final postId = state.pathParameters['id']!;
      //     return EditPostScreen(postId: postId);
      //   },
      // ),

      // Profile Routes
      GoRoute(
        path: '/profile/:userId',
        name: 'profile',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return ProfileScreen(userId: userId);
        },
      ),
      // TODO: Uncomment Settings Route when screen is created
      // GoRoute(
      //   path: '/settings',
      //   name: 'settings',
      //   builder: (context, state) => const SettingsScreen(),
      // ),

      // TODO: Uncomment AI Routes when screens are created
      // AI Routes
      // GoRoute(
      //   path: '/ai/chat',
      //   name: 'aiChat',
      //   builder: (context, state) => const AIChatScreen(),
      // ),
      // GoRoute(
      //   path: '/ai/suggestions',
      //   name: 'aiSuggestions',
      //   builder: (context, state) => const AISuggestionsScreen(),
      // ),
    ],
    
    // Error Page
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page Not Found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}

// Route names for easy reference
class Routes {
  static const String splash = 'splash';
  static const String login = 'login';
  static const String signup = 'signup';
  static const String forgotPassword = 'forgotPassword';
  static const String home = 'home';
  static const String feed = 'feed';
  static const String createPost = 'createPost';
  static const String postDetail = 'postDetail';
  static const String editPost = 'editPost';
  static const String profile = 'profile';
  static const String editProfile = 'editProfile';
  static const String settings = 'settings';
  static const String aiChat = 'aiChat';
  static const String aiSuggestions = 'aiSuggestions';
}
