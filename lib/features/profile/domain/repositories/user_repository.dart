// lib/features/profile/domain/repositories/user_repository.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User object from FirebaseAuth

// Abstract contract for user profile operations
abstract class UserRepository {
  // Get user profile by UID
  Future<UserEntity?> getUserProfile(String uid);

  // Update user profile data
  Future<void> updateUserProfile(UserEntity user);

  // Upload profile image and return its URL
  Future<String> uploadProfileImage(String uid, File imageFile);

  // Create initial user profile (called after sign-up)
  Future<void> createUserProfile(String uid, String email, String name);

  // Get the current Firebase authenticated user (for UID)
  User? getCurrentFirebaseUser();
}