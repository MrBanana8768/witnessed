import 'package:cloud_firestore/cloud_firestore.dart';
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
      print('Error getting user: $e');
      return null;
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
      print('Error creating user: $e');
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
      print('Error updating user: $e');
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
      print('Error ensuring user profile: $e');
      return null;
    }
  }
  
  // Post operations
  Future<String?> createPost(PostModel post) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.postsCollection)
          .add(post.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating post: $e');
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
              ))
          .toList();
    } catch (e) {
      print('Error getting posts: $e');
      return [];
    }
  }
  
  Future<bool> deletePost(String postId) async {
    try {
      await _firestore
          .collection(AppConstants.postsCollection)
          .doc(postId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting post: $e');
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
      print('Error liking post: $e');
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
      print('Error unliking post: $e');
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
      print('Error following user: $e');
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
                ))
            .toList());
  }
}
