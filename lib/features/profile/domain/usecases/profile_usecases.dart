// lib/features/profile/domain/usecases/profile_usecases.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/user_repository.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For User object from FirebaseAuth

// --- GetUserProfile Use Case ---
class GetUserProfile {
  final UserRepository repository;
  GetUserProfile(this.repository);

  Future<UserEntity?> call() async {
    final firebaseUser = repository.getCurrentFirebaseUser();
    if (firebaseUser == null) {
      return null;
    }
    return await repository.getUserProfile(firebaseUser.uid);
  }
}

// --- UpdateUserProfile Use Case ---
class UpdateUserProfile {
  final UserRepository repository;
  UpdateUserProfile(this.repository);

  Future<void> call(UserEntity user) async {
    await repository.updateUserProfile(user);
  }
}

// --- UploadProfileImage Use Case ---
class UploadProfileImage {
  final UserRepository repository;
  UploadProfileImage(this.repository);

  Future<String> call({required File imageFile}) async {
    final firebaseUser = repository.getCurrentFirebaseUser();
    if (firebaseUser == null) {
      throw Exception('No authenticated user to upload image for.');
    }
    return await repository.uploadProfileImage(firebaseUser.uid, imageFile);
  }
}

// --- CreateUserProfile Use Case ---
class CreateUserProfile {
  final UserRepository repository;
  CreateUserProfile(this.repository);

  Future<void> call({required String uid, required String email, required String name}) async {
    await repository.createUserProfile(uid, email, name);
  }
}