import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isFollowing = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isFollowing => _isFollowing;

  // Fetch user profile by userId
  Future<void> fetchUserProfile(String userId, {String? email, String? displayName}) async {
    _setLoading(true);
    _error = null;

    try {
      final fetchedUser = await _databaseService.getUser(userId);

      if (fetchedUser != null) {
        _user = fetchedUser;
      } else {
        // User profile doesn't exist, try to create it if we have email
        if (email != null) {
          final newUser = await _databaseService.ensureUserProfile(
            userId: userId,
            email: email,
            displayName: displayName,
          );

          if (newUser != null) {
            _user = newUser;
          } else {
            _error = 'Failed to create user profile';
          }
        } else {
          _error = 'User profile not found';
        }
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
      print('Error fetching user profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? username,
    String? bio,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    bool? isPrivate,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final updates = <String, dynamic>{};

      if (displayName != null) updates['displayName'] = displayName;
      if (username != null) updates['username'] = username;
      if (bio != null) updates['bio'] = bio;
      if (website != null) updates['website'] = website;
      if (location != null) updates['location'] = location;
      if (dateOfBirth != null) updates['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (isPrivate != null) updates['isPrivate'] = isPrivate;

      updates['updatedAt'] = DateTime.now().toIso8601String();

      final success = await _databaseService.updateUser(_user!.id, updates);

      if (success) {
        // Update local user model
        _user = _user!.copyWith(
          displayName: displayName,
          username: username,
          bio: bio,
          website: website,
          location: location,
          dateOfBirth: dateOfBirth,
          isPrivate: isPrivate,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to update profile';
        return false;
      }
    } catch (e) {
      _error = 'Failed to update profile: $e';
      print('Error updating profile: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload profile photo
  Future<bool> uploadProfilePhoto(String filePath) async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final file = File(filePath);
      final photoUrl = await _storageService.uploadProfileImage(
        userId: _user!.id,
        imageFile: file,
      );

      if (photoUrl != null) {
        final success = await _databaseService.updateUser(
          _user!.id,
          {
            'photoUrl': photoUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        if (success) {
          _user = _user!.copyWith(
            photoUrl: photoUrl,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
          return true;
        }
      }

      _error = 'Failed to upload profile photo';
      return false;
    } catch (e) {
      _error = 'Failed to upload profile photo: $e';
      print('Error uploading profile photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Upload cover photo
  Future<bool> uploadCoverPhoto(String filePath) async {
    if (_user == null) return false;

    _setLoading(true);
    _error = null;

    try {
      final file = File(filePath);
      final coverPhotoUrl = await _storageService.uploadCoverImage(
        userId: _user!.id,
        imageFile: file,
      );

      if (coverPhotoUrl != null) {
        final success = await _databaseService.updateUser(
          _user!.id,
          {
            'coverPhotoUrl': coverPhotoUrl,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        );

        if (success) {
          _user = _user!.copyWith(
            coverPhotoUrl: coverPhotoUrl,
            updatedAt: DateTime.now(),
          );
          notifyListeners();
          return true;
        }
      }

      _error = 'Failed to upload cover photo';
      return false;
    } catch (e) {
      _error = 'Failed to upload cover photo: $e';
      print('Error uploading cover photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Follow/Unfollow user
  Future<bool> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      if (_isFollowing) {
        // Unfollow logic would go here
        // For now, just toggle the state
        _isFollowing = false;
      } else {
        final success = await _databaseService.followUser(currentUserId, targetUserId);
        if (success) {
          _isFollowing = true;
          // Update follower count
          if (_user?.id == targetUserId) {
            _user = _user!.copyWith(
              followersCount: _user!.followersCount + 1,
            );
          }
        }
      }
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to toggle follow: $e';
      print('Error toggling follow: $e');
      return false;
    }
  }

  // Check if current user is following target user
  Future<void> checkFollowStatus(String currentUserId, String targetUserId) async {
    // This would check Firestore for follow status
    // For now, set to false by default
    _isFollowing = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _isLoading = false;
    _error = null;
    _isFollowing = false;
    notifyListeners();
  }
}
