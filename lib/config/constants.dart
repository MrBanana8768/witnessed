class AppConstants {
  // App Info
  static const String appName = 'AI Social Platform';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'AI-powered social media platform';
  
  // API Endpoints
  static const String apiBaseUrl = 'https://api.example.com/v1';
  static const String aiApiBaseUrl = 'https://ai-api.example.com/v1';
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String commentsCollection = 'comments';
  static const String likesCollection = 'likes';
  static const String followersCollection = 'followers';
  static const String followingCollection = 'following';
  static const String notificationsCollection = 'notifications';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  
  // Storage Paths
  static const String profileImagesPath = 'profile_images';
  static const String postImagesPath = 'post_images';
  static const String chatImagesPath = 'chat_images';
  
  // Pagination
  static const int postsPerPage = 20;
  static const int commentsPerPage = 10;
  static const int usersPerPage = 30;
  static const int notificationsPerPage = 15;
  
  // Limits
  static const int maxPostLength = 280;
  static const int maxBioLength = 160;
  static const int maxUsernameLength = 30;
  static const int maxDisplayNameLength = 50;
  static const int maxCommentLength = 200;
  static const int maxImagesPerPost = 4;
  static const int maxVideoSizeInMB = 100;
  static const int maxImageSizeInMB = 10;
  
  // Durations
  static const Duration splashDuration = Duration(seconds: 2);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration debounceSearchDuration = Duration(milliseconds: 500);
  static const Duration sessionTimeout = Duration(hours: 24);
  static const Duration cacheExpiration = Duration(hours: 1);
  
  // AI Features
  static const int maxAISuggestions = 5;
  static const double aiTemperature = 0.7;
  static const int maxAITokens = 150;
  static const String defaultAIModel = 'gpt-3.5-turbo';
  
  // Regular Expressions
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );
  static final RegExp usernameRegex = RegExp(
    r'^[a-zA-Z0-9_]+$',
  );
  static final RegExp hashtagRegex = RegExp(
    r'#[a-zA-Z0-9_]+',
  );
  static final RegExp mentionRegex = RegExp(
    r'@[a-zA-Z0-9_]+',
  );
  static final RegExp urlRegex = RegExp(
    r'https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)',
  );
  
  // Shared Preferences Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String notificationKey = 'notifications_enabled';
  static const String languageKey = 'language_code';
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String lastSyncKey = 'last_sync_timestamp';
  
  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'No internet connection. Please check your network.';
  static const String authError = 'Authentication failed. Please login again.';
  static const String permissionError = 'Permission denied. Please grant the required permissions.';
  static const String validationError = 'Please check your input and try again.';
  
  // Success Messages
  static const String postCreated = 'Post created successfully!';
  static const String postUpdated = 'Post updated successfully!';
  static const String postDeleted = 'Post deleted successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
  static const String passwordChanged = 'Password changed successfully!';
  
  // Placeholder Texts
  static const String postPlaceholder = "What's on your mind?";
  static const String commentPlaceholder = 'Write a comment...';
  static const String searchPlaceholder = 'Search...';
  static const String bioPlaceholder = 'Tell us about yourself...';
  
  // Asset Paths
  static const String logoPath = 'assets/images/logo.png';
  static const String placeholderImage = 'assets/images/placeholder.png';
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String emptyAnimation = 'assets/animations/empty.json';
  static const String errorAnimation = 'assets/animations/error.json';
  static const String successAnimation = 'assets/animations/success.json';
}
