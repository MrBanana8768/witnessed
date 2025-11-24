# Flutter Application Repository Structure

## Complete Project Structure

```
ai_social_platform/
├── .gitignore
├── .metadata
├── README.md
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
│
├── android/                    # Android-specific files
│   ├── app/
│   │   ├── build.gradle
│   │   ├── src/
│   │   │   ├── debug/
│   │   │   │   └── AndroidManifest.xml
│   │   │   ├── main/
│   │   │   │   ├── AndroidManifest.xml
│   │   │   │   ├── kotlin/
│   │   │   │   │   └── com/
│   │   │   │   │       └── example/
│   │   │   │   │           └── ai_social_platform/
│   │   │   │   │               └── MainActivity.kt
│   │   │   │   └── res/
│   │   │   │       ├── drawable/
│   │   │   │       ├── drawable-v21/
│   │   │   │       ├── mipmap-hdpi/
│   │   │   │       ├── mipmap-mdpi/
│   │   │   │       ├── mipmap-xhdpi/
│   │   │   │       ├── mipmap-xxhdpi/
│   │   │   │       ├── mipmap-xxxhdpi/
│   │   │   │       └── values/
│   │   │   └── profile/
│   │   │       └── AndroidManifest.xml
│   │   └── google-services.json    # Firebase config (added after setup)
│   ├── gradle/
│   │   └── wrapper/
│   │       ├── gradle-wrapper.jar
│   │       └── gradle-wrapper.properties
│   ├── build.gradle
│   ├── gradle.properties
│   └── settings.gradle
│
├── ios/                         # iOS-specific files
│   ├── Runner/
│   │   ├── AppDelegate.swift
│   │   ├── Assets.xcassets/
│   │   │   ├── AppIcon.appiconset/
│   │   │   └── LaunchImage.imageset/
│   │   ├── Base.lproj/
│   │   │   ├── LaunchScreen.storyboard
│   │   │   └── Main.storyboard
│   │   ├── Info.plist
│   │   ├── Runner-Bridging-Header.h
│   │   └── GoogleService-Info.plist    # Firebase config (added after setup)
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   ├── Flutter/
│   └── Podfile
│
├── lib/                         # Main application code
│   ├── main.dart               # Entry point
│   │
│   ├── config/                 # Configuration files
│   │   ├── constants.dart
│   │   ├── theme.dart
│   │   └── routes.dart
│   │
│   ├── models/                 # Data models
│   │   ├── user_model.dart
│   │   ├── post_model.dart
│   │   ├── comment_model.dart
│   │   └── chat_model.dart
│   │
│   ├── services/               # Business logic & API services
│   │   ├── auth_service.dart
│   │   ├── ai_service.dart
│   │   ├── database_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   │
│   ├── providers/              # State management (Provider)
│   │   ├── auth_provider.dart
│   │   ├── user_provider.dart
│   │   ├── posts_provider.dart
│   │   └── theme_provider.dart
│   │
│   ├── screens/                # Full page views
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── signup_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── home/
│   │   │   ├── home_screen.dart
│   │   │   └── feed_screen.dart
│   │   ├── post/
│   │   │   ├── create_post_screen.dart
│   │   │   ├── post_detail_screen.dart
│   │   │   └── edit_post_screen.dart
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   ├── edit_profile_screen.dart
│   │   │   └── settings_screen.dart
│   │   ├── ai/
│   │   │   ├── ai_chat_screen.dart
│   │   │   └── ai_suggestions_screen.dart
│   │   └── splash_screen.dart
│   │
│   ├── widgets/                # Reusable components
│   │   ├── common/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_indicator.dart
│   │   │   └── error_widget.dart
│   │   ├── post/
│   │   │   ├── post_card.dart
│   │   │   ├── post_actions.dart
│   │   │   └── comment_tile.dart
│   │   ├── user/
│   │   │   ├── user_avatar.dart
│   │   │   └── user_info_card.dart
│   │   └── ai/
│   │       ├── ai_suggestion_card.dart
│   │       └── ai_response_bubble.dart
│   │
│   └── utils/                  # Utility functions
│       ├── validators.dart
│       ├── formatters.dart
│       ├── helpers.dart
│       └── extensions.dart
│
├── assets/                     # Static assets
│   ├── images/
│   │   ├── logo.png
│   │   ├── splash_bg.png
│   │   └── placeholders/
│   │       └── user_placeholder.png
│   ├── icons/
│   │   └── app_icon.png
│   ├── animations/
│   │   └── loading.json        # Lottie animations
│   └── fonts/
│       ├── Roboto-Regular.ttf
│       └── Roboto-Bold.ttf
│
├── test/                       # Test files
│   ├── unit/
│   │   ├── services/
│   │   │   ├── auth_service_test.dart
│   │   │   └── ai_service_test.dart
│   │   └── models/
│   │       └── user_model_test.dart
│   ├── widget/
│   │   ├── screens/
│   │   │   └── login_screen_test.dart
│   │   └── widgets/
│   │       └── post_card_test.dart
│   └── integration/
│       └── app_test.dart
│
├── web/                        # Web-specific files (if supporting web)
│   ├── index.html
│   ├── manifest.json
│   └── icons/
│
├── linux/                      # Linux-specific files
├── macos/                      # macOS-specific files
└── windows/                    # Windows-specific files
```

