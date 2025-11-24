import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Get auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else if (e.code == 'user-disabled') {
        return 'This user account has been disabled.';
      } else {
        return e.message ?? 'An error occurred during sign in.';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
  
  // Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Update display name
      if (result.user != null) {
        await result.user!.updateDisplayName(displayName.trim());
        await result.user!.reload();
      }
      
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        return 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else {
        return e.message ?? 'An error occurred during sign up.';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
  
  // Reset password
  Future<String?> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'invalid-email') {
        return 'Invalid email format.';
      } else {
        return e.message ?? 'An error occurred sending reset email.';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }
}
