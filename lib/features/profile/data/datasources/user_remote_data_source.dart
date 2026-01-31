// lib/features/profile/data/datasources/user_remote_data_source.dart

import 'dart:io';
import 'package:grad_project/core/services/api_service.dart';
import 'package:grad_project/features/profile/data/models/profile_user_model.dart';

abstract class UserRemoteDataSource {
  Future<ProfileUserModel?> getUserProfile();
  Future<ProfileUserModel> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  });
  Future<String> uploadProfileImage(File imageFile);
  Future<void> createUserProfile({required ProfileUserModel user});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final ApiService apiService;

  UserRemoteDataSourceImpl({required this.apiService});

  @override
  Future<ProfileUserModel?> getUserProfile() async {
    try {
      final response = await apiService.get('/user/profile');

      if (response.isNotEmpty) {
        return ProfileUserModel.fromMap(response);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<ProfileUserModel> updateUserProfile({
    String? fullName,
    String? phoneNumber,
    String? job,
    DateTime? dateOfBirth,
    String? country,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (fullName != null) body['fullName'] = fullName;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (job != null) body['job'] = job;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (country != null) body['country'] = country;

      final response = await apiService.put('/user/profile', body: body);

      if (response.isEmpty) {
        throw Exception('Failed to update user profile: Response data is null.');
      }

      return ProfileUserModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadProfileImage(File imageFile) async {
    try {
      // Note: You'll need to implement uploadFile method in ApiService or use a different approach
      // For now, I'll show the structure but this method needs to be implemented in ApiService

      // If your ApiService doesn't have uploadFile method, you might need to use Dio directly
      // or implement it in the ApiService class

      throw UnimplementedError('Upload file method needs to be implemented in ApiService');

      /*
      // This is what it would look like if uploadFile was implemented:
      final response = await apiService.uploadFile(
        '/user/profile-image',
        imageFile,
        fieldName: 'profileImage',
      );

      if (response.isEmpty) {
        throw Exception('Failed to upload profile image: Response data is null.');
      }

      if (response.containsKey('imageUrl')) {
        return response['imageUrl'];
      } else {
        throw Exception('Failed to upload profile image: imageUrl not found in response.');
      }
      */
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  @override
  Future<void> createUserProfile({required ProfileUserModel user}) async {
    try {
      await apiService.post('/users', body: user.toMap());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }
}