## Key Files to Create

### 1. `.gitignore`
```gitignore
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/
migrate_working_dir/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VS Code
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio
/android/app/debug
/android/app/profile
/android/app/release

# Environment variables
.env
.env.local
```

### 2. `analysis_options.yaml`
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    avoid_print: true
    prefer_const_constructors: true
    prefer_const_declarations: true
    prefer_single_quotes: true
    unnecessary_this: true
    always_declare_return_types: true
    prefer_final_fields: true
    require_trailing_commas: true
    avoid_unnecessary_containers: true
    prefer_const_literals_to_create_immutables: true

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
  errors:
    invalid_annotation_target: ignore
```

### 3. File Organization Best Practices

#### Models (`lib/models/`)
```dart
// user_model.dart
class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime createdAt;
  
  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.createdAt,
  });
}
```

#### Config (`lib/config/`)
```dart
// constants.dart
class AppConstants {
  static const String appName = 'AI Social Platform';
  static const String apiBaseUrl = 'https://api.instituteofconsciousnessawareness.com';
  static const int maxPostLength = 280;
}

// theme.dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(...);
  static ThemeData darkTheme = ThemeData(...);
}

// routes.dart
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  static const String profile = '/profile';
}
```

#### Widgets (`lib/widgets/`)
Keep widgets small and reusable:
```dart
// widgets/common/custom_button.dart
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  
  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Development Workflow

### 1. Initial Setup
```bash
# Create new Flutter project
flutter create ai_social_platform

# Navigate to project
cd ai_social_platform

# Create the folder structure
mkdir -p lib/{config,models,services,providers,screens,widgets,utils}
mkdir -p lib/screens/{auth,home,post,profile,ai}
mkdir -p lib/widgets/{common,post,user,ai}
mkdir -p test/{unit,widget,integration}
mkdir -p assets/{images,icons,animations,fonts}

# Install dependencies
flutter pub get
```

### 2. Version Control
```bash
# Initialize git
git init

# Add files
git add .

# Initial commit
git commit -m "Initial Flutter project setup"

# Add remote repository
git remote add origin https://github.com/yourusername/ai-social-platform.git

# Push to GitHub
git push -u origin main
```

### 3. Branch Strategy
```bash
main/               # Production-ready code
├── develop/        # Development branch
├── feature/        # Feature branches
│   ├── feature/auth
│   ├── feature/posts
│   └── feature/ai-integration
├── bugfix/         # Bug fix branches
└── hotfix/         # Emergency fixes
```

## Best Practices

1. **Keep widgets small**: Each widget should have a single responsibility
2. **Use const constructors**: Where possible for better performance
3. **Separate business logic**: Keep UI and business logic separate
4. **Follow naming conventions**: 
   - Files: `snake_case.dart`
   - Classes: `PascalCase`
   - Variables/functions: `camelCase`
5. **Write tests**: Aim for >80% code coverage
6. **Document code**: Add comments for complex logic
7. **Use proper state management**: Provider, Riverpod, or Bloc
8. **Handle errors gracefully**: Always have error states in UI
9. **Optimize images**: Use appropriate formats and sizes
10. **Follow Material Design**: Or Cupertino for iOS-style apps

## Package Recommendations

### Essential Packages
```yaml
dependencies:
  # Firebase
  firebase_core: latest
  firebase_auth: latest
  cloud_firestore: latest
  firebase_storage: latest
  
  # State Management
  provider: latest  # or riverpod, bloc
  
  # Networking
  http: latest
  dio: latest  # More features than http
  
  # UI/UX
  cached_network_image: latest
  shimmer: latest
  lottie: latest
  
  # Utilities
  intl: latest
  shared_preferences: latest
  path_provider: latest
  
  # Navigation
  go_router: latest  # or auto_route
```

This structure provides a scalable, maintainable foundation for your Flutter application that follows industry best practices.
