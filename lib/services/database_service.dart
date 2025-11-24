import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../models/post_model.dart';
import '../config/constants.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User operations
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user: $e');
      return null;
    }
  }

  /// Check if a username is already taken by another user
  /// Returns true if available, false if taken
  Future<bool> isUsernameAvailable(String username, {String? excludeUserId}) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return true; // Username is available
      }

      // If excludeUserId is provided, check if the found user is the same user
      // (This allows users to keep their current username when editing profile)
      if (excludeUserId != null && querySnapshot.docs.first.id == excludeUserId) {
        return true;
      }

      return false; // Username is taken
    } catch (e) {
      debugPrint('Error checking username availability: $e');
      return false; // Assume taken on error to be safe
    }
  }
  
  Future<bool> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error creating user: $e');
      return false;
    }
  }
  
  Future<bool> updateUser(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating user: $e');
      return false;
    }
  }

  /// Ensures a user profile exists in Firestore
  /// Creates a basic profile if it doesn't exist
  /// Returns the user profile (existing or newly created)
  Future<UserModel?> ensureUserProfile({
    required String userId,
    required String email,
    String? displayName,
    String? username,
  }) async {
    try {
      // First, try to get existing user
      final existingUser = await getUser(userId);
      if (existingUser != null) {
        return existingUser;
      }

      // User doesn't exist, create a new profile
      final now = DateTime.now();
      final newUser = UserModel(
        id: userId,
        email: email,
        username: username ?? email.split('@')[0],
        displayName: displayName ?? email.split('@')[0],
        createdAt: now,
        updatedAt: now,
      );

      final success = await createUser(newUser);
      if (success) {
        return newUser;
      }

      return null;
    } catch (e) {
      debugPrint('Error ensuring user profile: $e');
      return null;
    }
  }
  
  // Post operations
  Future<String?> createPost(PostModel post) async {
    try {
      final batch = _firestore.batch();

      // Add the post
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc();

      batch.set(postRef, post.toFirestore());

      // Increment user's posts count
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(post.userId);

      batch.update(userRef, {
        'postsCount': FieldValue.increment(1),
      });

      await batch.commit();
      return postRef.id;
    } catch (e) {
      debugPrint('Error creating post: $e');
      return null;
    }
  }
  
  Future<List<PostModel>> getPosts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      Query query = _firestore
          .collection(AppConstants.postsCollection)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ),
      )
          .toList();
    } catch (e) {
      debugPrint('Error getting posts: $e');
      return [];
    }
  }

  /// Get posts by a specific user
  Future<List<PostModel>> getUserPosts(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.postsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => PostModel.fromFirestore(
                doc.data(),
                doc.id,
              ),
      )
          .toList();
    } catch (e) {
      debugPrint('Error getting user posts: $e');
      return [];
    }
  }
  
  Future<bool> deletePost(String postId, String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete the post
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId);

      batch.delete(postRef);

      // Decrement user's posts count
      final userRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      batch.update(userRef, {
        'postsCount': FieldValue.increment(-1),
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error deleting post: $e');
      return false;
    }
  }
  
  // Like operations
  Future<bool> likePost(String postId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Add like document
      final likeRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.likesCollection)
          .doc(userId);
      
      batch.set(likeRef, {
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update post likes count
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId);
      
      batch.update(postRef, {
        'likesCount': FieldValue.increment(1),
      });
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error liking post: $e');
      return false;
    }
  }
  
  Future<bool> unlikePost(String postId, String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Remove like document
      final likeRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .collection(AppConstants.likesCollection)
          .doc(userId);
      
      batch.delete(likeRef);
      
      // Update post likes count
      final postRef = _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId);
      
      batch.update(postRef, {
        'likesCount': FieldValue.increment(-1),
      });
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error unliking post: $e');
      return false;
    }
  }
  
  // Follow operations
  Future<bool> followUser(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();
      
      // Add to following collection
      final followingRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(currentUserId)
          .collection(AppConstants.followingCollection)
          .doc(targetUserId);
      
      batch.set(followingRef, {
        'userId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Add to followers collection
      final followersRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(targetUserId)
          .collection(AppConstants.followersCollection)
          .doc(currentUserId);
      
      batch.set(followersRef, {
        'userId': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Update counts
      batch.update(
        _firestore.collection(AppConstants.usersCollection).doc(currentUserId),
        {'followingCount': FieldValue.increment(1)},
      );
      
      batch.update(
        _firestore.collection(AppConstants.usersCollection).doc(targetUserId),
        {'followersCount': FieldValue.increment(1)},
      );
      
      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error following user: $e');
      return false;
    }
  }
  
  // Stream for real-time updates
  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection(AppConstants.postsCollection)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromFirestore(
                  doc.data(),
                  doc.id,
                ),
    )
            .toList(),
    );
  }
}
