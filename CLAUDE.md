# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an AI-powered social media Flutter application (similar to Truth Social/Bluesky/Twitter) built with Firebase as the backend. The app includes authentication, social features (posts, comments, likes, follows), real-time updates, media support, and AI integration.

**Project Name:** ai_social_platform
**Flutter SDK:** >=3.0.0 <4.0.0

## Development Commands

### Setup
```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code (when models change)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for continuous code generation
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running the App
```bash
# Run on default device
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>

# Run in release mode
flutter run --release

# Hot reload: Press 'r' in terminal
# Hot restart: Press 'R' in terminal
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/services/auth_service_test.dart

# Run tests with coverage
flutter test --coverage
```

### Building
```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

### Code Quality
```bash
# Analyze code for issues
flutter analyze

# Format code
flutter format lib/

# Format specific file
flutter format lib/main.dart
```

## Architecture

### State Management
The app uses **Provider** for state management. Key providers:
- `AuthProvider` (lib/providers/auth_provider.dart) - Manages authentication state and user profile data
- Additional providers should follow the same pattern

### Service Layer Architecture
Services are organized by responsibility and follow a consistent pattern:

**AuthService** (lib/services/auth_service.dart):
- Handles Firebase Authentication
- Extends `ChangeNotifier` for reactive updates
- Returns `String?` for errors (null = success)

**DatabaseService** (lib/services/database_service.dart):
- Manages Firestore CRUD operations
- Handles batched writes for transactions (likes, follows)
- Provides both futures and streams for data access
- Uses pagination with `DocumentSnapshot` for large lists

**StorageService** (lib/services/storage_service.dart):
- Manages Firebase Storage for media uploads
- Handles profile images, post images, and videos
- Includes file size validation and progress tracking
- Returns download URLs or null on failure

### Data Models
Models use `json_annotation` for serialization and extend `Equatable` for value comparison:
- Separate methods for JSON and Firestore serialization
- `fromFirestore()` factory for reading from Firestore
- `toFirestore()` method for writing to Firestore
- `copyWith()` method for immutable updates
- Helper getters for computed properties

After modifying models, run: `flutter pub run build_runner build --delete-conflicting-outputs`

### Firebase Collections Structure
```
users/
  {userId}/
    - profile data
    followers/{followerId}/
    following/{followingId}/

posts/
  {postId}/
    - post data
    likes/{userId}/
    comments/{commentId}/

notifications/
chats/
  {chatId}/
    messages/{messageId}/
```

### Configuration
All app-wide constants are centralized in `lib/config/constants.dart`:
- Firebase collection names
- Storage paths
- Pagination limits
- Content limits (post length, image sizes)
- Regex patterns for validation
- SharedPreferences keys
- Error/success messages

## Firebase Setup

The app requires Firebase configuration files:
- **Android**: `android/app/google-services.json`
- **iOS**: `ios/Runner/GoogleService-Info.plist`

These files are gitignored. To set up:
1. Create a Firebase project at console.firebase.google.com
2. Add Android/iOS apps to the project
3. Download and place the configuration files
4. Enable Authentication, Firestore, and Storage in Firebase Console

## Project Structure

```
lib/
├── main.dart              # App entry point with AuthWrapper
├── config/                # Constants, theme, routes
├── models/                # Data models with JSON serialization
├── services/              # Business logic and Firebase operations
├── providers/             # State management with Provider
├── screens/               # Full-page views organized by feature
│   ├── auth/             # Login, signup, splash
│   └── home/             # Main app screens
├── widgets/               # Reusable UI components
│   └── common/           # Shared widgets like CustomButton
└── utils/                 # Helper functions and extensions
```

## Important Patterns

### Error Handling
Services return `String?` for errors (null indicates success):
```dart
final error = await authService.signIn(email: email, password: password);
if (error != null) {
  // Handle error
}
```

### Provider Pattern
Providers manage loading states and errors:
```dart
class SomeProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
}
```

### Authentication Flow
The app uses `AuthWrapper` (lib/main.dart:41) which listens to Firebase auth state changes:
- Loading → `SplashScreen`
- Authenticated → `HomeScreen`
- Not authenticated → `LoginScreen`

### Batched Operations
For operations that update multiple documents (likes, follows), use Firestore batches to ensure atomicity. See `DatabaseService.likePost()` and `DatabaseService.followUser()` for examples.

## Code Generation

Models use `json_serializable`. When you modify a model:
1. Update the model class
2. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. The `*.g.dart` file will be generated automatically

## Testing Strategy

Test organization:
- `test/unit/` - Unit tests for services and models
- `test/widget/` - Widget tests for UI components
- `test/integration/` - Integration tests for complete flows

Use `mockito` and `faker` packages (already included) for test data and mocking.

## Assets

Assets are organized in the `assets/` directory:
- `assets/images/` - Logo, splash backgrounds, placeholders
- `assets/icons/` - App icons
- `assets/animations/` - Lottie JSON files
- `assets/fonts/` - Custom fonts

All asset paths are defined in `lib/config/constants.dart` for consistency.

## Common Issues

**"Missing google-services.json"**: Download from Firebase Console and place in `android/app/`

**"Pod install failed"**: Run `cd ios && pod install --repo-update`

**JSON serialization errors**: Run `flutter pub run build_runner build --delete-conflicting-outputs`

**Hot reload not working**: Try hot restart (R) or full restart

## Key Dependencies

- **firebase_core, firebase_auth, cloud_firestore, firebase_storage** - Firebase suite
- **provider** - State management
- **go_router** - Navigation
- **cached_network_image** - Image caching
- **dio** - HTTP client
- **json_annotation/json_serializable** - JSON serialization
- **equatable** - Value equality
