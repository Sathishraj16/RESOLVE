import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in with Google (for citizens only)
  Future<UserModel?> signInWithGoogle() async {
    try {
      debugPrint('🔐 Starting Google Sign-In...');
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        debugPrint('❌ Google Sign-In cancelled by user');
        return null;
      }

      debugPrint('✅ Google account selected: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final firebase_auth.UserCredential userCredential = await _auth.signInWithCredential(credential);
      final firebase_auth.User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        debugPrint('❌ Firebase sign-in failed');
        return null;
      }

      debugPrint('✅ Firebase user created: ${firebaseUser.uid}');

      // Check if user document exists in Firestore
      final userDoc = await _firestore.collection('citizens').doc(firebaseUser.uid).get();

      UserModel user;
      if (!userDoc.exists) {
        // Create new citizen user document
        user = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email!,
          name: firebaseUser.displayName ?? 'User',
          phone: firebaseUser.phoneNumber ?? '',
          role: UserRole.citizen,
          photoUrl: firebaseUser.photoURL,
        );

        await _firestore.collection('citizens').doc(firebaseUser.uid).set(user.toJson());
        debugPrint('✅ New citizen document created in Firestore');
      } else {
        // Load existing user
        user = UserModel.fromJson(userDoc.data()!);
        debugPrint('✅ Existing citizen loaded from Firestore');
      }

      return user;
    } catch (e) {
      debugPrint('❌ Google Sign-In error: $e');
      debugPrint('💡 This is likely due to missing SHA-1 fingerprint in Firebase Console.');
      debugPrint('💡 See GOOGLE_SIGN_IN_FIX.md for instructions to fix this issue.');
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      rethrow;
    }
  }

  /// Get citizen data from Firestore
  Future<UserModel?> getCitizenData(String uid) async {
    try {
      final doc = await _firestore.collection('citizens').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching citizen data: $e');
      return null;
    }
  }

  /// Update citizen profile
  Future<void> updateCitizenProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('citizens').doc(uid).update(data);
      debugPrint('✅ Citizen profile updated');
    } catch (e) {
      debugPrint('❌ Error updating profile: $e');
      rethrow;
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => _auth.currentUser != null;
}
