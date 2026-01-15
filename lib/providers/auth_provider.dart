import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;

  /// Sign in with Google (Citizens only)
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _firebaseAuthService.signInWithGoogle();
      
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('❌ Google Sign-In error in provider: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Login for Officials and Admins (from Firestore database)
  Future<bool> loginOfficial(String email, String password, UserRole role) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Query the appropriate collection based on role
      final collectionName = role == UserRole.official ? 'officials' : 'admins';
      
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password) // In production, use hashed passwords
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final userData = querySnapshot.docs.first.data();
      _currentUser = UserModel.fromJson(userData);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('❌ Official login error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Legacy login method (kept for backward compatibility)
  Future<bool> login(String email, String password, UserRole role) async {
    if (role == UserRole.citizen) {
      // Citizens should use Google Sign-In
      return false;
    }
    
    return loginOfficial(email, password, role);
  }

  Future<void> logout() async {
    if (_currentUser?.role == UserRole.citizen) {
      await _firebaseAuthService.signOut();
    }
    
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password, UserRole role) async {
    // Registration is only available for citizens via Google Sign-In
    // Officials and admins are added directly to the database
    return false;
  }
}
