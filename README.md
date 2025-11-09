# AI Social Platform

A comprehensive Flutter application structure for an AI-powered social media platform similar to Truth Social/Bluesky/Twitter.

## 📱 Features

- **Authentication System**: Email/password, social login, biometric auth
- **Social Features**: Posts, comments, likes, shares, follows
- **AI Integration**: Content generation, moderation, suggestions
- **Real-time Updates**: Live feeds, notifications, chat
- **Media Support**: Images, videos, polls, links
- **User Profiles**: Customizable profiles, settings, privacy

## 🏗️ Project Structure

```
lib/
├── main.dart                # Application entry point
├── config/                  # App configuration
│   ├── constants.dart      # App-wide constants
│   ├── theme.dart          # Theme definitions
│   └── routes.dart         # Navigation routes
├── models/                  # Data models
│   ├── user_model.dart     # User data structure
│   ├── post_model.dart     # Post data structure
│   └── ...
├── services/               # Business logic & APIs
│   ├── auth_service.dart   # Authentication
│   ├── ai_service.dart     # AI integration
│   └── ...
├── providers/              # State management
│   ├── auth_provider.dart  # Auth state
│   ├── posts_provider.dart # Posts state
│   └── ...
├── screens/                # Full page views
│   ├── auth/              # Authentication screens
│   ├── home/              # Main app screens
│   ├── post/              # Post-related screens
│   ├── profile/           # Profile screens
│   └── ai/                # AI feature screens
├── widgets/                # Reusable components
│   ├── common/            # Shared widgets
│   ├── post/              # Post widgets
│   └── ...
└── utils/                  # Utility functions
    ├── validators.dart     # Input validation
    ├── formatters.dart     # Data formatting
    └── ...
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK
- Android Studio / Xcode
- Firebase account

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/ai-social-platform.git
cd ai-social-platform
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

- Create a new Firebase project
- Add Android/iOS apps
- Download configuration files:
  - `google-services.json` → `android/app/`
  - `GoogleService-Info.plist` → `ios/Runner/`
- Enable Authentication, Firestore, and Storage

4. **Run the app**
```bash
flutter run
```

## 📦 Dependencies

### Core
- `firebase_core`: Firebase initialization
- `firebase_auth`: Authentication
- `cloud_firestore`: Database
- `firebase_storage`: File storage

### State Management
- `provider`: State management solution

### UI/UX
- `cached_network_image`: Image caching
- `shimmer`: Loading effects
- `lottie`: Animations

### Utilities
- `dio`: Advanced HTTP client
- `go_router`: Navigation
- `shared_preferences`: Local storage

## 🔧 Configuration

### Environment Variables

Create a `.env` file in the root directory:

```env
API_BASE_URL=https://api.example.com
AI_API_KEY=your_ai_api_key
```

### Firebase Setup

Update `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.yourcompany.ai_social_platform"
    minSdkVersion 21
    targetSdkVersion 33
}
```

Update iOS Bundle Identifier in Xcode.

## 🎨 Theming

The app supports light and dark themes. Customize in `lib/config/theme.dart`:

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(...);
  static ThemeData darkTheme = ThemeData(...);
}
```

## 🧪 Testing

### Unit Tests
```bash
flutter test test/unit/
```

### Widget Tests
```bash
flutter test test/widget/
```

### Integration Tests
```bash
flutter test test/integration/
```

## 📱 Screenshots

<img src="screenshots/login.png" width="250"> <img src="screenshots/home.png" width="250"> <img src="screenshots/profile.png" width="250">

## 🤖 AI Features

### Content Generation
- Post suggestions
- Caption generation
- Hashtag recommendations

### Content Moderation
- Toxicity detection
- Spam filtering
- Policy compliance

### Personalization
- Feed algorithm
- Content recommendations
- User suggestions

## 🔐 Security

- Secure authentication flow
- Data encryption
- API key protection
- User privacy controls

## 📈 Performance

- Lazy loading
- Image caching
- Pagination
- Code splitting

## 🚢 Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

All Rights Reserved - Copyright 2025

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Community contributors

## 📞 Contact

Your Name - [@yourusername](https://twitter.com/yourusername)

Project Link: [https://github.com/yourusername/ai-social-platform](https://github.com/yourusername/ai-social-platform)
