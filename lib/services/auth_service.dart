import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../models/user_role.dart';
import 'firestore_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();

  User? get currentUser => _auth.currentUser;
  UserRole? role;
  UserProfile? profile;
  bool isLoading = false;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await _loadProfile();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;
    final profileData = await _firestore.fetchUserProfile(user.uid);
    profile = profileData;
    role = profileData?.role;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    role = null;
    profile = null;
    notifyListeners();
  }

  Future<void> ensureProfileLoaded() async {
    if (profile == null && currentUser != null) {
      await _loadProfile();
    }
  }
}
