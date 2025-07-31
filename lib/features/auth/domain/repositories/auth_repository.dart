// lib/features/auth/domain/repositories/auth_repository.dart

import 'package:firebase_auth/firebase_auth.dart'; // Using Firebase User type

// Abstract contract for authentication operations
abstract class AuthRepository {
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  // Stream to observe authentication state changes (e.g., user logs in/out)
  Stream<User?> get authStateChanges;

  // Get the currently logged-in user
  User? getCurrentUser();

// TODO: Add methods for phone authentication if you plan to implement it
// Future<void> verifyPhoneNumber({
//   required String phoneNumber,
//   required Function(PhoneAuthCredential) verificationCompleted,
//   required Function(FirebaseAuthException) verificationFailed,
//   required Function(String, int?) codeSent,
//   required Function(String) codeAutoRetrievalTimeout,
// });
// Future<User?> signInWithPhoneCredential({
//   required PhoneAuthCredential credential,
// });
}