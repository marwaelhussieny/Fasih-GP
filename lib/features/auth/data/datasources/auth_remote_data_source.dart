// lib/features/auth/data/datasources/auth_remote_data_source.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// Abstract interface for the remote authentication data source
abstract class AuthRemoteDataSource {
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password, // FIXED: Removed the extra 'String' here
  });

  Future<void> sendPasswordResetEmail({
    required String email,
  });

  Future<void> signOut();

  // Optionally, add methods for phone authentication if needed
  // Future<void> verifyPhoneNumber({
  //   required String phoneNumber,
  //   required Function(PhoneAuthCredential) verificationCompleted,
  //   required Function(FirebaseAuthException) verificationFailed,
  //   required Function(String, int?) codeSent,
  //   required Function(String) codeAutoRetrievalTimeout,
  // });
  // Future<UserCredential> signInWithPhoneCredential({
  //   required PhoneAuthCredential credential,
  // });

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges;

  // Get current user (if logged in)
  User? getCurrentUser();
}

// Implementation of the remote authentication data source using Firebase Auth
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  AuthRemoteDataSourceImpl({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Re-throw FirebaseAuthException to be caught by repository/use case
      throw e;
    } catch (e) {
      // Catch any other unexpected errors
      throw Exception('Failed to sign in: $e');
    }
  }

  @override
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  User? getCurrentUser() => _firebaseAuth.currentUser;

// Implement phone authentication methods if you enable them in Firebase
// @override
// Future<void> verifyPhoneNumber({
//   required String phoneNumber,
//   required Function(PhoneAuthCredential) verificationCompleted,
//   required Function(FirebaseAuthException) verificationFailed,
//   required Function(String, int?) codeSent,
//   required Function(String) codeAutoRetrievalTimeout,
// }) async {
//   await _firebaseAuth.verifyPhoneNumber(
//     phoneNumber: phoneNumber,
//     verificationCompleted: verificationCompleted,
//     verificationFailed: verificationFailed,
//     codeSent: codeSent,
//     codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
//   );
// }

// @override
// Future<UserCredential> signInWithPhoneCredential({required PhoneAuthCredential credential}) async {
//   try {
//     return await _firebaseAuth.signInWithCredential(credential);
//   } on FirebaseAuthException catch (e) {
//     throw e;
//   } catch (e) {
//     throw Exception('Failed to sign in with phone credential: $e');
//   }
// }
}