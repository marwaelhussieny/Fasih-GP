// lib/features/profile/data/repositories/user_repository_impl.dart

import 'dart:io';
import 'package:grad_project/features/profile/domain/entities/profile_user_entity.dart';
import 'package:grad_project/features/profile/data/datasources/user_remote_data_source.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';
import 'package:grad_project/features/profile/domain/repositories/user_repository.dart';


class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileUserEntity?> getUserProfile() async {
    // Calls the correct method on the remote data source
    final userModel = await remoteDataSource.getUserProfile();
    return userModel?.toEntity();
  }

  @override
  Future<ProfileUserEntity> updateProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  }) async {
    // Calls the correct method with the correct parameters
    final updatedUserModel = await remoteDataSource.updateUserProfile(
      fullName: fullName,
      phoneNumber: phoneNumber,
      job: job,
      dateOfBirth: dateOfBirth,
      country: country,
    );
    return updatedUserModel.toEntity();
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    // Calls the correct method on the remote data source
    return await remoteDataSource.uploadProfileImage(imageFile);
  }

  @override
  Future<void> createUserProfile({required ProfileUserEntity user}) async {
    // Converts the domain entity to a data model before sending to the data source
    final userModel = ProfileUserModel.fromEntity(user);
    await remoteDataSource.createUserProfile(user: userModel);
  }
}