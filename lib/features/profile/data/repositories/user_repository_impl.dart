// lib/features/profile/data/repositories/user_repository_impl.dart

import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grad_project/features/profile/data/datasources/user_remote_data_source.dart';
import 'package:grad_project/features/profile/domain/entities/user_entity.dart';
import 'package:grad_project/features/profile/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final FirebaseAuth _firebaseAuth;

  UserRepositoryImpl({
    UserRemoteDataSource? remoteDataSource,
    FirebaseAuth? firebaseAuth,
  })  : remoteDataSource = remoteDataSource ?? UserRemoteDataSourceImpl(),
        _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<UserEntity?> getUserProfile(String uid) async {
    try {
      return await remoteDataSource.getUserProfile(uid);
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  @override
  Future<void> updateUserProfile(UserEntity user) async {
    try {
      await remoteDataSource.updateUserProfile(user.id, user); // Correctly using user.id
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      return await remoteDataSource.uploadProfileImage(uid, imageFile);
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> createUserProfile(String uid, String email, String name) async {
    try {
      await remoteDataSource.createUserProfile(uid, email, name);
    } catch (e) {
      throw Exception('Failed to create user profile: $e; This might happen if user profile already exists.');
    }
  }

  @override
  User? getCurrentFirebaseUser() {
    return _firebaseAuth.currentUser;
  }
}