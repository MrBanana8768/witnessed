# User Signup Flow - How Firestore Profiles are Created

This document explains how user profiles are automatically created in Firestore when users sign up.

## Overview

When a user signs up, **two things happen**:
1. Firebase Authentication creates an auth account (email/password)
2. **Firestore** creates a user profile document with all user data

## The Complete Flow

### 1. User Opens App → Login/Signup Screen

```
User sees LoginScreen
├── Toggle to "Sign Up" mode
├── Fills in:
│   ├── Display Name (e.g., "John Doe")
│   ├── Username (e.g., "johndoe")
│   ├── Email (e.g., "john@example.com")
│   └── Password
└── Clicks "Sign Up" button
```

### 2. LoginScreen → AuthProvider.signUp()

**File:** `lib/screens/auth/login_screen.dart` (lines 39-46)

```dart
success = await authProvider.signUp(
  email: _emailController.text.trim(),
  password: _passwordController.text.trim(),
  displayName: _displayNameController.text.trim(),
  username: _usernameController.text.trim(),
);
```

### 3. AuthProvider.signUp() - THE MAGIC HAPPENS HERE

**File:** `lib/providers/auth_provider.dart` (lines 86-135)

This method does THREE critical steps:

#### Step 3a: Create Firebase Auth Account

```dart
final error = await _authService.signUp(
  email: email,
  password: password,
  displayName: displayName,
);
```

This creates the authentication account in Firebase Auth.

#### Step 3b: Create UserModel

```dart
final userModel = UserModel.create(
  id: _firebaseUser!.uid,  // Uses Firebase Auth UID
  email: email,
  username: username,
  displayName: displayName,
);
```

`UserModel.create()` creates a new user object with:
- **id**: Firebase Auth user ID
- **email**: User's email
- **username**: Unique username
- **displayName**: Display name
- **createdAt**: Current timestamp
- **updatedAt**: Current timestamp
- **Default values**: 0 followers, 0 posts, not verified, etc.

#### Step 3c: Save to Firestore

```dart
final success = await _databaseService.createUser(userModel);
```

This calls `DatabaseService.createUser()` which saves the user document to Firestore.

### 4. DatabaseService.createUser() - Saves to Firestore

**File:** `lib/services/database_service.dart` (lines 27-38)

```dart
Future<bool> createUser(UserModel user) async {
  try {
    await _firestore
        .collection(AppConstants.usersCollection) // 'users'
        .doc(user.id)  // Document ID = Firebase Auth UID
        .set(user.toFirestore());  // Converts to Map
    return true;
  } catch (e) {
    print('Error creating user: $e');
    return false;
  }
}
```

### 5. What Gets Saved to Firestore?

**Firestore Collection:** `users`
**Document ID:** Firebase Auth UID (e.g., `abc123xyz`)

**Document Data:**
```json
{
  "email": "john@example.com",
  "username": "johndoe",
  "displayName": "John Doe",
  "bio": null,
  "photoUrl": null,
  "coverPhotoUrl": null,
  "website": null,
  "location": null,
  "dateOfBirth": null,
  "createdAt": "2025-01-15T10:30:00.000Z",
  "updatedAt": "2025-01-15T10:30:00.000Z",
  "isVerified": false,
  "isPrivate": false,
  "isOnline": false,
  "lastSeen": null,
  "followersCount": 0,
  "followingCount": 0,
  "postsCount": 0,
  "interests": [],
  "settings": null,
  "metadata": null
}
```

### 6. User is Redirected to Home

**File:** `lib/main.dart` (lines 52-72)

The `AuthWrapper` listens to Firebase auth state changes:

```dart
StreamBuilder<User?>(
  stream: authService.authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.hasData && snapshot.data != null) {
      return HomeScreen();  // User authenticated → Home
    }
    return LoginScreen();  // Not authenticated → Login
  },
)
```

When signup succeeds, Firebase Auth emits a user state change, and the app automatically navigates to `HomeScreen`.

## Testing the Flow

### 1. Run the App

```bash
flutter run
```

### 2. Sign Up

1. On LoginScreen, toggle to "Sign Up" mode
2. Fill in all fields:
   - Display Name: "Test User"
   - Username: "testuser"
   - Email: "test@example.com"
   - Password: "password123"
3. Click "Sign Up"

### 3. Verify in Firebase Console

Go to Firebase Console → Firestore Database:

```
users (collection)
  └── <firebase-auth-uid> (document)
      ├── email: "test@example.com"
      ├── username: "testuser"
      ├── displayName: "Test User"
      ├── followersCount: 0
      ├── createdAt: "..."
      └── ... (all other fields)
```

### 4. Check Profile

- Click "Profile" button on HomeScreen
- You should see your profile with:
  - Display name
  - Username
  - Default avatar (initials)
  - Stats (0 posts, 0 followers, 0 following)

## Key Files Reference

| File | Purpose |
|------|---------|
| `lib/screens/auth/login_screen.dart` | UI for login/signup |
| `lib/providers/auth_provider.dart` | Handles signup logic + Firestore creation |
| `lib/services/auth_service.dart` | Firebase Auth operations only |
| `lib/services/database_service.dart` | Firestore CRUD operations |
| `lib/models/user_model.dart` | User data structure |
| `lib/main.dart` | App setup + auth state listener |

## Important Notes

### UserModel.create() Factory

**File:** `lib/models/user_model.dart` (lines 57-72)

This factory method creates a new user with sensible defaults:

```dart
factory UserModel.create({
  required String id,
  required String email,
  required String username,
  required String displayName,
}) {
  final now = DateTime.now();
  return UserModel(
    id: id,
    email: email,
    username: username,
    displayName: displayName,
    createdAt: now,
    updatedAt: now,
    // All other fields use default values
  );
}
```

### Automatic Profile Loading

When a user signs in, `AuthProvider._onAuthStateChanged()` automatically loads their Firestore profile:

```dart
void _onAuthStateChanged(User? user) async {
  _firebaseUser = user;

  if (user != null) {
    await _loadUserData(user.uid);  // Loads from Firestore
  } else {
    _currentUser = null;
  }

  notifyListeners();
}
```

## Troubleshooting

### "User profile not found" error

**Cause:** User has Firebase Auth account but no Firestore document.

**Solution:** This happens if signup used `AuthService` directly instead of `AuthProvider`. Always use `AuthProvider.signUp()`.

### Username/Display Name not showing

**Cause:** Firestore document wasn't created properly.

**Solution:** Check Firebase Console → Firestore to verify the document exists.

### Can't see profile after signup

**Cause:** `AuthProvider` might not be registered in `main.dart`.

**Solution:** Verify `main.dart` has `AuthProvider` in the provider list.

## Summary

The flow is simple:

1. **User signs up** → LoginScreen
2. **AuthProvider.signUp()** → Creates Firebase Auth account
3. **UserModel.create()** → Creates user object
4. **DatabaseService.createUser()** → Saves to Firestore
5. **AuthWrapper** → Detects auth change → Navigates to HomeScreen
6. **Done!** User can view their profile

Everything happens automatically - you don't need to manually create the Firestore document. Just call `AuthProvider.signUp()` and it handles everything!