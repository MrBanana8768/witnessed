import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final DatabaseService _databaseService = DatabaseService();
  
  User? _firebaseUser;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  
  AuthProvider({required AuthService authService}) : _authService = authService {
    _init();
  }
  
  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Initialize auth state listener
  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }
  
  // Handle auth state changes
  void _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    
    if (user != null) {
      await _loadUserData(user.uid);
    } else {
      _currentUser = null;
    }
    
    notifyListeners();
  }
  
  // Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      // First try to get existing user
      _currentUser = await _databaseService.getUser(userId);

      // If user doesn't exist, create a profile from Firebase Auth data
      if (_currentUser == null && _firebaseUser != null) {
        _currentUser = await _databaseService.ensureUserProfile(
          userId: userId,
          email: _firebaseUser!.email ?? '',
          displayName: _firebaseUser!.displayName,
        );

        if (_currentUser == null) {
          _error = 'Failed to create user profile';
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _error = 'Failed to load user data';
      notifyListeners();
    }
  }
  
  // Sign in
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final error = await _authService.signIn(
        email: email,
        password: password,
      );
      
      if (error != null) {
        _setError(error);
        return false;
      }
      
      return true;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign up
  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Check username availability first
      final isUsernameAvailable = await _databaseService.isUsernameAvailable(username);
      if (!isUsernameAvailable) {
        _setError('Username "$username" is already taken');
        return false;
      }

      // Create auth account
      final error = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      if (error != null) {
        _setError(error);
        return false;
      }

      // Create user profile in Firestore
      if (_firebaseUser != null) {
        final userModel = UserModel.create(
          id: _firebaseUser!.uid,
          email: email,
          username: username,
          displayName: displayName,
        );

        final success = await _databaseService.createUser(userModel);

        if (!success) {
          _setError('Failed to create user profile');
          return false;
        }

        _currentUser = userModel;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _currentUser = null;
      _firebaseUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out');
    } finally {
      _setLoading(false);
    }
  }
  
  // Reset password
  Future<bool> resetPassword({required String email}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final error = await _authService.resetPassword(email: email);
      
      if (error != null) {
        _setError(error);
        return false;
      }
      
      return true;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? photoUrl,
    String? website,
    String? location,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      if (_currentUser == null) {
        _setError('No user logged in');
        return false;
      }
      
      final updates = <String, dynamic>{};
      
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (website != null) updates['website'] = website;
      if (location != null) updates['location'] = location;
      
      updates['updatedAt'] = DateTime.now().toIso8601String();
      
      final success = await _databaseService.updateUser(
        _currentUser!.id,
        updates,
      );
      
      if (success) {
        // Update local user model
        _currentUser = _currentUser!.copyWith(
          displayName: displayName ?? _currentUser!.displayName,
          bio: bio ?? _currentUser!.bio,
          photoUrl: photoUrl ?? _currentUser!.photoUrl,
          website: website ?? _currentUser!.website,
          location: location ?? _currentUser!.location,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update profile');
        return false;
      }
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }
  
  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = null;
  }
  
  void update(AuthService authService) {
    // This method is called when the provider is updated
    // You can add logic here if needed
  }
}
