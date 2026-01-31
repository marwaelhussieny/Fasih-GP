// lib/features/profile/domain/repositories/user_repository.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';

// Abstract contract for user profile operations
abstract class UserRepository {
  // Get user profile
  Future<ProfileUserEntity?> getUserProfile();

  // Update user profile data
  Future<ProfileUserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  });

  // Upload profile image and return its URL
  Future<String> uploadProfileImage(File imageFile);

  // Create initial user profile (called after sign-up)
  Future<void> createUserProfile({required ProfileUserEntity user});
}