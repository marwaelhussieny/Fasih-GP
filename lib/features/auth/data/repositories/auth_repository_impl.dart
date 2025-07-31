// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:grad_project/features/auth/domain/repositories/auth_repository.dart';

// Implementation of the AuthRepository contract
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await remoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user; // Return the Firebase User object
    } on FirebaseAuthException {
      rethrow; // Re-throw Firebase specific exceptions
    } catch (e) {
      throw Exception('Failed to sign in: $e'); // Catch other errors
    }
  }

  @override
  Future<User?> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await remoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await remoteDataSource.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  @override
  Stream<User?> get authStateChanges => remoteDataSource.authStateChanges;

  @override
  User? getCurrentUser() => remoteDataSource.getCurrentUser();

// TODO: Implement phone authentication methods if added to AuthRemoteDataSource
// @override
// Future<void> verifyPhoneNumber(...) { ... }
// @override
// Future<User?> signInWithPhoneCredential(...) { ... }
}